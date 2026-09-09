-- PETRA — operational control: deadlines, demands, productivity and payment recognition
do $$ begin create type petra.task_status as enum ('pending','in_progress','completed','cancelled'); exception when duplicate_object then null; end $$;
do $$ begin create type petra.task_priority as enum ('low','normal','high','urgent'); exception when duplicate_object then null; end $$;

create table if not exists petra.demands (
  id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid references petra.orders(id) on delete cascade, quote_id uuid references petra.quotes(id) on delete cascade,
  title text not null, task_type text not null, responsible_user_id uuid references petra.users(id) on delete set null,
  status petra.task_status not null default 'pending', priority petra.task_priority not null default 'normal',
  starts_at timestamptz, due_at timestamptz, completed_at timestamptz,
  estimated_minutes integer not null default 0, actual_minutes integer not null default 0,
  metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists idx_demands_company_due on petra.demands(company_id,status,due_at);
create index if not exists idx_demands_user on petra.demands(company_id,responsible_user_id,status,due_at);

create table if not exists petra.payment_events (
  id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict,
  external_id text not null, order_id uuid references petra.orders(id) on delete set null,
  financial_entry_id uuid references petra.financial_entries(id) on delete set null, amount numeric(14,2) not null,
  occurred_at timestamptz not null default now(), source text not null, status text not null default 'received',
  payload jsonb not null default '{}'::jsonb, processed_at timestamptz, created_at timestamptz not null default now(), unique(company_id,external_id)
);
create index if not exists idx_payment_events_order on petra.payment_events(company_id,order_id,occurred_at desc);

create or replace function petra.reconcile_payment(p_company_id uuid,p_external_id text,p_amount numeric,p_order_id uuid,p_payment_method text default null,p_occurred_at timestamptz default now(),p_source text default 'manual_or_gateway',p_payload jsonb default '{}'::jsonb) returns jsonb language plpgsql as $$
declare v_event petra.payment_events; v_entry petra.financial_entries; v_total_paid numeric(14,2); v_order_total numeric(14,2); v_status petra.payment_status;
begin
 select * into v_event from petra.payment_events where company_id=p_company_id and external_id=p_external_id for update;
 if v_event.id is not null then return jsonb_build_object('event_id',v_event.id,'duplicate',true,'status',v_event.status); end if;
 insert into petra.financial_entries(company_id,customer_id,order_id,type,description,amount,paid_at,status,payment_method,metadata)
 select p_company_id,o.customer_id,o.id,'receivable','Pagamento reconhecido automaticamente',p_amount,p_occurred_at,'paid',p_payment_method,jsonb_build_object('source',p_source,'external_id',p_external_id)
 from petra.orders o where o.id=p_order_id and o.company_id=p_company_id returning * into v_entry;
 if v_entry.id is null then raise exception 'PETRA: order not found for payment recognition'; end if;
 insert into petra.payment_events(company_id,external_id,order_id,financial_entry_id,amount,occurred_at,source,status,payload,processed_at)
 values(p_company_id,p_external_id,p_order_id,v_entry.id,p_amount,p_occurred_at,p_source,'processed',p_payload,now()) returning * into v_event;
 select o.total into v_order_total from petra.orders o where o.id=p_order_id and o.company_id=p_company_id;
 select coalesce(sum(fe.amount) filter (where fe.status='paid'),0) into v_total_paid from petra.financial_entries fe where fe.company_id=p_company_id and fe.order_id=p_order_id;
 v_status := case when v_total_paid >= coalesce(v_order_total,0) and coalesce(v_order_total,0)>0 then 'paid'::petra.payment_status when v_total_paid>0 then 'partial'::petra.payment_status else 'pending'::petra.payment_status end;
 update petra.financial_entries set status=v_status,updated_at=now() where company_id=p_company_id and order_id=p_order_id and type='receivable';
 insert into petra.events(company_id,event_type,aggregate_type,aggregate_id,payload) values(p_company_id,'payment.recognized','order',p_order_id,jsonb_build_object('amount',p_amount,'external_id',p_external_id,'total_paid',v_total_paid,'order_total',v_order_total,'status',v_status));
 return jsonb_build_object('event_id',v_event.id,'financial_entry_id',v_entry.id,'total_paid',v_total_paid,'order_total',v_order_total,'payment_status',v_status,'duplicate',false);
end; $$;

create or replace function petra.touch_demand_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
drop trigger if exists trg_demands_updated_at on petra.demands;
create trigger trg_demands_updated_at before update on petra.demands for each row execute function petra.touch_demand_updated_at();

-- Automatically create the first operational demand and receivable when an order enters PETRA.
create or replace function petra.seed_order_operations() returns trigger language plpgsql as $$
declare v_due timestamptz := now()+interval '1 day';
begin
  insert into petra.demands(company_id,order_id,title,task_type,status,priority,starts_at,due_at,estimated_minutes,metadata)
  values(new.company_id,new.id,'Conferência / Medição','measurement','pending','high',now(),v_due,120,jsonb_build_object('stage','conference'))
  on conflict do nothing;
  insert into petra.financial_entries(company_id,customer_id,order_id,type,description,amount,due_date,status,metadata)
  values(new.company_id,new.customer_id,new.id,'receivable','Valor do pedido',new.total,null,'pending',jsonb_build_object('source','order.created'))
  on conflict do nothing;
  return new;
end; $$;
drop trigger if exists trg_seed_order_operations on petra.orders;
create trigger trg_seed_order_operations after insert on petra.orders for each row execute function petra.seed_order_operations();

-- Every operational stage creates a dated demand automatically; existing stage demand is reused.
create or replace function petra.seed_stage_demand() returns trigger language plpgsql as $$
declare v_title text; v_type text; v_days integer; v_priority petra.task_priority := 'normal';
begin
 if new.status is distinct from old.status then
  if new.status='conference' then v_title:='Conferência / Medição'; v_type:='measurement'; v_days:=1; v_priority:='high';
  elsif new.status='technical' then v_title:='Desenho Técnico / Compatibilização'; v_type:='technical'; v_days:=2;
  elsif new.status='production' then v_title:='Produção'; v_type:='production'; v_days:=3;
  elsif new.status='finishing' then v_title:='Acabamento'; v_type:='finishing'; v_days:=1;
  elsif new.status='logistics' then v_title:='Carregamento / Romaneio'; v_type:='logistics'; v_days:=1;
  elsif new.status='installation' then v_title:='Instalação'; v_type:='installation'; v_days:=coalesce(greatest(1,(new.installation_planned_date-current_date)),1);
  else v_title:=null;
  end if;
  if v_title is not null and not exists(select 1 from petra.demands where company_id=new.company_id and order_id=new.id and metadata->>'stage'=new.status) then
    insert into petra.demands(company_id,order_id,title,task_type,status,priority,starts_at,due_at,estimated_minutes,metadata)
    values(new.company_id,new.id,v_title,v_type,'pending',v_priority,now(),now()+(v_days||' days')::interval,case v_type when 'production' then 480 when 'installation' then 360 else 120 end,jsonb_build_object('stage',new.status));
  end if;
 end if;
 return new;
end; $$;
drop trigger if exists trg_seed_stage_demand on petra.orders;
create trigger trg_seed_stage_demand after update of status on petra.orders for each row execute function petra.seed_stage_demand();

create or replace view petra.productivity_by_user as
select d.company_id,d.responsible_user_id,u.full_name,
 count(*) filter(where d.status<>'cancelled') as total_demands,
 count(*) filter(where d.status='completed') as completed_demands,
 count(*) filter(where d.status<>'completed' and d.status<>'cancelled' and d.due_at is not null and d.due_at<now()) as overdue_demands,
 coalesce(round(100.0*count(*) filter(where d.status='completed')/nullif(count(*) filter(where d.status<>'cancelled'),0),1),0) as completion_rate,
 coalesce(round(100.0*count(*) filter(where d.status='completed' and d.due_at is not null and d.completed_at<=d.due_at)/nullif(count(*) filter(where d.status='completed' and d.due_at is not null),0),1),0) as on_time_rate,
 coalesce(sum(d.actual_minutes),0) as actual_minutes,coalesce(sum(d.estimated_minutes),0) as estimated_minutes
from petra.demands d left join petra.users u on u.id=d.responsible_user_id and u.company_id=d.company_id
group by d.company_id,d.responsible_user_id,u.full_name;

comment on table petra.demands is 'Operational demands with owner, deadline and productivity tracking.';
comment on table petra.payment_events is 'Idempotent payment events used to automatically reconcile financial entries.';

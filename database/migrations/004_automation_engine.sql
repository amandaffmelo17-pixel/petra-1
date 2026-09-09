-- PETRA — Automation Engine
-- Durable database-driven automations. External adapters (Trello/WhatsApp/etc.)
-- consume petra.automation_jobs without putting provider credentials in code.

create or replace function petra.enqueue_automation(
  p_company_id uuid,
  p_event_type text,
  p_target text,
  p_payload jsonb default '{}'::jsonb,
  p_run_at timestamptz default now()
) returns uuid language plpgsql as $$
declare job_id uuid;
begin
  insert into petra.automation_jobs(company_id,event_type,target,payload,run_at)
  values(p_company_id,p_event_type,p_target,coalesce(p_payload,'{}'::jsonb),coalesce(p_run_at,now()))
  returning id into job_id;
  return job_id;
end;
$$;

create or replace function petra.log_domain_event(
  p_company_id uuid,
  p_event_type text,
  p_aggregate_type text,
  p_aggregate_id uuid,
  p_payload jsonb default '{}'::jsonb
) returns uuid language plpgsql as $$
declare event_id uuid; correlation uuid := gen_random_uuid();
begin
  insert into petra.events(company_id,event_type,aggregate_type,aggregate_id,correlation_id,payload)
  values(p_company_id,p_event_type,p_aggregate_type,p_aggregate_id,correlation,coalesce(p_payload,'{}'::jsonb))
  returning id into event_id;
  return event_id;
end;
$$;

-- Quote approved -> operational order creation request.
create or replace function petra.automation_quote_approved()
returns trigger language plpgsql as $$
begin
  if new.status = 'approved' and old.status is distinct from 'approved' then
    perform petra.log_domain_event(new.company_id,'quote.approved','quote',new.id,jsonb_build_object('quote_id',new.id,'customer_id',new.customer_id,'work_id',new.work_id,'total',new.total));
    perform petra.enqueue_automation(new.company_id,'quote.approved','order.create',jsonb_build_object('quote_id',new.id,'customer_id',new.customer_id,'work_id',new.work_id,'total',new.total,'payment_terms',new.payment_terms));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_quote_approved_automation on petra.quotes;
create trigger trg_quote_approved_automation after update on petra.quotes for each row execute function petra.automation_quote_approved();

-- Approved measurement -> technical/drawing readiness notification.
create or replace function petra.automation_measurement_approved()
returns trigger language plpgsql as $$
begin
  if new.status = 'approved' and old.status is distinct from 'approved' then
    perform petra.log_domain_event(new.company_id,'measurement.approved','measurement',new.id,jsonb_build_object('measurement_id',new.id,'order_id',new.order_id,'measured_at',new.measured_at));
    perform petra.enqueue_automation(new.company_id,'measurement.approved','technical.ready',jsonb_build_object('measurement_id',new.id,'order_id',new.order_id));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_measurement_approved_automation on petra.measurements;
create trigger trg_measurement_approved_automation after update on petra.measurements for each row execute function petra.automation_measurement_approved();

-- Production release -> create/prepare production order.
create or replace function petra.automation_production_release()
returns trigger language plpgsql as $$
begin
  perform petra.log_domain_event(new.company_id,'production.released','order',new.order_id,jsonb_build_object('release_id',new.id,'measurement_id',new.measurement_id));
  perform petra.enqueue_automation(new.company_id,'production.released','production.prepare',jsonb_build_object('order_id',new.order_id,'measurement_id',new.measurement_id,'release_id',new.id));
  return new;
end;
$$;
drop trigger if exists trg_production_release_automation on petra.production_releases;
create trigger trg_production_release_automation after insert on petra.production_releases for each row execute function petra.automation_production_release();

-- Installation scheduled -> reminder/communication job.
create or replace function petra.automation_installation_scheduled()
returns trigger language plpgsql as $$
begin
  if new.scheduled_at is not null and (old.scheduled_at is distinct from new.scheduled_at) then
    perform petra.log_domain_event(new.company_id,'installation.scheduled','order',new.order_id,jsonb_build_object('installation_id',new.id,'order_id',new.order_id,'scheduled_at',new.scheduled_at));
    perform petra.enqueue_automation(new.company_id,'installation.scheduled','customer.notify',jsonb_build_object('order_id',new.order_id,'installation_id',new.id,'scheduled_at',new.scheduled_at));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_installation_scheduled_automation on petra.installations;
create trigger trg_installation_scheduled_automation after update on petra.installations for each row execute function petra.automation_installation_scheduled();

-- Completed installation -> close order and start post-sale automation.
create or replace function petra.automation_installation_completed()
returns trigger language plpgsql as $$
begin
  if new.status = 'completed' and old.status is distinct from 'completed' then
    perform petra.log_domain_event(new.company_id,'installation.completed','order',new.order_id,jsonb_build_object('installation_id',new.id,'order_id',new.order_id,'acceptance',new.customer_acceptance));
    perform petra.enqueue_automation(new.company_id,'installation.completed','post_sale.start',jsonb_build_object('order_id',new.order_id,'installation_id',new.id));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_installation_completed_automation on petra.installations;
create trigger trg_installation_completed_automation after update on petra.installations for each row execute function petra.automation_installation_completed();

-- Finished order with installation date -> Trello/integration job.
create or replace function petra.automation_order_finished()
returns trigger language plpgsql as $$
begin
  if new.status = 'finished' and old.status is distinct from 'finished' then
    perform petra.log_domain_event(new.company_id,'order.finished','order',new.id,jsonb_build_object('order_id',new.id,'number',new.number,'customer_id',new.customer_id));
    perform petra.enqueue_automation(new.company_id,'order.finished','trello.card.create',jsonb_build_object('order_id',new.id,'number',new.number,'title','PEDIDO','customer_id',new.customer_id,'installation_planned_date',new.installation_planned_date));
    perform petra.enqueue_automation(new.company_id,'order.finished','customer.post_sale',jsonb_build_object('order_id',new.id,'customer_id',new.customer_id));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_order_finished_automation on petra.orders;
create trigger trg_order_finished_automation after update on petra.orders for each row execute function petra.automation_order_finished();

-- Financial payment recognized -> notify commercial/administrative workflow.
create or replace function petra.automation_payment_recognized()
returns trigger language plpgsql as $$
begin
  if new.status = 'paid' and old.status is distinct from 'paid' then
    perform petra.log_domain_event(new.company_id,'payment.recognized','financial_entry',new.id,jsonb_build_object('entry_id',new.id,'order_id',new.order_id,'amount',new.amount));
    perform petra.enqueue_automation(new.company_id,'payment.recognized','order.payment-confirmed',jsonb_build_object('entry_id',new.id,'order_id',new.order_id,'amount',new.amount));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_payment_recognized_automation on petra.financial_entries;
create trigger trg_payment_recognized_automation after update on petra.financial_entries for each row execute function petra.automation_payment_recognized();

comment on function petra.enqueue_automation is 'Creates durable automation jobs for provider adapters.';
comment on table petra.automation_jobs is 'Durable queue. A job is retried by the adapter/worker and only marked completed after successful execution.';

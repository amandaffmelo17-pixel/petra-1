-- PETRA — Operational completion foundation
-- Migration 002
-- Extends the initial schema with the operational domains and critical gates.
-- This migration defines the database contracts; execution against a real
-- PostgreSQL environment is still required before production sign-off.

create type petra.measurement_status as enum ('draft','approved','rejected');
create type petra.production_status as enum ('pending','released','in_progress','quality_check','completed','blocked');
create type petra.installation_status as enum ('scheduled','in_progress','completed','cancelled');
create type petra.document_status as enum ('draft','final','archived');
create type petra.payment_status as enum ('pending','partial','paid','cancelled','overdue');

alter table petra.orders
  add column if not exists production_released_at timestamptz,
  add column if not exists production_released_by uuid references petra.users(id) on delete set null,
  add column if not exists finalised_at timestamptz,
  add column if not exists finalised_by uuid references petra.users(id) on delete set null;

create table if not exists petra.measurements (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid not null references petra.orders(id) on delete cascade,
  environment_id uuid references petra.environments(id) on delete restrict,
  measured_at timestamptz not null,
  measured_by uuid references petra.users(id) on delete set null,
  status petra.measurement_status not null default 'draft',
  checklist jsonb not null default '{}'::jsonb,
  evidence jsonb not null default '[]'::jsonb,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_measurements_order on petra.measurements(company_id, order_id, measured_at desc);
create index if not exists idx_measurements_status on petra.measurements(company_id, status);

create table if not exists petra.production_releases (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid not null references petra.orders(id) on delete restrict,
  measurement_id uuid not null references petra.measurements(id) on delete restrict,
  released_at timestamptz not null default now(),
  released_by uuid references petra.users(id) on delete set null,
  notes text,
  unique(order_id)
);

create table if not exists petra.technical_drawings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid not null references petra.orders(id) on delete cascade,
  environment_id uuid references petra.environments(id) on delete restrict,
  title text not null,
  scale text,
  page_format text not null default 'A4',
  drawing_data jsonb not null default '{}'::jsonb,
  file_url text,
  status text not null default 'draft',
  approved_at timestamptz,
  approved_by uuid references petra.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists petra.production_orders (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid not null references petra.orders(id) on delete cascade,
  technical_drawing_id uuid references petra.technical_drawings(id) on delete restrict,
  status petra.production_status not null default 'pending',
  released_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  responsible_user_id uuid references petra.users(id) on delete set null,
  checklist jsonb not null default '{}'::jsonb,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(order_id)
);

create table if not exists petra.production_items (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  production_order_id uuid not null references petra.production_orders(id) on delete cascade,
  order_item_id uuid references petra.order_items(id) on delete set null,
  environment_id uuid references petra.environments(id) on delete set null,
  description text not null,
  material text,
  quantity numeric(12,3) not null default 1,
  dimensions jsonb not null default '{}'::jsonb,
  finish text,
  cutting_data jsonb not null default '{}'::jsonb,
  waste_m2 numeric(12,3) not null default 0,
  quality_status text not null default 'pending',
  notes text
);

create table if not exists petra.finishing_tasks (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  production_order_id uuid not null references petra.production_orders(id) on delete cascade,
  description text not null,
  finish_type text,
  status text not null default 'pending',
  responsible_user_id uuid references petra.users(id) on delete set null,
  completed_at timestamptz,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists petra.logistics_dispatches (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid not null references petra.orders(id) on delete cascade,
  planned_at timestamptz,
  loaded_at timestamptz,
  vehicle text,
  driver text,
  checklist jsonb not null default '{}'::jsonb,
  status text not null default 'pending',
  proof_document_id uuid references petra.documents(id) on delete set null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists petra.installations (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid not null references petra.orders(id) on delete cascade,
  scheduled_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  team jsonb not null default '[]'::jsonb,
  status petra.installation_status not null default 'scheduled',
  checklist jsonb not null default '{}'::jsonb,
  evidence jsonb not null default '[]'::jsonb,
  customer_acceptance jsonb not null default '{}'::jsonb,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(order_id)
);

create table if not exists petra.materials (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  code text,
  name text not null,
  category text,
  unit text not null default 'un',
  current_stock numeric(14,3) not null default 0,
  minimum_stock numeric(14,3) not null default 0,
  cost numeric(14,2) not null default 0,
  active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, code)
);

create table if not exists petra.stock_movements (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  material_id uuid not null references petra.materials(id) on delete restrict,
  order_id uuid references petra.orders(id) on delete set null,
  movement_type text not null,
  quantity numeric(14,3) not null,
  unit_cost numeric(14,2),
  occurred_at timestamptz not null default now(),
  actor_user_id uuid references petra.users(id) on delete set null,
  notes text
);

create table if not exists petra.financial_entries (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  customer_id uuid references petra.customers(id) on delete set null,
  order_id uuid references petra.orders(id) on delete set null,
  type text not null,
  description text not null,
  amount numeric(14,2) not null,
  due_date date,
  paid_at timestamptz,
  status petra.payment_status not null default 'pending',
  payment_method text,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid references petra.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists petra.commissions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  order_id uuid references petra.orders(id) on delete set null,
  user_id uuid references petra.users(id) on delete set null,
  role text not null,
  percentage numeric(7,4) not null default 0,
  base_amount numeric(14,2) not null default 0,
  amount numeric(14,2) not null default 0,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table if not exists petra.automation_jobs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete restrict,
  event_type text not null,
  target text not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'pending',
  attempts integer not null default 0,
  last_error text,
  run_at timestamptz not null default now(),
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists petra.assistant_sessions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete cascade,
  user_id uuid references petra.users(id) on delete cascade,
  context jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists petra.assistant_messages (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete cascade,
  session_id uuid not null references petra.assistant_sessions(id) on delete cascade,
  role text not null,
  content text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_production_company_status on petra.production_orders(company_id, status);
create index if not exists idx_installations_company_date on petra.installations(company_id, scheduled_at);
create index if not exists idx_financial_company_status on petra.financial_entries(company_id, status, due_date);
create index if not exists idx_stock_company_material on petra.stock_movements(company_id, material_id, occurred_at desc);
create index if not exists idx_automation_company_status on petra.automation_jobs(company_id, status, run_at);

-- Critical rule: no production release without an approved measurement.
create or replace function petra.require_measurement_for_production_release()
returns trigger language plpgsql as $$
begin
  if not exists (
    select 1
      from petra.measurements m
     where m.id = new.measurement_id
       and m.order_id = new.order_id
       and m.company_id = new.company_id
       and m.measured_at is not null
       and m.status = 'approved'
  ) then
    raise exception 'PETRA: production release requires an approved measurement with a date';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_production_release_requires_measurement on petra.production_releases;
create trigger trg_production_release_requires_measurement
before insert or update on petra.production_releases
for each row execute function petra.require_measurement_for_production_release();

-- Production orders can only be released through a valid production release.
create or replace function petra.require_release_for_production()
returns trigger language plpgsql as $$
begin
  if new.status in ('released','in_progress','quality_check','completed')
     and not exists (
       select 1 from petra.production_releases r
        where r.order_id = new.order_id
          and r.company_id = new.company_id
     ) then
    raise exception 'PETRA: production cannot advance without a registered production release';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_production_requires_release on petra.production_orders;
create trigger trg_production_requires_release
before insert or update on petra.production_orders
for each row execute function petra.require_release_for_production();

-- An order cannot be moved into production-or-later without a release.
create or replace function petra.require_order_production_release()
returns trigger language plpgsql as $$
begin
  if new.status in ('production','finishing','logistics','installation','finished')
     and not exists (
       select 1 from petra.production_releases r
        where r.order_id = new.id
          and r.company_id = new.company_id
     ) then
    raise exception 'PETRA: order cannot enter production stages without an approved measurement and production release';
  end if;
  if new.status = 'finished' and (new.installation_planned_date is null or new.finalised_at is null) then
    raise exception 'PETRA: finished order requires installation date and finalisation timestamp';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_order_requires_production_release on petra.orders;
create trigger trg_order_requires_production_release
before insert or update on petra.orders
for each row execute function petra.require_order_production_release();

-- When an order is finalised, preserve the closure timestamp.
create or replace function petra.set_order_finalisation()
returns trigger language plpgsql as $$
begin
  if new.status = 'finished' and old.status is distinct from 'finished' then
    new.finalised_at = coalesce(new.finalised_at, now());
    new.closed_at = coalesce(new.closed_at, now());
  end if;
  return new;
end;
$$;

drop trigger if exists trg_order_finalisation on petra.orders;
create trigger trg_order_finalisation
before update on petra.orders
for each row execute function petra.set_order_finalisation();

-- Common updated_at triggers for new mutable operational tables.
do $$
declare t text;
begin
  foreach t in array array[
    'measurements','technical_drawings','production_orders','installations',
    'materials','financial_entries','assistant_sessions'
  ] loop
    execute format('drop trigger if exists trg_%s_updated_at on petra.%I', t, t);
    execute format('create trigger trg_%s_updated_at before update on petra.%I for each row execute function petra.touch_updated_at()', t, t);
  end loop;
end $$;

comment on table petra.measurements is 'Registered measurement/conference evidence. Production requires an approved measurement.';
comment on table petra.production_releases is 'Auditable release gate between measurement and production.';
comment on table petra.technical_drawings is 'A4/scale technical drawing contract and approval state.';
comment on table petra.automation_jobs is 'Durable integration/automation queue for adapters such as Trello and WhatsApp.';

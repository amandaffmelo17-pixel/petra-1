-- PETRA — PostgreSQL initial schema
-- Migration 001 — independent multi-tenant core

create extension if not exists pgcrypto;
create schema if not exists petra;

create type petra.company_status as enum ('active','inactive','suspended');
create type petra.user_status as enum ('active','inactive','blocked');
create type petra.quote_status as enum ('draft','sent','negotiation','approved','refused','expired');
create type petra.order_status as enum ('new','conference','technical','production','finishing','logistics','installation','finished','cancelled');

create table petra.companies (id uuid primary key default gen_random_uuid(), legal_name text not null, trade_name text not null, document_number text, email text, phone text, whatsapp text, address jsonb not null default '{}'::jsonb, logo_url text, status petra.company_status not null default 'active', settings jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table petra.users (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, full_name text not null, email text not null, phone text, status petra.user_status not null default 'active', role text not null default 'user', permissions jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(company_id,email));
create table petra.customers (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, name text not null, document_number text, email text, phone text, whatsapp text, address jsonb not null default '{}'::jsonb, notes text, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table petra.works (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, customer_id uuid not null references petra.customers(id) on delete restrict, name text not null, address jsonb not null default '{}'::jsonb, notes text, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table petra.environments (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, work_id uuid not null references petra.works(id) on delete cascade, name text not null, description text, area_m2 numeric(12,3), status text not null default 'active', created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table petra.quotes (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, customer_id uuid not null references petra.customers(id) on delete restrict, work_id uuid references petra.works(id) on delete restrict, number text not null, status petra.quote_status not null default 'draft', valid_until date, subtotal numeric(14,2) not null default 0, discount numeric(14,2) not null default 0, total numeric(14,2) not null default 0, payment_terms text, notes text, created_by uuid references petra.users(id) on delete set null, approved_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(company_id,number));
create table petra.quote_items (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, quote_id uuid not null references petra.quotes(id) on delete cascade, environment_id uuid references petra.environments(id) on delete restrict, description text not null, material text, quantity numeric(12,3) not null default 1, unit text not null default 'un', unit_price numeric(14,2) not null default 0, finish_charge numeric(14,2) not null default 0, total numeric(14,2) not null default 0, metadata jsonb not null default '{}'::jsonb);
create table petra.orders (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, customer_id uuid not null references petra.customers(id) on delete restrict, work_id uuid references petra.works(id) on delete restrict, quote_id uuid references petra.quotes(id) on delete restrict, number text not null, status petra.order_status not null default 'new', installation_planned_date date, closed_at timestamptz, closed_by uuid references petra.users(id) on delete set null, payment_terms text, total numeric(14,2) not null default 0, notes text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(company_id,number));
create table petra.order_items (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, order_id uuid not null references petra.orders(id) on delete cascade, environment_id uuid references petra.environments(id) on delete restrict, description text not null, material text, quantity numeric(12,3) not null default 1, unit text not null default 'un', unit_price numeric(14,2) not null default 0, total numeric(14,2) not null default 0, metadata jsonb not null default '{}'::jsonb);
create table petra.documents (id uuid primary key default gen_random_uuid(), company_id uuid not null references petra.companies(id) on delete restrict, customer_id uuid references petra.customers(id) on delete restrict, work_id uuid references petra.works(id) on delete restrict, quote_id uuid references petra.quotes(id) on delete restrict, order_id uuid references petra.orders(id) on delete restrict, environment_id uuid references petra.environments(id) on delete restrict, document_type text not null, title text not null, version integer not null default 1, file_url text, storage_provider text, metadata jsonb not null default '{}'::jsonb, created_by uuid references petra.users(id) on delete set null, created_at timestamptz not null default now());
create table petra.events (id uuid primary key default gen_random_uuid(), company_id uuid references petra.companies(id) on delete restrict, event_type text not null, aggregate_type text, aggregate_id uuid, actor_user_id uuid references petra.users(id) on delete set null, correlation_id uuid, payload jsonb not null default '{}'::jsonb, created_at timestamptz not null default now());
create table petra.audit_log (id uuid primary key default gen_random_uuid(), company_id uuid references petra.companies(id) on delete restrict, actor_user_id uuid references petra.users(id) on delete set null, action text not null, entity_type text not null, entity_id uuid, before_data jsonb, after_data jsonb, correlation_id uuid, created_at timestamptz not null default now());

create index idx_users_company on petra.users(company_id);
create index idx_customers_company on petra.customers(company_id);
create index idx_works_company on petra.works(company_id);
create index idx_environments_company on petra.environments(company_id);
create index idx_quotes_company_status on petra.quotes(company_id,status);
create index idx_orders_company_status on petra.orders(company_id,status);
create index idx_orders_installation_date on petra.orders(company_id,installation_planned_date);
create index idx_documents_company_order on petra.documents(company_id,order_id);
create index idx_events_company_created on petra.events(company_id,created_at desc);
create index idx_audit_company_created on petra.audit_log(company_id,created_at desc);

create or replace function petra.touch_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
create trigger trg_companies_updated_at before update on petra.companies for each row execute function petra.touch_updated_at();
create trigger trg_users_updated_at before update on petra.users for each row execute function petra.touch_updated_at();
create trigger trg_customers_updated_at before update on petra.customers for each row execute function petra.touch_updated_at();
create trigger trg_works_updated_at before update on petra.works for each row execute function petra.touch_updated_at();
create trigger trg_environments_updated_at before update on petra.environments for each row execute function petra.touch_updated_at();
create trigger trg_quotes_updated_at before update on petra.quotes for each row execute function petra.touch_updated_at();
create trigger trg_orders_updated_at before update on petra.orders for each row execute function petra.touch_updated_at();

create or replace function petra.prevent_closed_order_update() returns trigger language plpgsql as $$ begin if old.closed_at is not null then raise exception 'PETRA: closed orders cannot be altered'; end if; return new; end; $$;
create trigger trg_orders_immutable_when_closed before update on petra.orders for each row execute function petra.prevent_closed_order_update();

comment on schema petra is 'PETRA independent multi-tenant operational database';

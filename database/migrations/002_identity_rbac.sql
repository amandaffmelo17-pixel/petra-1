-- PETRA — Identity, tenant isolation and RBAC foundation
-- Migration 002 — roles, permissions and company module configuration

create type petra.permission_effect as enum ('allow','deny');

create table petra.roles (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete cascade,
  name text not null,
  description text,
  is_system boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, name)
);

create table petra.role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references petra.roles(id) on delete cascade,
  module text not null,
  action text not null,
  effect petra.permission_effect not null default 'allow',
  unique(role_id, module, action)
);

create table petra.user_roles (
  user_id uuid not null references petra.users(id) on delete cascade,
  role_id uuid not null references petra.roles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id, role_id)
);

create table petra.company_modules (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references petra.companies(id) on delete cascade,
  module_key text not null,
  enabled boolean not null default true,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, module_key)
);

create index idx_roles_company on petra.roles(company_id);
create index idx_role_permissions_role on petra.role_permissions(role_id);
create index idx_user_roles_user on petra.user_roles(user_id);
create index idx_company_modules_company on petra.company_modules(company_id);

create trigger trg_roles_updated_at before update on petra.roles for each row execute function petra.touch_updated_at();
create trigger trg_company_modules_updated_at before update on petra.company_modules for each row execute function petra.touch_updated_at();

-- Every membership must belong to the same company as the user.
create or replace function petra.prevent_cross_company_role_assignment() returns trigger
language plpgsql as $$
declare role_company uuid;
declare user_company uuid;
begin
  select company_id into role_company from petra.roles where id = new.role_id;
  select company_id into user_company from petra.users where id = new.user_id;
  if role_company is null or user_company is null or role_company <> user_company then
    raise exception 'PETRA: user and role must belong to the same company';
  end if;
  return new;
end;
$$;

create trigger trg_user_roles_same_company
before insert or update on petra.user_roles
for each row execute function petra.prevent_cross_company_role_assignment();

comment on table petra.roles is 'Tenant-scoped roles managed by PETRA configuration.';
comment on table petra.role_permissions is 'Explicit module/action permissions for each role.';
comment on table petra.company_modules is 'Enabled modules and company-specific configuration; no customer-specific code.';

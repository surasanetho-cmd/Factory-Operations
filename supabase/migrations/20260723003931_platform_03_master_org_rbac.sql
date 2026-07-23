-- Module: PLATFORM
-- Org + RBAC masters: plant, department, user_profile, role, permission, junctions

-- ---------------------------------------------------------------------------
-- master.plant
-- ---------------------------------------------------------------------------
create table master.plant (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name text not null,
  timezone text not null default 'Asia/Bangkok',
  default_calendar_id uuid null, -- FK added when calendar module lands
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null,
  updated_by uuid null,
  deleted_at timestamptz null,
  deleted_by uuid null,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_plant_version_positive check (version >= 1)
);

create unique index uq_plant_code_active
  on master.plant (code)
  where deleted_at is null;

create trigger trg_plant_set_updated_at
  before update on master.plant
  for each row execute function master.set_updated_at();

comment on table master.plant is 'Site / plant root';

-- ---------------------------------------------------------------------------
-- master.department
-- ---------------------------------------------------------------------------
create table master.department (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  parent_id uuid null references master.department (id) on delete restrict,
  code text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null,
  updated_by uuid null,
  deleted_at timestamptz null,
  deleted_by uuid null,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_department_version_positive check (version >= 1)
);

create unique index uq_department_plant_code_active
  on master.department (plant_id, code)
  where deleted_at is null;

create index ix_department_plant_id on master.department (plant_id);
create index ix_department_parent_id on master.department (parent_id);

create trigger trg_department_set_updated_at
  before update on master.department
  for each row execute function master.set_updated_at();

-- ---------------------------------------------------------------------------
-- master.user_profile
-- ---------------------------------------------------------------------------
create table master.user_profile (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null,
  employee_code text not null,
  display_name text not null,
  email text not null,
  department_id uuid null references master.department (id) on delete restrict,
  default_plant_id uuid null references master.plant (id) on delete restrict,
  locale text not null default 'en',
  timezone text null,
  theme_pref text not null default 'auto',
  font_scale numeric(4, 2) not null default 1.00,
  compact_mode boolean not null default false,
  sidebar_collapsed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null,
  updated_by uuid null,
  deleted_at timestamptz null,
  deleted_by uuid null,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_user_profile_version_positive check (version >= 1),
  constraint ck_user_profile_theme_pref check (theme_pref in ('light', 'dark', 'auto')),
  constraint ck_user_profile_font_scale check (font_scale >= 0.80 and font_scale <= 1.50)
);

-- auth.users FK: present on Supabase; wrap for local tooling that may lack auth schema
do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'auth'
      and table_name = 'users'
  ) then
    alter table master.user_profile
      add constraint fk_user_profile_auth_user_id
      foreign key (auth_user_id) references auth.users (id) on delete restrict;
  end if;
end $$;

create unique index uq_user_profile_auth_user_id
  on master.user_profile (auth_user_id);

create unique index uq_user_profile_employee_code_active
  on master.user_profile (employee_code)
  where deleted_at is null;

create index ix_user_profile_default_plant_id on master.user_profile (default_plant_id);
create index ix_user_profile_department_id on master.user_profile (department_id);

create trigger trg_user_profile_set_updated_at
  before update on master.user_profile
  for each row execute function master.set_updated_at();

-- Actor FKs (added after user_profile exists)
alter table master.plant
  add constraint fk_plant_created_by foreign key (created_by) references master.user_profile (id) on delete restrict,
  add constraint fk_plant_updated_by foreign key (updated_by) references master.user_profile (id) on delete restrict,
  add constraint fk_plant_deleted_by foreign key (deleted_by) references master.user_profile (id) on delete restrict;

alter table master.department
  add constraint fk_department_created_by foreign key (created_by) references master.user_profile (id) on delete restrict,
  add constraint fk_department_updated_by foreign key (updated_by) references master.user_profile (id) on delete restrict,
  add constraint fk_department_deleted_by foreign key (deleted_by) references master.user_profile (id) on delete restrict;

alter table master.user_profile
  add constraint fk_user_profile_created_by foreign key (created_by) references master.user_profile (id) on delete restrict,
  add constraint fk_user_profile_updated_by foreign key (updated_by) references master.user_profile (id) on delete restrict,
  add constraint fk_user_profile_deleted_by foreign key (deleted_by) references master.user_profile (id) on delete restrict;

-- ---------------------------------------------------------------------------
-- master.role / permission
-- ---------------------------------------------------------------------------
create table master.role (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name text not null,
  description text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_role_version_positive check (version >= 1)
);

create unique index uq_role_code_active
  on master.role (code)
  where deleted_at is null;

create trigger trg_role_set_updated_at
  before update on master.role
  for each row execute function master.set_updated_at();

create table master.permission (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  module text not null,
  action text not null,
  resource text not null,
  description text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_permission_version_positive check (version >= 1)
);

create unique index uq_permission_code_active
  on master.permission (code)
  where deleted_at is null;

create trigger trg_permission_set_updated_at
  before update on master.permission
  for each row execute function master.set_updated_at();

-- ---------------------------------------------------------------------------
-- Junctions (pattern J)
-- ---------------------------------------------------------------------------
create table master.role_permission (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references master.role (id) on delete restrict,
  permission_id uuid not null references master.permission (id) on delete restrict,
  created_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true
);

create unique index uq_role_permission_pair_active
  on master.role_permission (role_id, permission_id)
  where deleted_at is null;

create index ix_role_permission_role on master.role_permission (role_id);
create index ix_role_permission_permission on master.role_permission (permission_id);

create table master.user_role (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references master.user_profile (id) on delete restrict,
  role_id uuid not null references master.role (id) on delete restrict,
  plant_id uuid null references master.plant (id) on delete restrict,
  created_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true
);

-- Unique with NULL plant_id treated as sentinel all-plants
create unique index uq_user_role_triple_active
  on master.user_role (
    user_id,
    role_id,
    coalesce(plant_id, '00000000-0000-0000-0000-000000000000'::uuid)
  )
  where deleted_at is null;

create index ix_user_role_user on master.user_role (user_id) where deleted_at is null;
create index ix_user_role_plant on master.user_role (plant_id);

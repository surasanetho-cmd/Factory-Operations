-- Module: CALENDAR & RESOURCES
-- master.production_line, master.machine

-- ---------------------------------------------------------------------------
-- master.production_line
-- ---------------------------------------------------------------------------
create table master.production_line (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  code text not null,
  name text not null,
  tonnage integer not null,
  sort_order integer not null default 0,
  calendar_id uuid null references master.calendar (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_production_line_version_positive check (version >= 1),
  constraint ck_production_line_tonnage_positive check (tonnage > 0)
);

create unique index uq_production_line_plant_code_active
  on master.production_line (plant_id, code)
  where deleted_at is null;

create index ix_production_line_plant_sort
  on master.production_line (plant_id, sort_order)
  where deleted_at is null;

create index ix_production_line_calendar_id
  on master.production_line (calendar_id)
  where deleted_at is null;

create trigger trg_production_line_set_updated_at
  before update on master.production_line
  for each row execute function master.set_updated_at();

comment on table master.production_line is 'Production lines (seed PL-110T … PL-3200T)';

-- ---------------------------------------------------------------------------
-- master.machine
-- ---------------------------------------------------------------------------
create table master.machine (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  production_line_id uuid not null references master.production_line (id) on delete restrict,
  code text not null,
  name text not null,
  machine_type text null,
  rated_capacity numeric(18, 6) null,
  calendar_id uuid null references master.calendar (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_machine_version_positive check (version >= 1),
  constraint ck_machine_rated_capacity_nonneg check (rated_capacity is null or rated_capacity >= 0)
);

create unique index uq_machine_plant_code_active
  on master.machine (plant_id, code)
  where deleted_at is null;

create index ix_machine_line_active
  on master.machine (production_line_id)
  where deleted_at is null;

create index ix_machine_calendar_id
  on master.machine (calendar_id)
  where deleted_at is null;

create trigger trg_machine_set_updated_at
  before update on master.machine
  for each row execute function master.set_updated_at();

comment on table master.machine is 'Machines on a production line for resource planning';

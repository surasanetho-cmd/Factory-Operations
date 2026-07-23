-- Module: CALENDAR & RESOURCES
-- master.shift, master.shift_assignment, master.capacity

-- ---------------------------------------------------------------------------
-- master.shift
-- ---------------------------------------------------------------------------
create table master.shift (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  code text not null,
  name text not null,
  start_time time not null,
  end_time time not null,
  break_minutes integer not null default 0,
  crosses_midnight boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_shift_version_positive check (version >= 1),
  constraint ck_shift_break_nonneg check (break_minutes >= 0),
  constraint ck_shift_time_span check (
    crosses_midnight = true
    or start_time < end_time
  )
);

create unique index uq_shift_plant_code_active
  on master.shift (plant_id, code)
  where deleted_at is null;

create index ix_shift_plant_id
  on master.shift (plant_id)
  where deleted_at is null;

create trigger trg_shift_set_updated_at
  before update on master.shift
  for each row execute function master.set_updated_at();

comment on table master.shift is 'Shift templates (local civil times in plant/calendar TZ)';

-- ---------------------------------------------------------------------------
-- master.shift_assignment
-- weekday_mask: bit0=Mon … bit6=Sun (value 1=Mon, 2=Tue, … 64=Sun)
-- ---------------------------------------------------------------------------
create table master.shift_assignment (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  shift_id uuid not null references master.shift (id) on delete restrict,
  production_line_id uuid null references master.production_line (id) on delete restrict,
  machine_id uuid null references master.machine (id) on delete restrict,
  effective_from date not null,
  effective_to date null,
  weekday_mask smallint not null default 127,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_shift_assignment_version_positive check (version >= 1),
  constraint ck_shift_assignment_not_both check (
    not (production_line_id is not null and machine_id is not null)
  ),
  constraint ck_shift_assignment_effective_range check (
    effective_to is null or effective_to >= effective_from
  ),
  constraint ck_shift_assignment_weekday_mask check (
    weekday_mask >= 1 and weekday_mask <= 127
  )
);

create index ix_shift_assignment_plant_from
  on master.shift_assignment (plant_id, effective_from, effective_to)
  where deleted_at is null;

create index ix_shift_assignment_shift_id
  on master.shift_assignment (shift_id)
  where deleted_at is null;

create index ix_shift_assignment_line_id
  on master.shift_assignment (production_line_id)
  where deleted_at is null and production_line_id is not null;

create index ix_shift_assignment_machine_id
  on master.shift_assignment (machine_id)
  where deleted_at is null and machine_id is not null;

create trigger trg_shift_assignment_set_updated_at
  before update on master.shift_assignment
  for each row execute function master.set_updated_at();

comment on table master.shift_assignment is 'Dated/scoped shift application (plant-wide, line, or machine)';

-- ---------------------------------------------------------------------------
-- master.capacity — exactly one of line XOR machine
-- ---------------------------------------------------------------------------
create table master.capacity (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  production_line_id uuid null references master.production_line (id) on delete restrict,
  machine_id uuid null references master.machine (id) on delete restrict,
  shift_id uuid not null references master.shift (id) on delete restrict,
  jobs_per_day integer null,
  hours_per_shift numeric(8, 2) null,
  effective_from date not null,
  effective_to date null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_capacity_version_positive check (version >= 1),
  constraint ck_capacity_line_xor_machine check (
    (production_line_id is not null and machine_id is null)
    or (production_line_id is null and machine_id is not null)
  ),
  constraint ck_capacity_effective_range check (
    effective_to is null or effective_to >= effective_from
  ),
  constraint ck_capacity_jobs_nonneg check (jobs_per_day is null or jobs_per_day >= 0),
  constraint ck_capacity_hours_nonneg check (hours_per_shift is null or hours_per_shift >= 0)
);

create index ix_capacity_line_shift_active
  on master.capacity (production_line_id, shift_id, effective_from)
  where deleted_at is null and production_line_id is not null;

create index ix_capacity_machine_shift_active
  on master.capacity (machine_id, shift_id, effective_from)
  where deleted_at is null and machine_id is not null;

create index ix_capacity_plant_id
  on master.capacity (plant_id)
  where deleted_at is null;

create trigger trg_capacity_set_updated_at
  before update on master.capacity
  for each row execute function master.set_updated_at();

comment on table master.capacity is 'Nominal jobs/hours capacity per line XOR machine + shift + effectivity';

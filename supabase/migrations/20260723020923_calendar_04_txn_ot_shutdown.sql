-- Module: CALENDAR & RESOURCES
-- txn.ot_window, txn.machine_shutdown

-- ---------------------------------------------------------------------------
-- txn.ot_window
-- ---------------------------------------------------------------------------
create table txn.ot_window (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  production_line_id uuid null references master.production_line (id) on delete restrict,
  machine_id uuid null references master.machine (id) on delete restrict,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status_code text not null default 'pending',
  reason_code_id uuid null references master.reason_code (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_ot_window_version_positive check (version >= 1),
  constraint ck_ot_window_has_resource check (
    production_line_id is not null or machine_id is not null
  ),
  constraint ck_ot_window_xor check (
    (production_line_id is not null and machine_id is null)
    or (production_line_id is null and machine_id is not null)
  ),
  constraint ck_ot_window_time_order check (end_at > start_at)
);

create index ix_ot_window_resource_time
  on txn.ot_window (plant_id, start_at, end_at)
  where deleted_at is null;

create index ix_ot_window_line_time
  on txn.ot_window (production_line_id, start_at)
  where deleted_at is null and production_line_id is not null;

create index ix_ot_window_machine_time
  on txn.ot_window (machine_id, start_at)
  where deleted_at is null and machine_id is not null;

create index ix_ot_window_status
  on txn.ot_window (status_code)
  where deleted_at is null;

create trigger trg_ot_window_set_updated_at
  before update on txn.ot_window
  for each row execute function master.set_updated_at();

comment on table txn.ot_window is 'Approved overtime intervals consumed by Calendar Engine';

-- ---------------------------------------------------------------------------
-- txn.machine_shutdown
-- ---------------------------------------------------------------------------
create table txn.machine_shutdown (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  machine_id uuid not null references master.machine (id) on delete restrict,
  production_line_id uuid null references master.production_line (id) on delete restrict,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status_code text not null default 'scheduled',
  reason_code_id uuid null references master.reason_code (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_machine_shutdown_version_positive check (version >= 1),
  constraint ck_shutdown_time_order check (end_at > start_at)
);

create index ix_shutdown_machine_time
  on txn.machine_shutdown (machine_id, start_at, end_at)
  where deleted_at is null;

create index ix_shutdown_plant_time
  on txn.machine_shutdown (plant_id, start_at)
  where deleted_at is null;

create index ix_shutdown_status
  on txn.machine_shutdown (status_code)
  where deleted_at is null;

create trigger trg_machine_shutdown_set_updated_at
  before update on txn.machine_shutdown
  for each row execute function master.set_updated_at();

comment on table txn.machine_shutdown is 'Machine unavailability blocks for Calendar Engine';

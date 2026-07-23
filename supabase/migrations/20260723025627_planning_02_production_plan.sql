-- Module: PLANNING
-- txn.production_plan (header) + txn.production_plan_item (detail / drag-drop unit)

create table txn.production_plan (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  plan_no text not null,
  horizon_type text not null default 'weekly',
  period_start date not null,
  period_end date not null,
  status_code text not null default 'draft',
  title text null,
  lease_owner_id uuid null references master.user_profile (id) on delete restrict,
  lease_expires_at timestamptz null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_production_plan_version_positive check (version >= 1),
  constraint ck_production_plan_horizon check (horizon_type in ('daily', 'weekly', 'monthly')),
  constraint ck_production_plan_period check (period_end >= period_start)
);

create unique index uq_production_plan_plan_no_active
  on txn.production_plan (plan_no)
  where deleted_at is null;

create index ix_plan_plant_period_active
  on txn.production_plan (plant_id, period_start, period_end)
  where deleted_at is null;

create index ix_plan_status_active
  on txn.production_plan (status_code)
  where deleted_at is null;

create trigger trg_production_plan_set_updated_at
  before update on txn.production_plan
  for each row execute function master.set_updated_at();

create table txn.production_plan_item (
  id uuid primary key default gen_random_uuid(),
  production_plan_id uuid not null references txn.production_plan (id) on delete restrict,
  sales_order_line_id uuid null references txn.sales_order_line (id) on delete restrict,
  part_id uuid not null references master.part (id) on delete restrict,
  production_line_id uuid not null references master.production_line (id) on delete restrict,
  machine_id uuid null references master.machine (id) on delete restrict,
  shift_id uuid null references master.shift (id) on delete restrict,
  planned_date date not null,
  planned_start_at timestamptz not null,
  planned_end_at timestamptz not null,
  qty numeric(18, 6) not null default 0,
  status_code text not null default 'planned',
  sort_order integer not null default 0,
  remark text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_production_plan_item_version_positive check (version >= 1),
  constraint ck_plan_item_time_order check (planned_end_at > planned_start_at),
  constraint ck_plan_item_qty check (qty >= 0)
);

create index ix_plan_item_plan_active
  on txn.production_plan_item (production_plan_id)
  where deleted_at is null;

create index ix_plan_item_line_start_active
  on txn.production_plan_item (production_line_id, planned_start_at)
  where deleted_at is null;

create index ix_plan_item_machine_start_active
  on txn.production_plan_item (machine_id, planned_start_at)
  where deleted_at is null and machine_id is not null;

create index ix_plan_item_date_active
  on txn.production_plan_item (planned_date)
  where deleted_at is null;

create index ix_plan_item_part_active
  on txn.production_plan_item (part_id)
  where deleted_at is null;

create trigger trg_production_plan_item_set_updated_at
  before update on txn.production_plan_item
  for each row execute function master.set_updated_at();

comment on table txn.production_plan is 'Planning Header — daily/weekly/monthly plan document';
comment on table txn.production_plan_item is 'Planning Detail — scheduled job (calendar drag-drop unit)';

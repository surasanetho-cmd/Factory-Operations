-- Module: PLANNING
-- history.production_plan_history + history.production_plan_item_history (pattern H)

create table history.production_plan_history (
  id uuid primary key default gen_random_uuid(),
  production_plan_id uuid not null references txn.production_plan (id) on delete restrict,
  version integer not null,
  change_type text not null,
  before_json jsonb null,
  after_json jsonb null,
  changed_fields text[] null,
  changed_at timestamptz not null default now(),
  changed_by uuid null references master.user_profile (id) on delete restrict
);

create index ix_plan_history_plan_changed
  on history.production_plan_history (production_plan_id, changed_at desc);

create table history.production_plan_item_history (
  id uuid primary key default gen_random_uuid(),
  production_plan_item_id uuid not null references txn.production_plan_item (id) on delete restrict,
  version integer not null,
  change_type text not null,
  before_json jsonb null,
  after_json jsonb null,
  changed_fields text[] null,
  changed_at timestamptz not null default now(),
  changed_by uuid null references master.user_profile (id) on delete restrict
);

create index ix_plan_item_history_item_changed
  on history.production_plan_item_history (production_plan_item_id, changed_at desc);

comment on table history.production_plan_history is 'Immutable history for production_plan header changes';
comment on table history.production_plan_item_history is 'Immutable history for plan item moves/edits';

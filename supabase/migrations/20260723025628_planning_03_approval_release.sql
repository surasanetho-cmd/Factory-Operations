-- Module: PLANNING
-- Approve / Release / Amendment events

-- Pattern E: Audit* + acted_at / acted_by
create table txn.plan_approval (
  id uuid primary key default gen_random_uuid(),
  production_plan_id uuid not null references txn.production_plan (id) on delete restrict,
  action text not null,
  comment text null,
  acted_by uuid not null references master.user_profile (id) on delete restrict,
  acted_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_plan_approval_version_positive check (version >= 1),
  constraint ck_plan_approval_action check (action in ('submit', 'approve', 'reject'))
);

create index ix_plan_approval_plan
  on txn.plan_approval (production_plan_id, acted_at desc);

create trigger trg_plan_approval_set_updated_at
  before update on txn.plan_approval
  for each row execute function master.set_updated_at();

-- Pattern E: Audit* + released_at / released_by
create table txn.plan_release (
  id uuid primary key default gen_random_uuid(),
  production_plan_id uuid not null references txn.production_plan (id) on delete restrict,
  released_by uuid not null references master.user_profile (id) on delete restrict,
  released_at timestamptz not null default now(),
  effective_from timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_plan_release_version_positive check (version >= 1)
);

create index ix_plan_release_plan
  on txn.plan_release (production_plan_id, released_at desc);

create trigger trg_plan_release_set_updated_at
  before update on txn.plan_release
  for each row execute function master.set_updated_at();

create table txn.plan_amendment (
  id uuid primary key default gen_random_uuid(),
  production_plan_id uuid not null references txn.production_plan (id) on delete restrict,
  amendment_no text not null,
  reason_code_id uuid null references master.reason_code (id) on delete restrict,
  status_code text not null default 'draft',
  summary text not null,
  payload_json jsonb null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_plan_amendment_version_positive check (version >= 1)
);

create unique index uq_plan_amendment_no_active
  on txn.plan_amendment (amendment_no)
  where deleted_at is null;

create index ix_plan_amendment_plan
  on txn.plan_amendment (production_plan_id)
  where deleted_at is null;

create trigger trg_plan_amendment_set_updated_at
  before update on txn.plan_amendment
  for each row execute function master.set_updated_at();

comment on table txn.plan_approval is 'Submit / approve / reject workflow events';
comment on table txn.plan_release is 'Release events to Production';
comment on table txn.plan_amendment is 'Post-release controlled amendments';

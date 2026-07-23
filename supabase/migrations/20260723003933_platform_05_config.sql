-- Module: PLATFORM
-- Configuration schema tables

create table config.system_setting (
  id uuid primary key default gen_random_uuid(),
  key text not null,
  value_json jsonb not null default '{}'::jsonb,
  module text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_system_setting_version_positive check (version >= 1)
);

create unique index uq_system_setting_key_active
  on config.system_setting (key)
  where deleted_at is null;

create trigger trg_system_setting_set_updated_at
  before update on config.system_setting
  for each row execute function master.set_updated_at();

create table config.feature_flag (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  is_enabled boolean not null default false,
  payload_json jsonb null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_feature_flag_version_positive check (version >= 1)
);

create unique index uq_feature_flag_code_active
  on config.feature_flag (code)
  where deleted_at is null;

create trigger trg_feature_flag_set_updated_at
  before update on config.feature_flag
  for each row execute function master.set_updated_at();

create table config.user_preference (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references master.user_profile (id) on delete restrict,
  key text not null,
  value_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_user_preference_version_positive check (version >= 1)
);

create unique index uq_user_preference_user_key_active
  on config.user_preference (user_id, key)
  where deleted_at is null;

create index ix_user_preference_user_id on config.user_preference (user_id);

create trigger trg_user_preference_set_updated_at
  before update on config.user_preference
  for each row execute function master.set_updated_at();

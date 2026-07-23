-- Module: PLATFORM
-- Lookup masters: uom, status_code, reason_code, file_type, notification_template, number_sequence

-- ---------------------------------------------------------------------------
-- UoM
-- ---------------------------------------------------------------------------
create table master.uom (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name text not null,
  dimension text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_uom_version_positive check (version >= 1),
  constraint ck_uom_dimension check (dimension in ('count', 'mass', 'length', 'time', 'volume', 'other'))
);

create unique index uq_uom_code_active
  on master.uom (code)
  where deleted_at is null;

create trigger trg_uom_set_updated_at
  before update on master.uom
  for each row execute function master.set_updated_at();

create table master.uom_conversion (
  id uuid primary key default gen_random_uuid(),
  from_uom_id uuid not null references master.uom (id) on delete restrict,
  to_uom_id uuid not null references master.uom (id) on delete restrict,
  factor numeric(18, 8) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_uom_conversion_version_positive check (version >= 1),
  constraint ck_uom_conversion_factor check (factor > 0),
  constraint ck_uom_conversion_not_same check (from_uom_id <> to_uom_id)
);

create unique index uq_uom_conversion_pair_active
  on master.uom_conversion (from_uom_id, to_uom_id)
  where deleted_at is null;

create trigger trg_uom_conversion_set_updated_at
  before update on master.uom_conversion
  for each row execute function master.set_updated_at();

-- ---------------------------------------------------------------------------
-- status_code
-- ---------------------------------------------------------------------------
create table master.status_code (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  code text not null,
  name text not null,
  sort_order integer not null default 0,
  is_terminal boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_status_code_version_positive check (version >= 1)
);

create unique index uq_status_code_entity_code_active
  on master.status_code (entity_type, code)
  where deleted_at is null;

create index ix_status_code_entity_type on master.status_code (entity_type);

create trigger trg_status_code_set_updated_at
  before update on master.status_code
  for each row execute function master.set_updated_at();

-- ---------------------------------------------------------------------------
-- reason_code
-- ---------------------------------------------------------------------------
create table master.reason_code (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid null references master.plant (id) on delete restrict,
  code text not null,
  category text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_reason_code_version_positive check (version >= 1)
);

create unique index uq_reason_code_active
  on master.reason_code (coalesce(plant_id, '00000000-0000-0000-0000-000000000000'::uuid), code)
  where deleted_at is null;

create trigger trg_reason_code_set_updated_at
  before update on master.reason_code
  for each row execute function master.set_updated_at();

-- ---------------------------------------------------------------------------
-- file_type
-- ---------------------------------------------------------------------------
create table master.file_type (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  mime_pattern text not null,
  max_size_mb numeric(8, 2) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_file_type_version_positive check (version >= 1),
  constraint ck_file_type_max_size check (max_size_mb > 0)
);

create unique index uq_file_type_code_active
  on master.file_type (code)
  where deleted_at is null;

create trigger trg_file_type_set_updated_at
  before update on master.file_type
  for each row execute function master.set_updated_at();

-- ---------------------------------------------------------------------------
-- notification_template
-- ---------------------------------------------------------------------------
create table master.notification_template (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  channel text not null,
  subject text null,
  body text not null,
  locale text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_notification_template_version_positive check (version >= 1)
);

create unique index uq_notification_template_active
  on master.notification_template (code, channel, locale)
  where deleted_at is null;

create trigger trg_notification_template_set_updated_at
  before update on master.notification_template
  for each row execute function master.set_updated_at();

-- ---------------------------------------------------------------------------
-- number_sequence
-- ---------------------------------------------------------------------------
create table master.number_sequence (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  doc_type text not null,
  prefix text not null,
  next_value bigint not null default 1,
  pad_length integer not null default 5,
  reset_rule text not null default 'yearly',
  last_reset_at timestamptz null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_number_sequence_version_positive check (version >= 1),
  constraint ck_number_sequence_next_value check (next_value >= 1),
  constraint ck_number_sequence_pad_length check (pad_length >= 1 and pad_length <= 12),
  constraint ck_number_sequence_reset_rule check (reset_rule in ('never', 'yearly', 'monthly'))
);

create unique index uq_number_sequence_plant_doc_active
  on master.number_sequence (plant_id, doc_type)
  where deleted_at is null;

create trigger trg_number_sequence_set_updated_at
  before update on master.number_sequence
  for each row execute function master.set_updated_at();

-- Allocate next document number (row lock)
create or replace function master.next_document_no(
  p_plant_id uuid,
  p_doc_type text
)
returns text
language plpgsql
security definer
set search_path = master, public
as $$
declare
  v_seq master.number_sequence%rowtype;
  v_plant_code text;
  v_year text := to_char(now() at time zone 'UTC', 'YYYY');
  v_num text;
begin
  select * into v_seq
  from master.number_sequence
  where plant_id = p_plant_id
    and doc_type = p_doc_type
    and deleted_at is null
  for update;

  if not found then
    raise exception 'NUMBER_ALLOCATION_FAILED: sequence missing for % / %', p_plant_id, p_doc_type
      using errcode = 'P0001';
  end if;

  -- yearly reset
  if v_seq.reset_rule = 'yearly'
     and (v_seq.last_reset_at is null
          or date_trunc('year', v_seq.last_reset_at) < date_trunc('year', now())) then
    v_seq.next_value := 1;
    v_seq.last_reset_at := now();
  elsif v_seq.reset_rule = 'monthly'
     and (v_seq.last_reset_at is null
          or date_trunc('month', v_seq.last_reset_at) < date_trunc('month', now())) then
    v_seq.next_value := 1;
    v_seq.last_reset_at := now();
  end if;

  select code into v_plant_code
  from master.plant
  where id = p_plant_id
    and deleted_at is null;

  v_num := lpad(v_seq.next_value::text, v_seq.pad_length, '0');

  update master.number_sequence
     set next_value = v_seq.next_value + 1,
         last_reset_at = coalesce(v_seq.last_reset_at, last_reset_at),
         version = version + 1,
         updated_at = now()
   where id = v_seq.id;

  return format('%s-%s-%s%s', v_plant_code, v_seq.prefix, v_year, v_num);
end;
$$;

revoke all on function master.next_document_no(uuid, text) from public;
grant execute on function master.next_document_no(uuid, text) to authenticated, service_role;

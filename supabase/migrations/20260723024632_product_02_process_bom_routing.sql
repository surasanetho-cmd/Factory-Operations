-- Module: PRODUCT
-- master.process, master.part_material (BOM), master.part_process (routing)

-- ---------------------------------------------------------------------------
-- master.process
-- ---------------------------------------------------------------------------
create table master.process (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid null references master.plant (id) on delete restrict,
  code text not null,
  name text not null,
  sequence_hint integer null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_process_version_positive check (version >= 1)
);

create unique index uq_process_plant_code_active
  on master.process (plant_id, code)
  where deleted_at is null;

create index ix_process_plant_id
  on master.process (plant_id)
  where deleted_at is null;

create trigger trg_process_set_updated_at
  before update on master.process
  for each row execute function master.set_updated_at();

comment on table master.process is 'Process catalog for part routing';

-- ---------------------------------------------------------------------------
-- master.part_material — pattern J (BOM)
-- ---------------------------------------------------------------------------
create table master.part_material (
  id uuid primary key default gen_random_uuid(),
  part_id uuid not null references master.part (id) on delete restrict,
  material_id uuid not null references master.material (id) on delete restrict,
  qty_per numeric(18, 6) not null default 0,
  uom_id uuid not null references master.uom (id) on delete restrict,
  sequence integer not null default 1,
  created_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  constraint ck_part_material_qty check (qty_per >= 0),
  constraint ck_part_material_sequence_positive check (sequence >= 1)
);

create unique index uq_part_material_seq_active
  on master.part_material (part_id, material_id, sequence)
  where deleted_at is null;

create index ix_part_material_part_id
  on master.part_material (part_id)
  where deleted_at is null;

create index ix_part_material_material_id
  on master.part_material (material_id)
  where deleted_at is null;

comment on table master.part_material is 'BOM link: part → material with qty_per';

-- ---------------------------------------------------------------------------
-- master.part_process — pattern J (routing)
-- ---------------------------------------------------------------------------
create table master.part_process (
  id uuid primary key default gen_random_uuid(),
  part_id uuid not null references master.part (id) on delete restrict,
  process_id uuid not null references master.process (id) on delete restrict,
  sequence integer not null,
  std_time_sec integer null,
  created_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  constraint ck_part_process_sequence_positive check (sequence >= 1),
  constraint ck_part_process_std_time_nonneg check (std_time_sec is null or std_time_sec >= 0)
);

create unique index uq_part_process_seq_active
  on master.part_process (part_id, sequence)
  where deleted_at is null;

create index ix_part_process_part_id
  on master.part_process (part_id)
  where deleted_at is null;

create index ix_part_process_process_id
  on master.part_process (process_id)
  where deleted_at is null;

comment on table master.part_process is 'Part routing: ordered processes with optional std time';

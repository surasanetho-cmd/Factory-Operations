-- Module: PRODUCT
-- master.customer, master.part, master.material

-- ---------------------------------------------------------------------------
-- master.customer
-- ---------------------------------------------------------------------------
create table master.customer (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid null references master.plant (id) on delete restrict,
  code text not null,
  name text not null,
  contact_json jsonb null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_customer_version_positive check (version >= 1)
);

create unique index uq_customer_plant_code_active
  on master.customer (plant_id, code)
  where deleted_at is null;

create index ix_customer_plant_id
  on master.customer (plant_id)
  where deleted_at is null;

create trigger trg_customer_set_updated_at
  before update on master.customer
  for each row execute function master.set_updated_at();

comment on table master.customer is 'Customer master for orders and parts';

-- ---------------------------------------------------------------------------
-- master.part
-- ---------------------------------------------------------------------------
create table master.part (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  customer_id uuid null references master.customer (id) on delete restrict,
  code text not null,
  name text not null,
  revision text null,
  uom_id uuid not null references master.uom (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_part_version_positive check (version >= 1)
);

create unique index uq_part_plant_code_active
  on master.part (plant_id, code)
  where deleted_at is null;

create index ix_part_customer_id
  on master.part (customer_id)
  where deleted_at is null;

create index ix_part_uom_id
  on master.part (uom_id)
  where deleted_at is null;

create trigger trg_part_set_updated_at
  before update on master.part
  for each row execute function master.set_updated_at();

comment on table master.part is 'Finished / sellable part master for planning and orders';

-- ---------------------------------------------------------------------------
-- master.material
-- ---------------------------------------------------------------------------
create table master.material (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  code text not null,
  name text not null,
  uom_id uuid not null references master.uom (id) on delete restrict,
  spec_json jsonb null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_material_version_positive check (version >= 1)
);

create unique index uq_material_plant_code_active
  on master.material (plant_id, code)
  where deleted_at is null;

create index ix_material_uom_id
  on master.material (uom_id)
  where deleted_at is null;

create trigger trg_material_set_updated_at
  before update on master.material
  for each row execute function master.set_updated_at();

comment on table master.material is 'Raw / component materials for BOM and Store';

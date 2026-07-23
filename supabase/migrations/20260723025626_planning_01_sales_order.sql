-- Module: PLANNING
-- txn.sales_order, txn.sales_order_line (demand)

create table txn.sales_order (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references master.plant (id) on delete restrict,
  order_no text not null,
  customer_id uuid not null references master.customer (id) on delete restrict,
  order_date date not null default (timezone('Asia/Bangkok', now()))::date,
  status_code text not null default 'open',
  remark text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_sales_order_version_positive check (version >= 1)
);

create unique index uq_sales_order_order_no_active
  on txn.sales_order (order_no)
  where deleted_at is null;

create index ix_sales_order_plant_date_active
  on txn.sales_order (plant_id, order_date)
  where deleted_at is null;

create index ix_sales_order_customer_active
  on txn.sales_order (customer_id)
  where deleted_at is null;

create trigger trg_sales_order_set_updated_at
  before update on txn.sales_order
  for each row execute function master.set_updated_at();

create table txn.sales_order_line (
  id uuid primary key default gen_random_uuid(),
  sales_order_id uuid not null references txn.sales_order (id) on delete restrict,
  line_no integer not null,
  part_id uuid not null references master.part (id) on delete restrict,
  qty_ordered numeric(18, 6) not null default 0,
  qty_allocated numeric(18, 6) not null default 0,
  due_date date null,
  status_code text not null default 'open',
  uom_id uuid null references master.uom (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_sales_order_line_version_positive check (version >= 1),
  constraint ck_order_line_qty check (qty_ordered >= 0 and qty_allocated >= 0),
  constraint ck_sales_order_line_no_positive check (line_no >= 1)
);

create unique index uq_sales_order_line_no_active
  on txn.sales_order_line (sales_order_id, line_no)
  where deleted_at is null;

create index ix_sales_order_line_order_active
  on txn.sales_order_line (sales_order_id)
  where deleted_at is null;

create index ix_sales_order_line_part_active
  on txn.sales_order_line (part_id)
  where deleted_at is null;

create trigger trg_sales_order_line_set_updated_at
  before update on txn.sales_order_line
  for each row execute function master.set_updated_at();

comment on table txn.sales_order is 'Planning Header demand — customer order';
comment on table txn.sales_order_line is 'Sales order lines for allocation into plan items';

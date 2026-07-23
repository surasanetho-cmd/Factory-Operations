-- Module: PLANNING
-- Seed demo sales order + weekly plan with items on lines

insert into txn.sales_order (plant_id, order_no, customer_id, order_date, status_code, remark)
select p.id, 'SO-2026-0001', c.id, date '2026-07-20', 'open', 'Demo demand for planning board'
from master.plant p
join master.customer c on c.plant_id = p.id and c.code = 'CUST-DEMO' and c.deleted_at is null
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from txn.sales_order so where so.order_no = 'SO-2026-0001' and so.deleted_at is null
  );

insert into txn.sales_order_line (sales_order_id, line_no, part_id, qty_ordered, qty_allocated, due_date, status_code, uom_id)
select so.id, v.line_no, pt.id, v.qty, 0, date '2026-07-27', 'open', pt.uom_id
from (values
  (1, 'PART-001', 100::numeric),
  (2, 'PART-002', 80::numeric)
) as v(line_no, part_code, qty)
join txn.sales_order so on so.order_no = 'SO-2026-0001' and so.deleted_at is null
join master.plant p on p.id = so.plant_id and p.code = 'SF1'
join master.part pt on pt.plant_id = p.id and pt.code = v.part_code and pt.deleted_at is null
where not exists (
  select 1 from txn.sales_order_line sol
  where sol.sales_order_id = so.id and sol.line_no = v.line_no and sol.deleted_at is null
);

insert into txn.production_plan (
  plant_id, plan_no, horizon_type, period_start, period_end, status_code, title
)
select
  p.id,
  'PP-2026-W30',
  'weekly',
  date '2026-07-20',
  date '2026-07-26',
  'draft',
  'Week 30 demo plan'
from master.plant p
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from txn.production_plan pp where pp.plan_no = 'PP-2026-W30' and pp.deleted_at is null
  );

insert into txn.production_plan_item (
  production_plan_id,
  sales_order_line_id,
  part_id,
  production_line_id,
  machine_id,
  shift_id,
  planned_date,
  planned_start_at,
  planned_end_at,
  qty,
  status_code,
  sort_order
)
select
  pp.id,
  sol.id,
  pt.id,
  pl.id,
  m.id,
  s.id,
  v.planned_date::date,
  (v.planned_date || ' ' || v.start_t || '+07')::timestamptz,
  (v.planned_date || ' ' || v.end_t || '+07')::timestamptz,
  v.qty,
  'planned',
  v.sort_order
from (values
  (1, 'PL-110T', '2026-07-21', '08:00', '10:00', 20::numeric, 10),
  (1, 'PL-110T', '2026-07-22', '08:00', '11:00', 25::numeric, 20),
  (2, 'PL-250T', '2026-07-21', '09:00', '12:00', 15::numeric, 30),
  (2, 'PL-300T', '2026-07-23', '08:00', '10:30', 18::numeric, 40),
  (1, 'PL-600T', '2026-07-24', '08:00', '09:30', 12::numeric, 50)
) as v(line_no, line_code, planned_date, start_t, end_t, qty, sort_order)
join txn.production_plan pp on pp.plan_no = 'PP-2026-W30' and pp.deleted_at is null
join master.plant p on p.id = pp.plant_id and p.code = 'SF1'
join txn.sales_order so on so.plant_id = p.id and so.order_no = 'SO-2026-0001' and so.deleted_at is null
join txn.sales_order_line sol on sol.sales_order_id = so.id and sol.line_no = v.line_no and sol.deleted_at is null
join master.part pt on pt.id = sol.part_id
join master.production_line pl on pl.plant_id = p.id and pl.code = v.line_code and pl.deleted_at is null
join master.machine m on m.production_line_id = pl.id and m.code = pl.code || '-01' and m.deleted_at is null
join master.shift s on s.plant_id = p.id and s.code = 'DAY' and s.deleted_at is null
where not exists (
  select 1 from txn.production_plan_item i
  where i.production_plan_id = pp.id
    and i.sort_order = v.sort_order
    and i.deleted_at is null
);

update txn.sales_order_line sol
set qty_allocated = least(sol.qty_ordered, coalesce((
  select sum(i.qty) from txn.production_plan_item i
  where i.sales_order_line_id = sol.id and i.deleted_at is null
), 0)),
    status_code = 'partial',
    version = sol.version + 1
from txn.sales_order so
where sol.sales_order_id = so.id
  and so.order_no = 'SO-2026-0001'
  and sol.deleted_at is null;

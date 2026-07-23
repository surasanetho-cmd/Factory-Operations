-- Module: PLANNING
-- Views + RLS

create or replace view txn.v_production_plan_active
with (security_invoker = true)
as
select
  id, plant_id, plan_no, horizon_type, period_start, period_end,
  status_code, title, lease_owner_id, lease_expires_at,
  created_at, updated_at, version
from txn.production_plan
where deleted_at is null and is_active = true;

create or replace view txn.v_production_plan_item_active
with (security_invoker = true)
as
select
  id, production_plan_id, sales_order_line_id, part_id,
  production_line_id, machine_id, shift_id,
  planned_date, planned_start_at, planned_end_at,
  qty, status_code, sort_order, remark,
  created_at, updated_at, version
from txn.production_plan_item
where deleted_at is null and is_active = true;

grant select on txn.v_production_plan_active to authenticated, service_role;
grant select on txn.v_production_plan_item_active to authenticated, service_role;

alter table txn.sales_order enable row level security;
alter table txn.sales_order_line enable row level security;
alter table txn.production_plan enable row level security;
alter table txn.production_plan_item enable row level security;
alter table txn.plan_approval enable row level security;
alter table txn.plan_release enable row level security;
alter table txn.plan_amendment enable row level security;
alter table history.production_plan_history enable row level security;
alter table history.production_plan_item_history enable row level security;

-- Select policies
create policy sales_order_select on txn.sales_order
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids())
    and authz.has_permission('plan.production_plan.read'));

create policy sales_order_line_select on txn.sales_order_line
  for select to authenticated
  using (
    deleted_at is null
    and sales_order_id in (
      select so.id from txn.sales_order so
      where so.deleted_at is null and so.plant_id in (select authz.user_plant_ids())
    )
    and authz.has_permission('plan.production_plan.read')
  );

create policy production_plan_select on txn.production_plan
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids())
    and authz.has_permission('plan.production_plan.read'));

create policy production_plan_item_select on txn.production_plan_item
  for select to authenticated
  using (
    deleted_at is null
    and production_plan_id in (
      select pp.id from txn.production_plan pp
      where pp.deleted_at is null and pp.plant_id in (select authz.user_plant_ids())
    )
    and authz.has_permission('plan.production_plan.read')
  );

create policy plan_approval_select on txn.plan_approval
  for select to authenticated
  using (
    deleted_at is null
    and production_plan_id in (
      select pp.id from txn.production_plan pp
      where pp.deleted_at is null and pp.plant_id in (select authz.user_plant_ids())
    )
    and authz.has_permission('plan.production_plan.read')
  );

create policy plan_release_select on txn.plan_release
  for select to authenticated
  using (
    deleted_at is null
    and production_plan_id in (
      select pp.id from txn.production_plan pp
      where pp.deleted_at is null and pp.plant_id in (select authz.user_plant_ids())
    )
    and authz.has_permission('plan.production_plan.read')
  );

create policy plan_amendment_select on txn.plan_amendment
  for select to authenticated
  using (
    deleted_at is null
    and production_plan_id in (
      select pp.id from txn.production_plan pp
      where pp.deleted_at is null and pp.plant_id in (select authz.user_plant_ids())
    )
    and authz.has_permission('plan.production_plan.read')
  );

create policy plan_history_select on history.production_plan_history
  for select to authenticated
  using (authz.has_permission('plan.production_plan.read'));

create policy plan_item_history_select on history.production_plan_item_history
  for select to authenticated
  using (authz.has_permission('plan.production_plan.read'));

-- Write policies (create/update)
create policy production_plan_insert on txn.production_plan
  for insert to authenticated
  with check (
    plant_id in (select authz.user_plant_ids())
    and authz.has_permission('plan.production_plan.create')
  );

create policy production_plan_update on txn.production_plan
  for update to authenticated
  using (
    plant_id in (select authz.user_plant_ids())
    and authz.has_permission('plan.production_plan.update')
  )
  with check (
    plant_id in (select authz.user_plant_ids())
    and authz.has_permission('plan.production_plan.update')
  );

create policy production_plan_item_write on txn.production_plan_item
  for all to authenticated
  using (authz.has_permission('plan.production_plan.update'))
  with check (authz.has_permission('plan.production_plan.update'));

create policy sales_order_write on txn.sales_order
  for all to authenticated
  using (authz.has_permission('plan.production_plan.create'))
  with check (authz.has_permission('plan.production_plan.create'));

create policy sales_order_line_write on txn.sales_order_line
  for all to authenticated
  using (authz.has_permission('plan.production_plan.create'))
  with check (authz.has_permission('plan.production_plan.create'));

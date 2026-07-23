-- Module: PRODUCT
-- RLS for customer / part / material / process / junctions

alter table master.customer enable row level security;
alter table master.part enable row level security;
alter table master.material enable row level security;
alter table master.process enable row level security;
alter table master.part_material enable row level security;
alter table master.part_process enable row level security;

-- Select
create policy customer_select_authenticated on master.customer
  for select to authenticated
  using (
    deleted_at is null
    and (plant_id is null or plant_id in (select authz.user_plant_ids()))
  );

create policy part_select_authenticated on master.part
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy material_select_authenticated on master.material
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy process_select_authenticated on master.process
  for select to authenticated
  using (
    deleted_at is null
    and (plant_id is null or plant_id in (select authz.user_plant_ids()))
  );

create policy part_material_select_authenticated on master.part_material
  for select to authenticated
  using (
    deleted_at is null
    and part_id in (
      select p.id from master.part p
      where p.deleted_at is null
        and p.plant_id in (select authz.user_plant_ids())
    )
  );

create policy part_process_select_authenticated on master.part_process
  for select to authenticated
  using (
    deleted_at is null
    and part_id in (
      select p.id from master.part p
      where p.deleted_at is null
        and p.plant_id in (select authz.user_plant_ids())
    )
  );

-- Manage
create policy customer_manage on master.customer
  for all to authenticated
  using (authz.has_permission('master.customer.manage'))
  with check (authz.has_permission('master.customer.manage'));

create policy part_manage on master.part
  for all to authenticated
  using (authz.has_permission('master.part.manage'))
  with check (authz.has_permission('master.part.manage'));

create policy material_manage on master.material
  for all to authenticated
  using (authz.has_permission('master.material.manage'))
  with check (authz.has_permission('master.material.manage'));

create policy process_manage on master.process
  for all to authenticated
  using (authz.has_permission('master.process.manage'))
  with check (authz.has_permission('master.process.manage'));

create policy part_material_manage on master.part_material
  for all to authenticated
  using (authz.has_permission('master.part.manage'))
  with check (authz.has_permission('master.part.manage'));

create policy part_process_manage on master.part_process
  for all to authenticated
  using (authz.has_permission('master.part.manage'))
  with check (authz.has_permission('master.part.manage'));

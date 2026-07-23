-- Module: PRODUCT
-- Active convenience views

create or replace view master.v_customer_active
with (security_invoker = true)
as
select id, plant_id, code, name, contact_json, created_at, updated_at, version
from master.customer
where deleted_at is null
  and is_active = true;

create or replace view master.v_part_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  customer_id,
  code,
  name,
  revision,
  uom_id,
  created_at,
  updated_at,
  version
from master.part
where deleted_at is null
  and is_active = true;

create or replace view master.v_material_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  code,
  name,
  uom_id,
  spec_json,
  created_at,
  updated_at,
  version
from master.material
where deleted_at is null
  and is_active = true;

create or replace view master.v_process_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  code,
  name,
  sequence_hint,
  created_at,
  updated_at,
  version
from master.process
where deleted_at is null
  and is_active = true;

create or replace view master.v_part_bom_active
with (security_invoker = true)
as
select
  pm.id,
  pm.part_id,
  p.code as part_code,
  pm.material_id,
  m.code as material_code,
  pm.qty_per,
  pm.uom_id,
  pm.sequence
from master.part_material pm
join master.part p on p.id = pm.part_id and p.deleted_at is null
join master.material m on m.id = pm.material_id and m.deleted_at is null
where pm.deleted_at is null
  and pm.is_active = true;

create or replace view master.v_part_routing_active
with (security_invoker = true)
as
select
  pp.id,
  pp.part_id,
  p.code as part_code,
  pp.process_id,
  pr.code as process_code,
  pr.name as process_name,
  pp.sequence,
  pp.std_time_sec
from master.part_process pp
join master.part p on p.id = pp.part_id and p.deleted_at is null
join master.process pr on pr.id = pp.process_id and pr.deleted_at is null
where pp.deleted_at is null
  and pp.is_active = true;

grant select on master.v_customer_active to authenticated, service_role;
grant select on master.v_part_active to authenticated, service_role;
grant select on master.v_material_active to authenticated, service_role;
grant select on master.v_process_active to authenticated, service_role;
grant select on master.v_part_bom_active to authenticated, service_role;
grant select on master.v_part_routing_active to authenticated, service_role;

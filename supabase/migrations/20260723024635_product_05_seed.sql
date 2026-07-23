-- Module: PRODUCT
-- Seed: permissions, customers, parts, materials, processes, BOM, routing

-- ---------------------------------------------------------------------------
-- Permissions
-- ---------------------------------------------------------------------------
insert into master.permission (code, module, action, resource, description)
select v.code, v.module, v.action, v.resource, v.description
from (values
  ('master.customer.manage', 'master', 'manage', 'customer', 'Manage customers'),
  ('master.part.manage', 'master', 'manage', 'part', 'Manage parts, BOM, routing'),
  ('master.material.manage', 'master', 'manage', 'material', 'Manage materials'),
  ('master.process.manage', 'master', 'manage', 'process', 'Manage processes')
) as v(code, module, action, resource, description)
where not exists (
  select 1 from master.permission p where p.code = v.code and p.deleted_at is null
);

insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
cross join master.permission p
where r.code = 'admin'
  and r.deleted_at is null
  and p.deleted_at is null
  and p.code in (
    'master.customer.manage',
    'master.part.manage',
    'master.material.manage',
    'master.process.manage'
  )
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
join master.permission p on p.code in (
  'master.customer.manage',
  'master.part.manage',
  'master.material.manage',
  'master.process.manage'
)
where r.code = 'planner'
  and r.deleted_at is null
  and p.deleted_at is null
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Customer
-- ---------------------------------------------------------------------------
insert into master.customer (plant_id, code, name, contact_json)
select p.id, 'CUST-DEMO', 'Demo Customer', '{"channel":"email"}'::jsonb
from master.plant p
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.customer c
    where c.plant_id = p.id and c.code = 'CUST-DEMO' and c.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Materials
-- ---------------------------------------------------------------------------
insert into master.material (plant_id, code, name, uom_id, spec_json)
select p.id, v.code, v.name, u.id, v.spec_json::jsonb
from master.plant p
cross join (values
  ('MAT-STEEL', 'Steel blank', 'KG', '{"grade":"SPCC"}'),
  ('MAT-RESIN', 'Resin pellet', 'KG', '{"type":"ABS"}')
) as v(code, name, uom_code, spec_json)
join master.uom u on u.code = v.uom_code and u.deleted_at is null
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.material m
    where m.plant_id = p.id and m.code = v.code and m.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Processes
-- ---------------------------------------------------------------------------
insert into master.process (plant_id, code, name, sequence_hint)
select p.id, v.code, v.name, v.sequence_hint
from master.plant p
cross join (values
  ('PRESS', 'Press forming', 10),
  ('DEBURR', 'Deburr', 20),
  ('INSPECT', 'Final inspect', 30)
) as v(code, name, sequence_hint)
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.process pr
    where pr.plant_id = p.id and pr.code = v.code and pr.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Parts
-- ---------------------------------------------------------------------------
insert into master.part (plant_id, customer_id, code, name, revision, uom_id)
select
  p.id,
  c.id,
  v.code,
  v.name,
  v.revision,
  u.id
from master.plant p
join master.customer c
  on c.plant_id = p.id and c.code = 'CUST-DEMO' and c.deleted_at is null
join master.uom u on u.code = 'EA' and u.deleted_at is null
cross join (values
  ('PART-001', 'Demo Bracket A', 'A'),
  ('PART-002', 'Demo Cover B', 'A')
) as v(code, name, revision)
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.part pt
    where pt.plant_id = p.id and pt.code = v.code and pt.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- BOM (part_material)
-- ---------------------------------------------------------------------------
insert into master.part_material (part_id, material_id, qty_per, uom_id, sequence)
select pt.id, m.id, v.qty_per, u.id, v.sequence
from (values
  ('PART-001', 'MAT-STEEL', 0.450::numeric, 1),
  ('PART-002', 'MAT-RESIN', 0.120::numeric, 1)
) as v(part_code, material_code, qty_per, sequence)
join master.part pt on pt.code = v.part_code and pt.deleted_at is null
join master.plant p on p.id = pt.plant_id and p.code = 'SF1'
join master.material m
  on m.plant_id = p.id and m.code = v.material_code and m.deleted_at is null
join master.uom u on u.code = 'KG' and u.deleted_at is null
where not exists (
  select 1 from master.part_material pm
  where pm.part_id = pt.id
    and pm.material_id = m.id
    and pm.sequence = v.sequence
    and pm.deleted_at is null
);

-- ---------------------------------------------------------------------------
-- Routing (part_process)
-- ---------------------------------------------------------------------------
insert into master.part_process (part_id, process_id, sequence, std_time_sec)
select pt.id, pr.id, v.sequence, v.std_time_sec
from (values
  ('PART-001', 'PRESS', 10, 120),
  ('PART-001', 'DEBURR', 20, 60),
  ('PART-001', 'INSPECT', 30, 30),
  ('PART-002', 'PRESS', 10, 90),
  ('PART-002', 'INSPECT', 20, 30)
) as v(part_code, process_code, sequence, std_time_sec)
join master.part pt on pt.code = v.part_code and pt.deleted_at is null
join master.plant p on p.id = pt.plant_id and p.code = 'SF1'
join master.process pr
  on pr.plant_id = p.id and pr.code = v.process_code and pr.deleted_at is null
where not exists (
  select 1 from master.part_process pp
  where pp.part_id = pt.id
    and pp.sequence = v.sequence
    and pp.deleted_at is null
);

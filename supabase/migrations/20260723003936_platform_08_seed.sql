-- Module: PLATFORM
-- Seed data (idempotent where practical)
-- Note: user_profile rows that reference auth.users are created by app signup trigger later.
-- This seed creates plant, roles, permissions, lookups, sequences, flags.

-- ---------------------------------------------------------------------------
-- Plant SF1
-- ---------------------------------------------------------------------------
insert into master.plant (code, name, timezone)
select 'SF1', 'Smart-Factory Plant 1', 'Asia/Bangkok'
where not exists (
  select 1 from master.plant where code = 'SF1' and deleted_at is null
);

-- ---------------------------------------------------------------------------
-- Department
-- ---------------------------------------------------------------------------
insert into master.department (plant_id, code, name)
select p.id, 'PLANNING', 'Planning'
from master.plant p
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.department d
    where d.plant_id = p.id and d.code = 'PLANNING' and d.deleted_at is null
  );

insert into master.department (plant_id, code, name)
select p.id, 'PRODUCTION', 'Production'
from master.plant p
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.department d
    where d.plant_id = p.id and d.code = 'PRODUCTION' and d.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Roles
-- ---------------------------------------------------------------------------
insert into master.role (code, name, description)
select v.code, v.name, v.description
from (values
  ('admin', 'Administrator', 'Full platform configuration'),
  ('planner', 'Planner', 'Create/edit plans and submit'),
  ('supervisor', 'Supervisor', 'Approve/reject/release plans'),
  ('viewer', 'Viewer', 'Read-only planning and dashboards'),
  ('operator', 'Operator', 'Future production execution')
) as v(code, name, description)
where not exists (
  select 1 from master.role r where r.code = v.code and r.deleted_at is null
);

-- ---------------------------------------------------------------------------
-- Permissions (Phase 1 baseline)
-- ---------------------------------------------------------------------------
insert into master.permission (code, module, action, resource, description)
select v.code, v.module, v.action, v.resource, v.description
from (values
  ('master.plant.manage', 'master', 'manage', 'plant', 'Manage plants'),
  ('master.role.manage', 'master', 'manage', 'role', 'Manage roles'),
  ('master.permission.manage', 'master', 'manage', 'permission', 'Manage permissions'),
  ('master.user.manage', 'master', 'manage', 'user', 'Manage users'),
  ('master.configure', 'master', 'configure', 'system', 'Manage system settings'),
  ('master.number_sequence.manage', 'master', 'manage', 'number_sequence', 'Manage number sequences'),
  ('master.machine.manage', 'master', 'manage', 'machine', 'Manage machines'),
  ('plan.production_plan.read', 'plan', 'read', 'production_plan', 'Read plans'),
  ('plan.production_plan.create', 'plan', 'create', 'production_plan', 'Create plans'),
  ('plan.production_plan.update', 'plan', 'update', 'production_plan', 'Update plans'),
  ('plan.production_plan.delete', 'plan', 'delete', 'production_plan', 'Soft delete plans'),
  ('plan.production_plan.approve', 'plan', 'approve', 'production_plan', 'Approve plans'),
  ('plan.production_plan.reject', 'plan', 'reject', 'production_plan', 'Reject plans'),
  ('plan.production_plan.release', 'plan', 'release', 'production_plan', 'Release plans'),
  ('dashboard.layout.manage_own', 'dashboard', 'manage', 'layout', 'Manage own dashboard layout')
) as v(code, module, action, resource, description)
where not exists (
  select 1 from master.permission p where p.code = v.code and p.deleted_at is null
);

-- ---------------------------------------------------------------------------
-- Role → permission matrix
-- ---------------------------------------------------------------------------
-- admin: all permissions
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
cross join master.permission p
where r.code = 'admin'
  and r.deleted_at is null
  and p.deleted_at is null
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- planner
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
join master.permission p on p.code in (
  'plan.production_plan.read',
  'plan.production_plan.create',
  'plan.production_plan.update',
  'plan.production_plan.delete',
  'dashboard.layout.manage_own'
)
where r.code = 'planner'
  and r.deleted_at is null
  and p.deleted_at is null
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- supervisor
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
join master.permission p on p.code in (
  'plan.production_plan.read',
  'plan.production_plan.approve',
  'plan.production_plan.reject',
  'plan.production_plan.release',
  'dashboard.layout.manage_own'
)
where r.code = 'supervisor'
  and r.deleted_at is null
  and p.deleted_at is null
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- viewer
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
join master.permission p on p.code in (
  'plan.production_plan.read',
  'dashboard.layout.manage_own'
)
where r.code = 'viewer'
  and r.deleted_at is null
  and p.deleted_at is null
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- UoM + conversions
-- ---------------------------------------------------------------------------
insert into master.uom (code, name, dimension)
select v.code, v.name, v.dimension
from (values
  ('EA', 'Each', 'count'),
  ('KG', 'Kilogram', 'mass'),
  ('G', 'Gram', 'mass'),
  ('M', 'Meter', 'length'),
  ('MIN', 'Minute', 'time'),
  ('H', 'Hour', 'time')
) as v(code, name, dimension)
where not exists (
  select 1 from master.uom u where u.code = v.code and u.deleted_at is null
);

insert into master.uom_conversion (from_uom_id, to_uom_id, factor)
select f.id, t.id, 0.001
from master.uom f
join master.uom t on t.code = 'KG'
where f.code = 'G'
  and f.deleted_at is null
  and t.deleted_at is null
  and not exists (
    select 1 from master.uom_conversion c
    where c.from_uom_id = f.id and c.to_uom_id = t.id and c.deleted_at is null
  );

insert into master.uom_conversion (from_uom_id, to_uom_id, factor)
select f.id, t.id, 1000
from master.uom f
join master.uom t on t.code = 'G'
where f.code = 'KG'
  and f.deleted_at is null
  and t.deleted_at is null
  and not exists (
    select 1 from master.uom_conversion c
    where c.from_uom_id = f.id and c.to_uom_id = t.id and c.deleted_at is null
  );

insert into master.uom_conversion (from_uom_id, to_uom_id, factor)
select f.id, t.id, 60
from master.uom f
join master.uom t on t.code = 'MIN'
where f.code = 'H'
  and f.deleted_at is null
  and t.deleted_at is null
  and not exists (
    select 1 from master.uom_conversion c
    where c.from_uom_id = f.id and c.to_uom_id = t.id and c.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Status codes
-- ---------------------------------------------------------------------------
insert into master.status_code (entity_type, code, name, sort_order, is_terminal)
select v.entity_type, v.code, v.name, v.sort_order, v.is_terminal
from (values
  ('production_plan', 'draft', 'Draft', 10, false),
  ('production_plan', 'submitted', 'Submitted', 20, false),
  ('production_plan', 'approved', 'Approved', 30, false),
  ('production_plan', 'rejected', 'Rejected', 40, false),
  ('production_plan', 'released', 'Released', 50, true),
  ('production_plan', 'cancelled', 'Cancelled', 60, true),
  ('production_plan_item', 'planned', 'Planned', 10, false),
  ('production_plan_item', 'locked', 'Locked', 20, false),
  ('production_plan_item', 'released', 'Released', 30, true),
  ('production_plan_item', 'cancelled', 'Cancelled', 40, true),
  ('production_plan_item', 'amended', 'Amended', 50, false),
  ('sales_order', 'open', 'Open', 10, false),
  ('sales_order', 'partial', 'Partial', 20, false),
  ('sales_order', 'planned', 'Planned', 30, false),
  ('sales_order', 'closed', 'Closed', 40, true),
  ('sales_order', 'cancelled', 'Cancelled', 50, true),
  ('sales_order_line', 'open', 'Open', 10, false),
  ('sales_order_line', 'partial', 'Partial', 20, false),
  ('sales_order_line', 'planned', 'Planned', 30, false),
  ('sales_order_line', 'closed', 'Closed', 40, true),
  ('sales_order_line', 'cancelled', 'Cancelled', 50, true),
  ('plan_amendment', 'draft', 'Draft', 10, false),
  ('plan_amendment', 'approved', 'Approved', 20, true),
  ('plan_amendment', 'cancelled', 'Cancelled', 30, true),
  ('ot_window', 'pending', 'Pending', 10, false),
  ('ot_window', 'approved', 'Approved', 20, true),
  ('ot_window', 'rejected', 'Rejected', 30, true),
  ('machine_shutdown', 'scheduled', 'Scheduled', 10, false),
  ('machine_shutdown', 'active', 'Active', 20, false),
  ('machine_shutdown', 'closed', 'Closed', 30, true),
  ('outbox', 'pending', 'Pending', 10, false),
  ('outbox', 'processing', 'Processing', 20, false),
  ('outbox', 'done', 'Done', 30, true),
  ('outbox', 'error', 'Error', 40, false),
  ('sync_job', 'pending', 'Pending', 10, false),
  ('sync_job', 'running', 'Running', 20, false),
  ('sync_job', 'done', 'Done', 30, true),
  ('sync_job', 'error', 'Error', 40, false)
) as v(entity_type, code, name, sort_order, is_terminal)
where not exists (
  select 1 from master.status_code s
  where s.entity_type = v.entity_type and s.code = v.code and s.deleted_at is null
);

-- ---------------------------------------------------------------------------
-- Reason codes / file types / notification templates
-- ---------------------------------------------------------------------------
insert into master.reason_code (plant_id, code, category, name)
select p.id, v.code, v.category, v.name
from master.plant p
cross join (values
  ('OT_DEMAND', 'ot', 'Overtime for demand peak'),
  ('OT_CATCHUP', 'ot', 'Overtime catch-up'),
  ('SD_BREAKDOWN', 'shutdown', 'Machine breakdown'),
  ('SD_PM', 'shutdown', 'Preventive maintenance'),
  ('AMD_ORDER_CHANGE', 'amendment', 'Customer order change'),
  ('CAP_OVERRIDE', 'capacity', 'Capacity conflict override')
) as v(code, category, name)
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.reason_code r
    where r.code = v.code and r.plant_id = p.id and r.deleted_at is null
  );

insert into master.file_type (code, mime_pattern, max_size_mb)
select v.code, v.mime_pattern, v.max_size_mb
from (values
  ('PDF', 'application/pdf', 20::numeric),
  ('PNG', 'image/png', 10::numeric),
  ('JPEG', 'image/jpeg', 10::numeric),
  ('XLSX', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 25::numeric)
) as v(code, mime_pattern, max_size_mb)
where not exists (
  select 1 from master.file_type f where f.code = v.code and f.deleted_at is null
);

insert into master.notification_template (code, channel, subject, body, locale)
select v.code, v.channel, v.subject, v.body, v.locale
from (values
  ('plan.submitted', 'telegram', null, 'Plan {{plan_no}} submitted by {{actor_name}}.', 'en'),
  ('plan.approved', 'telegram', null, 'Plan {{plan_no}} approved by {{actor_name}}.', 'en'),
  ('plan.rejected', 'telegram', null, 'Plan {{plan_no}} rejected by {{actor_name}}.', 'en'),
  ('plan.released', 'telegram', null, 'Plan {{plan_no}} released by {{actor_name}}.', 'en'),
  ('plan.conflict', 'telegram', null, 'Plan {{plan_no}} has capacity conflicts on {{line_code}}.', 'en')
) as v(code, channel, subject, body, locale)
where not exists (
  select 1 from master.notification_template t
  where t.code = v.code and t.channel = v.channel and t.locale = v.locale and t.deleted_at is null
);

-- ---------------------------------------------------------------------------
-- Number sequences for SF1
-- ---------------------------------------------------------------------------
insert into master.number_sequence (plant_id, doc_type, prefix, next_value, pad_length, reset_rule)
select p.id, v.doc_type, v.prefix, 1, 5, 'yearly'
from master.plant p
cross join (values
  ('sales_order', 'SO'),
  ('production_plan', 'PP'),
  ('plan_amendment', 'PA'),
  ('production_job', 'PJ')
) as v(doc_type, prefix)
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.number_sequence s
    where s.plant_id = p.id and s.doc_type = v.doc_type and s.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Feature flags + system settings
-- ---------------------------------------------------------------------------
insert into config.feature_flag (code, is_enabled, payload_json)
select v.code, v.is_enabled, v.payload_json::jsonb
from (values
  ('plan_lease', false, '{}'),
  ('telegram_notifications', false, '{}'),
  ('calendar_conflict_block_release', true, '{}')
) as v(code, is_enabled, payload_json)
where not exists (
  select 1 from config.feature_flag f where f.code = v.code and f.deleted_at is null
);

insert into config.system_setting (key, value_json, module)
select v.key, v.value_json::jsonb, v.module
from (values
  ('log.retention_days', '{"days": 90}', 'log'),
  ('outbox.retention_days', '{"days": 30}', 'integration'),
  ('idempotency.ttl_hours', '{"hours": 24}', 'integration'),
  ('planning.default_horizon', '{"type": "weekly"}', 'plan')
) as v(key, value_json, module)
where not exists (
  select 1 from config.system_setting s where s.key = v.key and s.deleted_at is null
);

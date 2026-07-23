-- Module: AUTH (Phase 5)
-- Seed permissions, menus, role_menu matrix

insert into master.permission (code, module, action, resource, description)
select v.code, v.module, v.action, v.resource, v.description
from (values
  ('master.menu.manage', 'master', 'manage', 'menu', 'Manage navigation menus'),
  ('shell.dashboard.read', 'shell', 'read', 'dashboard', 'View home dashboard'),
  ('shell.settings.read', 'shell', 'read', 'settings', 'View settings area')
) as v(code, module, action, resource, description)
where not exists (
  select 1 from master.permission p where p.code = v.code and p.deleted_at is null
);

-- admin: all new perms
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
cross join master.permission p
where r.code = 'admin'
  and r.deleted_at is null
  and p.deleted_at is null
  and p.code in ('master.menu.manage', 'shell.dashboard.read', 'shell.settings.read')
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- all roles get dashboard + settings read
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
join master.permission p on p.code in ('shell.dashboard.read', 'shell.settings.read')
where r.deleted_at is null
  and p.deleted_at is null
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- viewer/planner/supervisor get plan read already; ensure dashboard

-- ---------------------------------------------------------------------------
-- Menu tree
-- ---------------------------------------------------------------------------
-- Root: HOME
insert into master.menu (code, label, path, icon, sort_order, module, permission_code)
select 'home', 'Home', '/dashboard', 'home', 10, 'shell', 'shell.dashboard.read'
where not exists (select 1 from master.menu where code = 'home' and deleted_at is null);

-- Root: PLANNING
insert into master.menu (code, label, path, icon, sort_order, module, permission_code)
select 'planning', 'Planning', null, 'calendar', 20, 'plan', 'plan.production_plan.read'
where not exists (select 1 from master.menu where code = 'planning' and deleted_at is null);

insert into master.menu (parent_id, code, label, path, icon, sort_order, module, permission_code)
select m.id, 'planning.plans', 'Plans', '/planning/plans', 'list', 10, 'plan', 'plan.production_plan.read'
from master.menu m
where m.code = 'planning' and m.deleted_at is null
  and not exists (select 1 from master.menu where code = 'planning.plans' and deleted_at is null);

insert into master.menu (parent_id, code, label, path, icon, sort_order, module, permission_code)
select m.id, 'planning.approvals', 'Approvals', '/planning/approvals', 'check', 20, 'plan', 'plan.production_plan.approve'
from master.menu m
where m.code = 'planning' and m.deleted_at is null
  and not exists (select 1 from master.menu where code = 'planning.approvals' and deleted_at is null);

-- Root: MASTERS
insert into master.menu (code, label, path, icon, sort_order, module, permission_code)
select 'masters', 'Masters', null, 'database', 30, 'master', null
where not exists (select 1 from master.menu where code = 'masters' and deleted_at is null);

insert into master.menu (parent_id, code, label, path, icon, sort_order, module, permission_code)
select m.id, v.code, v.label, v.path, v.icon, v.sort_order, 'master', v.permission_code
from master.menu m
cross join (values
  ('masters.lines', 'Lines', '/settings/masters/lines', 'layers', 10, 'master.production_line.manage'),
  ('masters.machines', 'Machines', '/settings/masters/machines', 'cpu', 20, 'master.machine.manage'),
  ('masters.shifts', 'Shifts', '/settings/masters/shifts', 'clock', 30, 'master.shift.manage'),
  ('masters.calendars', 'Calendars', '/settings/masters/calendars', 'calendar', 40, 'master.calendar.manage'),
  ('masters.holidays', 'Holidays', '/settings/masters/holidays', 'sun', 50, 'master.calendar.manage'),
  ('masters.customers', 'Customers', '/settings/masters/customers', 'users', 60, 'master.customer.manage'),
  ('masters.parts', 'Parts', '/settings/masters/parts', 'box', 70, 'master.part.manage'),
  ('masters.processes', 'Processes', '/settings/masters/processes', 'workflow', 80, 'master.process.manage')
) as v(code, label, path, icon, sort_order, permission_code)
where m.code = 'masters' and m.deleted_at is null
  and not exists (select 1 from master.menu x where x.code = v.code and x.deleted_at is null);

-- Root: AUTH ADMIN
insert into master.menu (code, label, path, icon, sort_order, module, permission_code)
select 'auth', 'Access', null, 'shield', 40, 'master', null
where not exists (select 1 from master.menu where code = 'auth' and deleted_at is null);

insert into master.menu (parent_id, code, label, path, icon, sort_order, module, permission_code)
select m.id, v.code, v.label, v.path, v.icon, v.sort_order, 'master', v.permission_code
from master.menu m
cross join (values
  ('auth.users', 'Users', '/settings/users', 'user', 10, 'master.user.manage'),
  ('auth.roles', 'Roles', '/settings/roles', 'badge', 20, 'master.role.manage'),
  ('auth.permissions', 'Permissions', '/settings/permissions', 'key', 30, 'master.permission.manage'),
  ('auth.menus', 'Menus', '/settings/menus', 'menu', 40, 'master.menu.manage')
) as v(code, label, path, icon, sort_order, permission_code)
where m.code = 'auth' and m.deleted_at is null
  and not exists (select 1 from master.menu x where x.code = v.code and x.deleted_at is null);

-- Root: SETTINGS
insert into master.menu (code, label, path, icon, sort_order, module, permission_code)
select 'settings', 'Settings', '/settings/preferences', 'settings', 90, 'shell', 'shell.settings.read'
where not exists (select 1 from master.menu where code = 'settings' and deleted_at is null);

-- ---------------------------------------------------------------------------
-- role_menu: pin full tree for admin; planning+home for planner/supervisor/viewer
-- ---------------------------------------------------------------------------
insert into master.role_menu (role_id, menu_id)
select r.id, m.id
from master.role r
cross join master.menu m
where r.code = 'admin'
  and r.deleted_at is null
  and m.deleted_at is null
  and not exists (
    select 1 from master.role_menu rm
    where rm.role_id = r.id and rm.menu_id = m.id and rm.deleted_at is null
  );

insert into master.role_menu (role_id, menu_id)
select r.id, m.id
from master.role r
join master.menu m on m.code in (
  'home', 'planning', 'planning.plans', 'planning.approvals', 'settings'
)
where r.code in ('planner', 'supervisor', 'viewer')
  and r.deleted_at is null
  and m.deleted_at is null
  and not exists (
    select 1 from master.role_menu rm
    where rm.role_id = r.id and rm.menu_id = m.id and rm.deleted_at is null
  );

-- supervisor also sees approvals already included
-- planner does not get auth.* menus (admin only via role_menu)

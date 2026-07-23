-- Module: AUTH (Phase 5)
-- Views + RLS for menu / role_menu

create or replace view master.v_menu_active
with (security_invoker = true)
as
select
  id,
  parent_id,
  code,
  label,
  path,
  icon,
  sort_order,
  module,
  permission_code,
  created_at,
  updated_at,
  version
from master.menu
where deleted_at is null
  and is_active = true;

grant select on master.v_menu_active to authenticated, service_role;

alter table master.menu enable row level security;
alter table master.role_menu enable row level security;

create policy menu_select_authenticated on master.menu
  for select to authenticated
  using (deleted_at is null);

create policy role_menu_select_authenticated on master.role_menu
  for select to authenticated
  using (deleted_at is null);

create policy menu_manage on master.menu
  for all to authenticated
  using (authz.has_permission('master.menu.manage'))
  with check (authz.has_permission('master.menu.manage'));

create policy role_menu_manage on master.role_menu
  for all to authenticated
  using (authz.has_permission('master.menu.manage'))
  with check (authz.has_permission('master.menu.manage'));

-- Also allow role managers to assign role_menu
create policy role_menu_manage_via_role on master.role_menu
  for all to authenticated
  using (authz.has_permission('master.role.manage'))
  with check (authz.has_permission('master.role.manage'));

-- Module: PLATFORM
-- Convenience views (security_invoker where supported)

create or replace view master.v_plant_active
with (security_invoker = true)
as
select
  id,
  code,
  name,
  timezone,
  default_calendar_id,
  created_at,
  updated_at,
  version
from master.plant
where deleted_at is null
  and is_active = true;

create or replace view master.v_role_active
with (security_invoker = true)
as
select id, code, name, description
from master.role
where deleted_at is null
  and is_active = true;

create or replace view master.v_permission_active
with (security_invoker = true)
as
select id, code, module, action, resource, description
from master.permission
where deleted_at is null
  and is_active = true;

create or replace view master.v_uom_active
with (security_invoker = true)
as
select id, code, name, dimension
from master.uom
where deleted_at is null
  and is_active = true;

create or replace view master.v_status_code_active
with (security_invoker = true)
as
select id, entity_type, code, name, sort_order, is_terminal
from master.status_code
where deleted_at is null
  and is_active = true;

create or replace view master.v_user_profile_active
with (security_invoker = true)
as
select
  id,
  auth_user_id,
  employee_code,
  display_name,
  email,
  department_id,
  default_plant_id,
  locale,
  timezone,
  theme_pref,
  font_scale,
  compact_mode,
  sidebar_collapsed
from master.user_profile
where deleted_at is null
  and is_active = true;

create or replace view config.v_feature_flag_active
with (security_invoker = true)
as
select code, is_enabled, payload_json
from config.feature_flag
where deleted_at is null
  and is_active = true;

grant select on master.v_plant_active to authenticated, service_role;
grant select on master.v_role_active to authenticated, service_role;
grant select on master.v_permission_active to authenticated, service_role;
grant select on master.v_uom_active to authenticated, service_role;
grant select on master.v_status_code_active to authenticated, service_role;
grant select on master.v_user_profile_active to authenticated, service_role;
grant select on config.v_feature_flag_active to authenticated, service_role;

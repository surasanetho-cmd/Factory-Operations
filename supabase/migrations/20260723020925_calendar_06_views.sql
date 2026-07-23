-- Module: CALENDAR & RESOURCES
-- Active convenience views

create or replace view master.v_calendar_active
with (security_invoker = true)
as
select id, plant_id, code, name, timezone, created_at, updated_at, version
from master.calendar
where deleted_at is null
  and is_active = true;

create or replace view master.v_holiday_active
with (security_invoker = true)
as
select id, calendar_id, holiday_date, name, is_paid, created_at, updated_at, version
from master.holiday
where deleted_at is null
  and is_active = true;

create or replace view master.v_production_line_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  code,
  name,
  tonnage,
  sort_order,
  calendar_id,
  created_at,
  updated_at,
  version
from master.production_line
where deleted_at is null
  and is_active = true;

create or replace view master.v_machine_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  production_line_id,
  code,
  name,
  machine_type,
  rated_capacity,
  calendar_id,
  created_at,
  updated_at,
  version
from master.machine
where deleted_at is null
  and is_active = true;

create or replace view master.v_shift_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  code,
  name,
  start_time,
  end_time,
  break_minutes,
  crosses_midnight,
  created_at,
  updated_at,
  version
from master.shift
where deleted_at is null
  and is_active = true;

create or replace view master.v_capacity_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  production_line_id,
  machine_id,
  shift_id,
  jobs_per_day,
  hours_per_shift,
  effective_from,
  effective_to,
  created_at,
  updated_at,
  version
from master.capacity
where deleted_at is null
  and is_active = true;

create or replace view txn.v_ot_window_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  production_line_id,
  machine_id,
  start_at,
  end_at,
  status_code,
  reason_code_id,
  created_at,
  updated_at,
  version
from txn.ot_window
where deleted_at is null
  and is_active = true;

create or replace view txn.v_machine_shutdown_active
with (security_invoker = true)
as
select
  id,
  plant_id,
  machine_id,
  production_line_id,
  start_at,
  end_at,
  status_code,
  reason_code_id,
  created_at,
  updated_at,
  version
from txn.machine_shutdown
where deleted_at is null
  and is_active = true;

grant select on master.v_calendar_active to authenticated, service_role;
grant select on master.v_holiday_active to authenticated, service_role;
grant select on master.v_production_line_active to authenticated, service_role;
grant select on master.v_machine_active to authenticated, service_role;
grant select on master.v_shift_active to authenticated, service_role;
grant select on master.v_capacity_active to authenticated, service_role;
grant select on txn.v_ot_window_active to authenticated, service_role;
grant select on txn.v_machine_shutdown_active to authenticated, service_role;

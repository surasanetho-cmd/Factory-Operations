-- Module: CALENDAR & RESOURCES
-- RLS policies for calendar / resource tables

alter table master.calendar enable row level security;
alter table master.holiday enable row level security;
alter table master.production_line enable row level security;
alter table master.machine enable row level security;
alter table master.shift enable row level security;
alter table master.shift_assignment enable row level security;
alter table master.capacity enable row level security;
alter table txn.ot_window enable row level security;
alter table txn.machine_shutdown enable row level security;

-- ---------------------------------------------------------------------------
-- Select (plant-scoped)
-- ---------------------------------------------------------------------------
create policy calendar_select_authenticated on master.calendar
  for select to authenticated
  using (
    deleted_at is null
    and (plant_id is null or plant_id in (select authz.user_plant_ids()))
  );

create policy holiday_select_authenticated on master.holiday
  for select to authenticated
  using (
    deleted_at is null
    and calendar_id in (
      select c.id
      from master.calendar c
      where c.deleted_at is null
        and (c.plant_id is null or c.plant_id in (select authz.user_plant_ids()))
    )
  );

create policy production_line_select_authenticated on master.production_line
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy machine_select_authenticated on master.machine
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy shift_select_authenticated on master.shift
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy shift_assignment_select_authenticated on master.shift_assignment
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy capacity_select_authenticated on master.capacity
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy ot_window_select_authenticated on txn.ot_window
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy machine_shutdown_select_authenticated on txn.machine_shutdown
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

-- ---------------------------------------------------------------------------
-- Manage (permission-gated)
-- ---------------------------------------------------------------------------
create policy calendar_manage on master.calendar
  for all to authenticated
  using (authz.has_permission('master.calendar.manage'))
  with check (authz.has_permission('master.calendar.manage'));

create policy holiday_manage on master.holiday
  for all to authenticated
  using (authz.has_permission('master.calendar.manage'))
  with check (authz.has_permission('master.calendar.manage'));

create policy production_line_manage on master.production_line
  for all to authenticated
  using (authz.has_permission('master.production_line.manage'))
  with check (authz.has_permission('master.production_line.manage'));

create policy machine_manage on master.machine
  for all to authenticated
  using (authz.has_permission('master.machine.manage'))
  with check (authz.has_permission('master.machine.manage'));

create policy shift_manage on master.shift
  for all to authenticated
  using (authz.has_permission('master.shift.manage'))
  with check (authz.has_permission('master.shift.manage'));

create policy shift_assignment_manage on master.shift_assignment
  for all to authenticated
  using (authz.has_permission('master.shift.manage'))
  with check (authz.has_permission('master.shift.manage'));

create policy capacity_manage on master.capacity
  for all to authenticated
  using (authz.has_permission('master.capacity.manage'))
  with check (authz.has_permission('master.capacity.manage'));

create policy ot_window_manage on txn.ot_window
  for all to authenticated
  using (
    plant_id in (select authz.user_plant_ids())
    and (
      authz.has_permission('plan.ot_window.manage')
      or authz.has_permission_for_plant('plan.ot_window.manage', plant_id)
    )
  )
  with check (
    plant_id in (select authz.user_plant_ids())
    and (
      authz.has_permission('plan.ot_window.manage')
      or authz.has_permission_for_plant('plan.ot_window.manage', plant_id)
    )
  );

create policy machine_shutdown_manage on txn.machine_shutdown
  for all to authenticated
  using (
    plant_id in (select authz.user_plant_ids())
    and (
      authz.has_permission('plan.machine_shutdown.manage')
      or authz.has_permission_for_plant('plan.machine_shutdown.manage', plant_id)
    )
  )
  with check (
    plant_id in (select authz.user_plant_ids())
    and (
      authz.has_permission('plan.machine_shutdown.manage')
      or authz.has_permission_for_plant('plan.machine_shutdown.manage', plant_id)
    )
  );

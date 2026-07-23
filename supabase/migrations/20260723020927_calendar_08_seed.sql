-- Module: CALENDAR & RESOURCES
-- Seed: calendar, holidays, lines, machines, shifts, capacity, permissions

-- ---------------------------------------------------------------------------
-- Permissions for this module
-- ---------------------------------------------------------------------------
insert into master.permission (code, module, action, resource, description)
select v.code, v.module, v.action, v.resource, v.description
from (values
  ('master.calendar.manage', 'master', 'manage', 'calendar', 'Manage calendars and holidays'),
  ('master.production_line.manage', 'master', 'manage', 'production_line', 'Manage production lines'),
  ('master.shift.manage', 'master', 'manage', 'shift', 'Manage shifts and assignments'),
  ('master.capacity.manage', 'master', 'manage', 'capacity', 'Manage capacity definitions'),
  ('plan.ot_window.manage', 'plan', 'manage', 'ot_window', 'Manage overtime windows'),
  ('plan.machine_shutdown.manage', 'plan', 'manage', 'machine_shutdown', 'Manage machine shutdowns')
) as v(code, module, action, resource, description)
where not exists (
  select 1 from master.permission p where p.code = v.code and p.deleted_at is null
);

-- admin gets all new permissions
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
cross join master.permission p
where r.code = 'admin'
  and r.deleted_at is null
  and p.deleted_at is null
  and p.code in (
    'master.calendar.manage',
    'master.production_line.manage',
    'master.shift.manage',
    'master.capacity.manage',
    'plan.ot_window.manage',
    'plan.machine_shutdown.manage'
  )
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- planner: OT + shutdown manage; supervisor: same
insert into master.role_permission (role_id, permission_id)
select r.id, p.id
from master.role r
join master.permission p on p.code in (
  'plan.ot_window.manage',
  'plan.machine_shutdown.manage'
)
where r.code in ('planner', 'supervisor')
  and r.deleted_at is null
  and p.deleted_at is null
  and not exists (
    select 1 from master.role_permission rp
    where rp.role_id = r.id and rp.permission_id = p.id and rp.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Calendar SF1-STD → plant default
-- ---------------------------------------------------------------------------
insert into master.calendar (plant_id, code, name, timezone)
select p.id, 'SF1-STD', 'SF1 Standard Calendar', 'Asia/Bangkok'
from master.plant p
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.calendar c
    where c.plant_id = p.id and c.code = 'SF1-STD' and c.deleted_at is null
  );

update master.plant p
set default_calendar_id = c.id,
    updated_at = now(),
    version = p.version + 1
from master.calendar c
where p.code = 'SF1'
  and p.deleted_at is null
  and c.plant_id = p.id
  and c.code = 'SF1-STD'
  and c.deleted_at is null
  and (p.default_calendar_id is distinct from c.id);

-- ---------------------------------------------------------------------------
-- Holidays (sample 2026–2027 Thailand-oriented)
-- ---------------------------------------------------------------------------
insert into master.holiday (calendar_id, holiday_date, name, is_paid)
select c.id, v.holiday_date::date, v.name, true
from master.calendar c
join master.plant p on p.id = c.plant_id and p.code = 'SF1'
cross join (values
  ('2026-01-01', 'New Year''s Day'),
  ('2026-04-06', 'Chakri Memorial Day'),
  ('2026-04-13', 'Songkran'),
  ('2026-04-14', 'Songkran'),
  ('2026-04-15', 'Songkran'),
  ('2026-05-01', 'Labour Day'),
  ('2026-12-05', 'Father''s Day / National Day'),
  ('2026-12-31', 'New Year''s Eve'),
  ('2027-01-01', 'New Year''s Day')
) as v(holiday_date, name)
where c.code = 'SF1-STD' and c.deleted_at is null
  and not exists (
    select 1 from master.holiday h
    where h.calendar_id = c.id
      and h.holiday_date = v.holiday_date::date
      and h.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Production lines (110T–3200T)
-- ---------------------------------------------------------------------------
insert into master.production_line (plant_id, code, name, tonnage, sort_order, calendar_id)
select p.id, v.code, v.name, v.tonnage, v.sort_order, c.id
from master.plant p
join master.calendar c
  on c.plant_id = p.id and c.code = 'SF1-STD' and c.deleted_at is null
cross join (values
  ('PL-110T', '110 Ton', 110, 10),
  ('PL-250T', '250 Ton', 250, 20),
  ('PL-300T', '300 Ton', 300, 30),
  ('PL-600T', '600 Ton', 600, 40),
  ('PL-800T', '800 Ton', 800, 50),
  ('PL-3200T', '3200 Ton', 3200, 60)
) as v(code, name, tonnage, sort_order)
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.production_line pl
    where pl.plant_id = p.id and pl.code = v.code and pl.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Machines (one primary machine per line)
-- ---------------------------------------------------------------------------
insert into master.machine (
  plant_id,
  production_line_id,
  code,
  name,
  machine_type,
  rated_capacity,
  calendar_id
)
select
  pl.plant_id,
  pl.id,
  pl.code || '-01',
  pl.name || ' Machine 01',
  'press',
  null,
  pl.calendar_id
from master.production_line pl
join master.plant p on p.id = pl.plant_id and p.code = 'SF1'
where pl.deleted_at is null
  and not exists (
    select 1 from master.machine m
    where m.plant_id = pl.plant_id
      and m.code = pl.code || '-01'
      and m.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Shifts
-- ---------------------------------------------------------------------------
insert into master.shift (
  plant_id, code, name, start_time, end_time, break_minutes, crosses_midnight
)
select p.id, v.code, v.name, v.start_time::time, v.end_time::time, v.break_minutes, v.crosses_midnight
from master.plant p
cross join (values
  ('DAY', 'Day Shift', '08:00', '17:00', 60, false),
  ('NIGHT', 'Night Shift', '20:00', '05:00', 60, true)
) as v(code, name, start_time, end_time, break_minutes, crosses_midnight)
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.shift s
    where s.plant_id = p.id and s.code = v.code and s.deleted_at is null
  );

-- Plant-wide shift assignments (Mon–Fri = 31), effective from 2026-01-01
insert into master.shift_assignment (
  plant_id,
  shift_id,
  production_line_id,
  machine_id,
  effective_from,
  effective_to,
  weekday_mask
)
select
  p.id,
  s.id,
  null,
  null,
  date '2026-01-01',
  null,
  31::smallint
from master.plant p
join master.shift s on s.plant_id = p.id and s.code in ('DAY', 'NIGHT') and s.deleted_at is null
where p.code = 'SF1' and p.deleted_at is null
  and not exists (
    select 1 from master.shift_assignment sa
    where sa.plant_id = p.id
      and sa.shift_id = s.id
      and sa.production_line_id is null
      and sa.machine_id is null
      and sa.effective_from = date '2026-01-01'
      and sa.deleted_at is null
  );

-- ---------------------------------------------------------------------------
-- Capacity: ~25 jobs/day, 8 hours on DAY shift per line
-- ---------------------------------------------------------------------------
insert into master.capacity (
  plant_id,
  production_line_id,
  machine_id,
  shift_id,
  jobs_per_day,
  hours_per_shift,
  effective_from,
  effective_to
)
select
  pl.plant_id,
  pl.id,
  null,
  s.id,
  25,
  8.00,
  date '2026-01-01',
  null
from master.production_line pl
join master.plant p on p.id = pl.plant_id and p.code = 'SF1'
join master.shift s on s.plant_id = pl.plant_id and s.code = 'DAY' and s.deleted_at is null
where pl.deleted_at is null
  and not exists (
    select 1 from master.capacity c
    where c.production_line_id = pl.id
      and c.shift_id = s.id
      and c.effective_from = date '2026-01-01'
      and c.deleted_at is null
  );

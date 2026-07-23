-- Module: CALENDAR & RESOURCES
-- Calendar Engine SQL helpers (v1 foundation)
-- Full window/timeline computation stays in domain service; these RPCs share resolution rules.

-- ---------------------------------------------------------------------------
-- Resolve calendar for a resource (machine → line → plant default)
-- ---------------------------------------------------------------------------
create or replace function master.resolve_calendar_id(
  p_plant_id uuid,
  p_production_line_id uuid default null,
  p_machine_id uuid default null
)
returns uuid
language plpgsql
stable
security invoker
set search_path = master, public
as $$
declare
  v_calendar_id uuid;
  v_line_id uuid := p_production_line_id;
begin
  if p_machine_id is not null then
    select m.calendar_id, m.production_line_id
      into v_calendar_id, v_line_id
    from master.machine m
    where m.id = p_machine_id
      and m.deleted_at is null
      and m.is_active = true;

    if v_calendar_id is not null then
      return v_calendar_id;
    end if;
  end if;

  if v_line_id is not null then
    select pl.calendar_id
      into v_calendar_id
    from master.production_line pl
    where pl.id = v_line_id
      and pl.deleted_at is null
      and pl.is_active = true;

    if v_calendar_id is not null then
      return v_calendar_id;
    end if;
  end if;

  select p.default_calendar_id
    into v_calendar_id
  from master.plant p
  where p.id = p_plant_id
    and p.deleted_at is null
    and p.is_active = true;

  return v_calendar_id;
end;
$$;

comment on function master.resolve_calendar_id(uuid, uuid, uuid) is
  'Calendar Engine: machine.calendar → line.calendar → plant.default_calendar';

-- Alias RPC name per naming standard
create or replace function public.engine_calendar_resolve_calendar(
  p_plant_id uuid,
  p_production_line_id uuid default null,
  p_machine_id uuid default null
)
returns table (
  calendar_id uuid,
  timezone text,
  code text
)
language sql
stable
security invoker
set search_path = master, public
as $$
  select
    c.id as calendar_id,
    c.timezone,
    c.code
  from master.calendar c
  where c.id = master.resolve_calendar_id(p_plant_id, p_production_line_id, p_machine_id)
    and c.deleted_at is null
    and c.is_active = true;
$$;

comment on function public.engine_calendar_resolve_calendar(uuid, uuid, uuid) is
  'RPC: resolve calendar id + timezone for a resource';

-- ---------------------------------------------------------------------------
-- Holiday / working day
-- ---------------------------------------------------------------------------
create or replace function master.is_holiday(
  p_calendar_id uuid,
  p_date date
)
returns boolean
language sql
stable
security invoker
set search_path = master, public
as $$
  select exists (
    select 1
    from master.holiday h
    where h.calendar_id = p_calendar_id
      and h.holiday_date = p_date
      and h.deleted_at is null
      and h.is_active = true
  );
$$;

create or replace function master.is_working_day(
  p_calendar_id uuid,
  p_date date
)
returns boolean
language sql
stable
security invoker
set search_path = master, public
as $$
  select p_calendar_id is not null
    and not master.is_holiday(p_calendar_id, p_date);
$$;

create or replace function public.engine_calendar_is_working_day(
  p_calendar_id uuid,
  p_date date
)
returns boolean
language sql
stable
security invoker
set search_path = master, public
as $$
  select master.is_working_day(p_calendar_id, p_date);
$$;

-- ---------------------------------------------------------------------------
-- Weekday bit for mask (Mon=1 … Sun=64); ISODOW Mon=1 … Sun=7
-- ---------------------------------------------------------------------------
create or replace function master.weekday_bit(
  p_date date
)
returns smallint
language sql
immutable
as $$
  select (1 << (extract(isodow from p_date)::integer - 1))::smallint;
$$;

-- ---------------------------------------------------------------------------
-- Effective capacity row for resource + date (+ optional shift)
-- ---------------------------------------------------------------------------
create or replace function master.get_capacity_for_date(
  p_plant_id uuid,
  p_date date,
  p_production_line_id uuid default null,
  p_machine_id uuid default null,
  p_shift_id uuid default null
)
returns table (
  capacity_id uuid,
  shift_id uuid,
  jobs_per_day integer,
  hours_per_shift numeric
)
language sql
stable
security invoker
set search_path = master, public
as $$
  select
    c.id,
    c.shift_id,
    c.jobs_per_day,
    c.hours_per_shift
  from master.capacity c
  where c.plant_id = p_plant_id
    and c.deleted_at is null
    and c.is_active = true
    and c.effective_from <= p_date
    and (c.effective_to is null or c.effective_to >= p_date)
    and (
      (p_machine_id is not null and c.machine_id = p_machine_id)
      or (
        p_machine_id is null
        and p_production_line_id is not null
        and c.production_line_id = p_production_line_id
      )
    )
    and (p_shift_id is null or c.shift_id = p_shift_id)
  order by c.effective_from desc
  limit 1;
$$;

create or replace function public.engine_calendar_get_capacity(
  p_plant_id uuid,
  p_date date,
  p_production_line_id uuid default null,
  p_machine_id uuid default null,
  p_shift_id uuid default null
)
returns table (
  capacity_id uuid,
  shift_id uuid,
  jobs_per_day integer,
  hours_per_shift numeric
)
language sql
stable
security invoker
set search_path = master, public
as $$
  select *
  from master.get_capacity_for_date(
    p_plant_id,
    p_date,
    p_production_line_id,
    p_machine_id,
    p_shift_id
  );
$$;

-- Grants
revoke all on function master.resolve_calendar_id(uuid, uuid, uuid) from public;
revoke all on function master.is_holiday(uuid, date) from public;
revoke all on function master.is_working_day(uuid, date) from public;
revoke all on function master.weekday_bit(date) from public;
revoke all on function master.get_capacity_for_date(uuid, date, uuid, uuid, uuid) from public;
revoke all on function public.engine_calendar_resolve_calendar(uuid, uuid, uuid) from public;
revoke all on function public.engine_calendar_is_working_day(uuid, date) from public;
revoke all on function public.engine_calendar_get_capacity(uuid, date, uuid, uuid, uuid) from public;

grant execute on function master.resolve_calendar_id(uuid, uuid, uuid) to authenticated, service_role;
grant execute on function master.is_holiday(uuid, date) to authenticated, service_role;
grant execute on function master.is_working_day(uuid, date) to authenticated, service_role;
grant execute on function master.weekday_bit(date) to authenticated, service_role;
grant execute on function master.get_capacity_for_date(uuid, date, uuid, uuid, uuid) to authenticated, service_role;
grant execute on function public.engine_calendar_resolve_calendar(uuid, uuid, uuid) to authenticated, service_role, anon;
grant execute on function public.engine_calendar_is_working_day(uuid, date) to authenticated, service_role, anon;
grant execute on function public.engine_calendar_get_capacity(uuid, date, uuid, uuid, uuid) to authenticated, service_role, anon;

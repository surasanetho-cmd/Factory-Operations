-- Module: PLANNING
-- Workflow + drag-drop + capacity RPCs

-- ---------------------------------------------------------------------------
-- Capacity summary for a plan (jobs vs nominal capacity by line+date)
-- ---------------------------------------------------------------------------
create or replace function public.rpc_plan_capacity_summary(p_plan_id uuid)
returns table (
  production_line_id uuid,
  line_code text,
  planned_date date,
  jobs_scheduled integer,
  jobs_capacity integer,
  hours_scheduled numeric,
  hours_capacity numeric,
  load_pct numeric
)
language sql
stable
security invoker
set search_path = txn, master, public
as $$
  with items as (
    select
      i.production_line_id,
      i.planned_date,
      count(*)::int as jobs_scheduled,
      coalesce(sum(extract(epoch from (i.planned_end_at - i.planned_start_at)) / 3600.0), 0) as hours_scheduled
    from txn.production_plan_item i
    where i.production_plan_id = p_plan_id
      and i.deleted_at is null
      and i.is_active = true
    group by i.production_line_id, i.planned_date
  )
  select
    it.production_line_id,
    pl.code as line_code,
    it.planned_date,
    it.jobs_scheduled,
    coalesce(c.jobs_per_day, 25) as jobs_capacity,
    round(it.hours_scheduled::numeric, 2) as hours_scheduled,
    coalesce(c.hours_per_shift, 8) as hours_capacity,
    case
      when coalesce(c.jobs_per_day, 25) = 0 then null
      else round((it.jobs_scheduled::numeric / c.jobs_per_day::numeric) * 100, 1)
    end as load_pct
  from items it
  join master.production_line pl on pl.id = it.production_line_id
  left join lateral (
    select cap.jobs_per_day, cap.hours_per_shift
    from master.capacity cap
    where cap.production_line_id = it.production_line_id
      and cap.deleted_at is null
      and cap.is_active = true
      and cap.effective_from <= it.planned_date
      and (cap.effective_to is null or cap.effective_to >= it.planned_date)
    order by cap.effective_from desc
    limit 1
  ) c on true
  order by it.planned_date, pl.sort_order;
$$;

-- ---------------------------------------------------------------------------
-- Drag-drop move plan item (optimistic concurrency via version)
-- ---------------------------------------------------------------------------
create or replace function public.rpc_plan_item_move(
  p_item_id uuid,
  p_expected_version integer,
  p_production_line_id uuid,
  p_machine_id uuid,
  p_shift_id uuid,
  p_planned_date date,
  p_planned_start_at timestamptz,
  p_planned_end_at timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = txn, history, master, authz, public
as $$
declare
  v_item txn.production_plan_item%rowtype;
  v_plan txn.production_plan%rowtype;
  v_actor uuid := authz.current_user_profile_id();
  v_before jsonb;
begin
  if v_actor is null then
    raise exception 'not authenticated';
  end if;

  if not authz.has_permission('plan.production_plan.update') then
    raise exception 'permission denied';
  end if;

  select * into v_item
  from txn.production_plan_item
  where id = p_item_id and deleted_at is null
  for update;

  if v_item.id is null then
    raise exception 'item not found';
  end if;

  if v_item.version <> p_expected_version then
    return jsonb_build_object('ok', false, 'error', 'version_conflict', 'version', v_item.version);
  end if;

  select * into v_plan
  from txn.production_plan
  where id = v_item.production_plan_id and deleted_at is null;

  if v_plan.status_code not in ('draft', 'rejected') then
    raise exception 'plan is not editable (status=%)', v_plan.status_code;
  end if;

  if p_planned_end_at <= p_planned_start_at then
    raise exception 'planned_end_at must be after planned_start_at';
  end if;

  v_before := to_jsonb(v_item);

  update txn.production_plan_item
  set
    production_line_id = p_production_line_id,
    machine_id = p_machine_id,
    shift_id = p_shift_id,
    planned_date = p_planned_date,
    planned_start_at = p_planned_start_at,
    planned_end_at = p_planned_end_at,
    updated_by = v_actor,
    version = version + 1
  where id = p_item_id
  returning * into v_item;

  insert into history.production_plan_item_history (
    production_plan_item_id, version, change_type, before_json, after_json,
    changed_fields, changed_by
  ) values (
    v_item.id,
    v_item.version,
    'move',
    v_before,
    to_jsonb(v_item),
    array['production_line_id','machine_id','shift_id','planned_date','planned_start_at','planned_end_at'],
    v_actor
  );

  update txn.production_plan
  set updated_by = v_actor, version = version + 1
  where id = v_plan.id;

  return jsonb_build_object('ok', true, 'item', to_jsonb(v_item));
end;
$$;

-- ---------------------------------------------------------------------------
-- Workflow: submit / approve / reject / release
-- ---------------------------------------------------------------------------
create or replace function public.rpc_plan_workflow(
  p_plan_id uuid,
  p_action text,
  p_comment text default null,
  p_expected_version integer default null
)
returns jsonb
language plpgsql
security definer
set search_path = txn, history, master, authz, public
as $$
declare
  v_plan txn.production_plan%rowtype;
  v_actor uuid := authz.current_user_profile_id();
  v_before jsonb;
  v_new_status text;
  v_perm text;
begin
  if v_actor is null then
    raise exception 'not authenticated';
  end if;

  if p_action not in ('submit', 'approve', 'reject', 'release') then
    raise exception 'invalid action';
  end if;

  v_perm := case p_action
    when 'submit' then 'plan.production_plan.update'
    when 'approve' then 'plan.production_plan.approve'
    when 'reject' then 'plan.production_plan.reject'
    when 'release' then 'plan.production_plan.release'
  end;

  if not authz.has_permission(v_perm) then
    raise exception 'permission denied for %', p_action;
  end if;

  select * into v_plan
  from txn.production_plan
  where id = p_plan_id and deleted_at is null
  for update;

  if v_plan.id is null then
    raise exception 'plan not found';
  end if;

  if p_expected_version is not null and v_plan.version <> p_expected_version then
    return jsonb_build_object('ok', false, 'error', 'version_conflict', 'version', v_plan.version);
  end if;

  -- state machine
  if p_action = 'submit' and v_plan.status_code not in ('draft', 'rejected') then
    raise exception 'cannot submit from %', v_plan.status_code;
  elsif p_action = 'approve' and v_plan.status_code <> 'submitted' then
    raise exception 'cannot approve from %', v_plan.status_code;
  elsif p_action = 'reject' and v_plan.status_code <> 'submitted' then
    raise exception 'cannot reject from %', v_plan.status_code;
  elsif p_action = 'release' and v_plan.status_code <> 'approved' then
    raise exception 'cannot release from %', v_plan.status_code;
  end if;

  v_new_status := case p_action
    when 'submit' then 'submitted'
    when 'approve' then 'approved'
    when 'reject' then 'rejected'
    when 'release' then 'released'
  end;

  v_before := to_jsonb(v_plan);

  update txn.production_plan
  set
    status_code = v_new_status,
    updated_by = v_actor,
    version = version + 1
  where id = p_plan_id
  returning * into v_plan;

  if p_action in ('submit', 'approve', 'reject') then
    insert into txn.plan_approval (
      production_plan_id, action, comment, acted_by, acted_at, created_by
    ) values (
      p_plan_id, p_action, p_comment, v_actor, now(), v_actor
    );
  end if;

  if p_action = 'release' then
    insert into txn.plan_release (
      production_plan_id, released_by, released_at, effective_from, created_by
    ) values (
      p_plan_id, v_actor, now(), now(), v_actor
    );

    update txn.production_plan_item
    set status_code = 'released', updated_by = v_actor, version = version + 1
    where production_plan_id = p_plan_id
      and deleted_at is null
      and status_code = 'planned';
  end if;

  insert into history.production_plan_history (
    production_plan_id, version, change_type, before_json, after_json,
    changed_fields, changed_by
  ) values (
    v_plan.id,
    v_plan.version,
    p_action,
    v_before,
    to_jsonb(v_plan),
    array['status_code'],
    v_actor
  );

  return jsonb_build_object('ok', true, 'plan', to_jsonb(v_plan));
end;
$$;

revoke all on function public.rpc_plan_capacity_summary(uuid) from public;
revoke all on function public.rpc_plan_item_move(uuid, integer, uuid, uuid, uuid, date, timestamptz, timestamptz) from public;
revoke all on function public.rpc_plan_workflow(uuid, text, text, integer) from public;

grant execute on function public.rpc_plan_capacity_summary(uuid) to authenticated, service_role;
grant execute on function public.rpc_plan_item_move(uuid, integer, uuid, uuid, uuid, date, timestamptz, timestamptz) to authenticated, service_role;
grant execute on function public.rpc_plan_workflow(uuid, text, text, integer) to authenticated, service_role;

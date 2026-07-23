-- Module: PLATFORM
-- Authz helpers + baseline RLS on platform tables

-- ---------------------------------------------------------------------------
-- authz helpers
-- ---------------------------------------------------------------------------
create or replace function authz.current_user_profile_id()
returns uuid
language sql
stable
security definer
set search_path = master, authz, public
as $$
  select up.id
  from master.user_profile up
  where up.auth_user_id = auth.uid()
    and up.deleted_at is null
  limit 1;
$$;

create or replace function authz.user_plant_ids()
returns setof uuid
language sql
stable
security definer
set search_path = master, authz, public
as $$
  select distinct coalesce(ur.plant_id, up.default_plant_id) as plant_id
  from master.user_profile up
  left join master.user_role ur
    on ur.user_id = up.id
   and ur.deleted_at is null
   and ur.is_active = true
  where up.auth_user_id = auth.uid()
    and up.deleted_at is null
    and coalesce(ur.plant_id, up.default_plant_id) is not null
  union
  select up.default_plant_id
  from master.user_profile up
  where up.auth_user_id = auth.uid()
    and up.deleted_at is null
    and up.default_plant_id is not null;
$$;

create or replace function authz.has_permission(permission_code text)
returns boolean
language sql
stable
security definer
set search_path = master, authz, public
as $$
  select exists (
    select 1
    from master.user_profile up
    join master.user_role ur
      on ur.user_id = up.id
     and ur.deleted_at is null
     and ur.is_active = true
    join master.role r
      on r.id = ur.role_id
     and r.deleted_at is null
     and r.is_active = true
    join master.role_permission rp
      on rp.role_id = r.id
     and rp.deleted_at is null
     and rp.is_active = true
    join master.permission p
      on p.id = rp.permission_id
     and p.deleted_at is null
     and p.is_active = true
    where up.auth_user_id = auth.uid()
      and up.deleted_at is null
      and p.code = permission_code
  );
$$;

create or replace function authz.has_permission_for_plant(
  permission_code text,
  p_plant_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = master, authz, public
as $$
  select exists (
    select 1
    from master.user_profile up
    join master.user_role ur
      on ur.user_id = up.id
     and ur.deleted_at is null
     and ur.is_active = true
     and (ur.plant_id is null or ur.plant_id = p_plant_id)
    join master.role r
      on r.id = ur.role_id
     and r.deleted_at is null
     and r.is_active = true
    join master.role_permission rp
      on rp.role_id = r.id
     and rp.deleted_at is null
     and rp.is_active = true
    join master.permission p
      on p.id = rp.permission_id
     and p.deleted_at is null
     and p.is_active = true
    where up.auth_user_id = auth.uid()
      and up.deleted_at is null
      and p.code = permission_code
  );
$$;

revoke all on function authz.current_user_profile_id() from public;
revoke all on function authz.user_plant_ids() from public;
revoke all on function authz.has_permission(text) from public;
revoke all on function authz.has_permission_for_plant(text, uuid) from public;

grant execute on function authz.current_user_profile_id() to authenticated, service_role;
grant execute on function authz.user_plant_ids() to authenticated, service_role;
grant execute on function authz.has_permission(text) to authenticated, service_role;
grant execute on function authz.has_permission_for_plant(text, uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- RLS enable + baseline policies (authenticated)
-- ---------------------------------------------------------------------------
alter table master.plant enable row level security;
alter table master.department enable row level security;
alter table master.user_profile enable row level security;
alter table master.role enable row level security;
alter table master.permission enable row level security;
alter table master.role_permission enable row level security;
alter table master.user_role enable row level security;
alter table master.uom enable row level security;
alter table master.uom_conversion enable row level security;
alter table master.status_code enable row level security;
alter table master.reason_code enable row level security;
alter table master.file_type enable row level security;
alter table master.notification_template enable row level security;
alter table master.number_sequence enable row level security;
alter table config.system_setting enable row level security;
alter table config.feature_flag enable row level security;
alter table config.user_preference enable row level security;

-- Read: authenticated users with matching plant (or global lookups)
create policy plant_select_authenticated on master.plant
  for select to authenticated
  using (deleted_at is null and id in (select authz.user_plant_ids()));

create policy department_select_authenticated on master.department
  for select to authenticated
  using (deleted_at is null and plant_id in (select authz.user_plant_ids()));

create policy user_profile_select_authenticated on master.user_profile
  for select to authenticated
  using (
    deleted_at is null
    and (
      auth_user_id = auth.uid()
      or default_plant_id in (select authz.user_plant_ids())
      or authz.has_permission('master.user.manage')
    )
  );

create policy user_profile_update_self on master.user_profile
  for update to authenticated
  using (auth_user_id = auth.uid() and deleted_at is null)
  with check (auth_user_id = auth.uid());

-- Global lookup reads
create policy role_select_authenticated on master.role
  for select to authenticated using (deleted_at is null);

create policy permission_select_authenticated on master.permission
  for select to authenticated using (deleted_at is null);

create policy role_permission_select_authenticated on master.role_permission
  for select to authenticated using (deleted_at is null);

create policy user_role_select_authenticated on master.user_role
  for select to authenticated
  using (
    deleted_at is null
    and (
      user_id = authz.current_user_profile_id()
      or authz.has_permission('master.user.manage')
    )
  );

create policy uom_select_authenticated on master.uom
  for select to authenticated using (deleted_at is null);

create policy uom_conversion_select_authenticated on master.uom_conversion
  for select to authenticated using (deleted_at is null);

create policy status_code_select_authenticated on master.status_code
  for select to authenticated using (deleted_at is null);

create policy reason_code_select_authenticated on master.reason_code
  for select to authenticated
  using (
    deleted_at is null
    and (plant_id is null or plant_id in (select authz.user_plant_ids()))
  );

create policy file_type_select_authenticated on master.file_type
  for select to authenticated using (deleted_at is null);

create policy notification_template_select_authenticated on master.notification_template
  for select to authenticated using (deleted_at is null);

create policy number_sequence_select_admin on master.number_sequence
  for select to authenticated
  using (
    deleted_at is null
    and plant_id in (select authz.user_plant_ids())
    and authz.has_permission('master.number_sequence.manage')
  );

create policy feature_flag_select_authenticated on config.feature_flag
  for select to authenticated using (deleted_at is null);

create policy system_setting_select_authenticated on config.system_setting
  for select to authenticated
  using (deleted_at is null and authz.has_permission('master.configure'));

create policy user_preference_select_own on config.user_preference
  for select to authenticated
  using (deleted_at is null and user_id = authz.current_user_profile_id());

create policy user_preference_write_own on config.user_preference
  for all to authenticated
  using (user_id = authz.current_user_profile_id())
  with check (user_id = authz.current_user_profile_id());

-- Manage policies (admin)
create policy plant_manage on master.plant
  for all to authenticated
  using (authz.has_permission('master.plant.manage'))
  with check (authz.has_permission('master.plant.manage'));

create policy role_manage on master.role
  for all to authenticated
  using (authz.has_permission('master.role.manage'))
  with check (authz.has_permission('master.role.manage'));

create policy permission_manage on master.permission
  for all to authenticated
  using (authz.has_permission('master.permission.manage'))
  with check (authz.has_permission('master.permission.manage'));

-- Module: AUTH (Phase 5)
-- Auth helpers: permissions list, menus for current user, session context
-- Signup trigger: create master.user_profile from auth.users

-- ---------------------------------------------------------------------------
-- List permission codes for current user
-- ---------------------------------------------------------------------------
create or replace function authz.my_permission_codes()
returns setof text
language sql
stable
security definer
set search_path = master, authz, public
as $$
  select distinct p.code
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
    and up.deleted_at is null;
$$;

-- ---------------------------------------------------------------------------
-- Menus visible to current user
-- Rule: active menu AND (no permission_code OR has that permission)
-- AND (no role_menu rows for any of user's roles OR menu assigned via role_menu
--      OR menu has no role_menu assignments at all → permission-only mode)
-- Simplified locked rule:
--   1) permission_code null OR has_permission(permission_code)
--   2) If ANY role_menu exists for this menu, user must have at least one matching role_menu
--      Else permission rule alone is enough
-- ---------------------------------------------------------------------------
create or replace function authz.my_menus()
returns table (
  id uuid,
  parent_id uuid,
  code text,
  label text,
  path text,
  icon text,
  sort_order integer,
  module text,
  permission_code text
)
language sql
stable
security definer
set search_path = master, authz, public
as $$
  with my_roles as (
    select ur.role_id
    from master.user_profile up
    join master.user_role ur
      on ur.user_id = up.id
     and ur.deleted_at is null
     and ur.is_active = true
    where up.auth_user_id = auth.uid()
      and up.deleted_at is null
  ),
  menus as (
    select m.*
    from master.menu m
    where m.deleted_at is null
      and m.is_active = true
      and (
        m.permission_code is null
        or authz.has_permission(m.permission_code)
      )
      and (
        not exists (
          select 1 from master.role_menu rm
          where rm.menu_id = m.id
            and rm.deleted_at is null
            and rm.is_active = true
        )
        or exists (
          select 1 from master.role_menu rm
          join my_roles mr on mr.role_id = rm.role_id
          where rm.menu_id = m.id
            and rm.deleted_at is null
            and rm.is_active = true
        )
      )
  )
  select
    menus.id,
    menus.parent_id,
    menus.code,
    menus.label,
    menus.path,
    menus.icon,
    menus.sort_order,
    menus.module,
    menus.permission_code
  from menus
  order by menus.sort_order, menus.label;
$$;

-- ---------------------------------------------------------------------------
-- Session context for Login / shell bootstrap
-- ---------------------------------------------------------------------------
create or replace function public.rpc_auth_session_context()
returns jsonb
language plpgsql
stable
security definer
set search_path = master, authz, public
as $$
declare
  v_profile master.user_profile%rowtype;
  v_roles text[];
  v_permissions text[];
  v_menus jsonb;
begin
  if auth.uid() is null then
    return jsonb_build_object('authenticated', false);
  end if;

  select *
    into v_profile
  from master.user_profile up
  where up.auth_user_id = auth.uid()
    and up.deleted_at is null
  limit 1;

  if v_profile.id is null then
    return jsonb_build_object(
      'authenticated', true,
      'profile', null,
      'roles', '[]'::jsonb,
      'permissions', '[]'::jsonb,
      'menus', '[]'::jsonb,
      'message', 'user_profile missing — complete onboarding'
    );
  end if;

  select coalesce(array_agg(distinct r.code order by r.code), '{}')
    into v_roles
  from master.user_role ur
  join master.role r on r.id = ur.role_id and r.deleted_at is null and r.is_active = true
  where ur.user_id = v_profile.id
    and ur.deleted_at is null
    and ur.is_active = true;

  select coalesce(array_agg(distinct x order by x), '{}')
    into v_permissions
  from authz.my_permission_codes() as x;

  select coalesce(jsonb_agg(to_jsonb(m) order by m.sort_order, m.label), '[]'::jsonb)
    into v_menus
  from authz.my_menus() m;

  return jsonb_build_object(
    'authenticated', true,
    'profile', jsonb_build_object(
      'id', v_profile.id,
      'employee_code', v_profile.employee_code,
      'display_name', v_profile.display_name,
      'email', v_profile.email,
      'default_plant_id', v_profile.default_plant_id,
      'locale', v_profile.locale,
      'theme_pref', v_profile.theme_pref,
      'sidebar_collapsed', v_profile.sidebar_collapsed
    ),
    'roles', to_jsonb(v_roles),
    'permissions', to_jsonb(v_permissions),
    'menus', v_menus
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Create profile on auth.users insert (Supabase Auth signup)
-- ---------------------------------------------------------------------------
create or replace function master.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = master, public
as $$
declare
  v_plant_id uuid;
  v_code text;
begin
  select id into v_plant_id
  from master.plant
  where code = 'SF1' and deleted_at is null
  limit 1;

  v_code := coalesce(
    new.raw_user_meta_data ->> 'employee_code',
    'U-' || substr(replace(new.id::text, '-', ''), 1, 8)
  );

  insert into master.user_profile (
    auth_user_id,
    employee_code,
    display_name,
    email,
    default_plant_id
  )
  values (
    new.id,
    v_code,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1), 'User'),
    coalesce(new.email, v_code || '@local'),
    v_plant_id
  )
  on conflict (auth_user_id) do nothing;

  return new;
end;
$$;

do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'auth' and table_name = 'users'
  ) then
    drop trigger if exists on_auth_user_created on auth.users;
    create trigger on_auth_user_created
      after insert on auth.users
      for each row execute function master.handle_new_auth_user();
  end if;
end $$;

-- Grants
revoke all on function authz.my_permission_codes() from public;
revoke all on function authz.my_menus() from public;
revoke all on function public.rpc_auth_session_context() from public;
revoke all on function master.handle_new_auth_user() from public;

grant execute on function authz.my_permission_codes() to authenticated, service_role;
grant execute on function authz.my_menus() to authenticated, service_role;
grant execute on function public.rpc_auth_session_context() to authenticated, anon, service_role;

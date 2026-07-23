-- Assign a platform role to an existing auth user by email.
-- Run in Supabase SQL Editor after creating the user in Authentication → Users.
--
-- Example:
--   SELECT master.assign_role_by_email('surasane.tho@gmail.com', 'admin');

create or replace function master.assign_role_by_email(p_email text, p_role_code text default 'admin')
returns uuid
language plpgsql
security definer
set search_path = master, public
as $$
declare
  v_user_id uuid;
  v_role_id uuid;
  v_link_id uuid;
begin
  select up.id
    into v_user_id
  from master.user_profile up
  where lower(up.email) = lower(trim(p_email))
    and up.deleted_at is null
  limit 1;

  if v_user_id is null then
    raise exception 'No user_profile for email %. Create the user in Supabase Auth first (trigger creates profile).', p_email;
  end if;

  select r.id
    into v_role_id
  from master.role r
  where r.code = lower(trim(p_role_code))
    and r.deleted_at is null
  limit 1;

  if v_role_id is null then
    raise exception 'Role not found: %', p_role_code;
  end if;

  insert into master.user_role (user_id, role_id, is_active)
  values (v_user_id, v_role_id, true)
  on conflict do nothing
  returning id into v_link_id;

  if v_link_id is null then
    select ur.id into v_link_id
    from master.user_role ur
    where ur.user_id = v_user_id
      and ur.role_id = v_role_id
      and ur.deleted_at is null
    limit 1;
  end if;

  return v_link_id;
end;
$$;

revoke all on function master.assign_role_by_email(text, text) from public;
grant execute on function master.assign_role_by_email(text, text) to service_role;

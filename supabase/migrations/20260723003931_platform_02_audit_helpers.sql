-- Module: PLATFORM
-- Audit helpers: updated_at trigger + shared comment conventions

create or replace function master.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function master.set_updated_at() is 'Maintains updated_at on row update';

-- Generic soft-delete helper (application may also set columns directly)
create or replace function master.soft_delete_row(
  p_schema text,
  p_table text,
  p_id uuid,
  p_deleted_by uuid
)
returns void
language plpgsql
security definer
set search_path = master, public
as $$
begin
  execute format(
    'update %I.%I
        set deleted_at = now(),
            deleted_by = $1,
            is_active = false,
            updated_at = now(),
            updated_by = $1,
            version = version + 1
      where id = $2
        and deleted_at is null',
    p_schema,
    p_table
  )
  using p_deleted_by, p_id;
end;
$$;

revoke all on function master.soft_delete_row(text, text, uuid, uuid) from public;
grant execute on function master.soft_delete_row(text, text, uuid, uuid) to service_role;

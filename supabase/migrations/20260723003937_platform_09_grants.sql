-- Module: PLATFORM
-- Table grants for Supabase roles (RLS still applies)

grant select, insert, update on all tables in schema master to authenticated;
grant select, insert, update on all tables in schema config to authenticated;
grant select on all tables in schema master to anon;
grant select on all tables in schema config to anon;

grant all on all tables in schema master to service_role;
grant all on all tables in schema config to service_role;

grant usage, select on all sequences in schema master to authenticated, service_role;
grant usage, select on all sequences in schema config to authenticated, service_role;

alter default privileges in schema master
  grant select, insert, update on tables to authenticated;
alter default privileges in schema config
  grant select, insert, update on tables to authenticated;

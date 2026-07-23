-- Module: CALENDAR & RESOURCES
-- Grants for new master/txn tables (RLS still applies)

grant select, insert, update on all tables in schema master to authenticated;
grant select, insert, update on all tables in schema txn to authenticated;
grant select on all tables in schema master to anon;
grant select on all tables in schema txn to anon;

grant all on all tables in schema master to service_role;
grant all on all tables in schema txn to service_role;

grant usage, select on all sequences in schema master to authenticated, service_role;
grant usage, select on all sequences in schema txn to authenticated, service_role;

alter default privileges in schema master
  grant select, insert, update on tables to authenticated;
alter default privileges in schema txn
  grant select, insert, update on tables to authenticated;

grant usage on schema txn to authenticated, anon, service_role;

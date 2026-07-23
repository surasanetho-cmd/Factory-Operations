-- Module: PRODUCT
-- Grants for new master tables

grant select, insert, update on all tables in schema master to authenticated;
grant select on all tables in schema master to anon;
grant all on all tables in schema master to service_role;
grant usage, select on all sequences in schema master to authenticated, service_role;

alter default privileges in schema master
  grant select, insert, update on tables to authenticated;

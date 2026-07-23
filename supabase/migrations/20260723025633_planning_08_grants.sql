-- Module: PLANNING
-- Grants

grant usage on schema txn to authenticated, anon, service_role;
grant usage on schema history to authenticated, service_role;

grant select, insert, update on all tables in schema txn to authenticated;
grant select on all tables in schema history to authenticated;
grant all on all tables in schema txn to service_role;
grant all on all tables in schema history to service_role;

grant usage, select on all sequences in schema txn to authenticated, service_role;
grant usage, select on all sequences in schema history to authenticated, service_role;

alter default privileges in schema txn
  grant select, insert, update on tables to authenticated;
alter default privileges in schema history
  grant select on tables to authenticated;

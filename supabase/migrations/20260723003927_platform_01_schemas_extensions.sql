-- Module: PLATFORM (1/N)
-- Migration: schemas + extensions
-- Compatible with Supabase PostgreSQL

create extension if not exists "pgcrypto";

create schema if not exists master;
create schema if not exists txn;
create schema if not exists history;
create schema if not exists log;
create schema if not exists config;
create schema if not exists integration;
create schema if not exists dashboard;
create schema if not exists authz;

comment on schema master is 'Master / reference data';
comment on schema txn is 'Operational transactions';
comment on schema history is 'Immutable historical records';
comment on schema log is 'Application, security, integration logs';
comment on schema config is 'System and feature configuration';
comment on schema integration is 'External sync, outbox, idempotency';
comment on schema dashboard is 'Dashboard layouts and widgets';
comment on schema authz is 'Private RLS helper functions';

-- Grants: authenticated can use schemas; authz execute granted later per function
grant usage on schema master to anon, authenticated, service_role;
grant usage on schema txn to anon, authenticated, service_role;
grant usage on schema history to anon, authenticated, service_role;
grant usage on schema log to anon, authenticated, service_role;
grant usage on schema config to anon, authenticated, service_role;
grant usage on schema integration to anon, authenticated, service_role;
grant usage on schema dashboard to anon, authenticated, service_role;
grant usage on schema authz to authenticated, service_role;

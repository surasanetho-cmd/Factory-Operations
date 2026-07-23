# Prompt — Database

**Use when:** schemas, tables, FKs, indexes, triggers, views, functions, seeds, migrations.

## Context to load first

1. `knowledge/00_Governance/PROJECT_CONSTITUTION.md`
2. `knowledge/20_Database/DATABASE_STANDARD.md`
3. `knowledge/20_Database/DATA_DICTIONARY.md`
4. `knowledge/20_Database/TABLE_RELATIONSHIP.md`
5. `knowledge/20_Database/INDEX_STANDARD.md`
6. `knowledge/20_Database/MIGRATION_PLAN.md`
7. `knowledge/99_ADR/ADR-004-SoftDelete.md`

## Task template

```text
Generate PostgreSQL SQL compatible with Supabase.

Create (as needed for this module only):
- Tables
- Constraints / CHECKs
- Foreign Keys (ON DELETE RESTRICT for masters)
- Indexes (partial unique for soft-delete codes)
- Triggers (updated_at via master.set_updated_at)
- Views (security_invoker active views)
- Functions / RPCs
- Seed data (idempotent where practical)
- Migration files in supabase/migrations/

Rules:
- One module at a time — do not invent the next module
- Schemas: master | txn | history | log | config | integration | dashboard | authz
- Pattern A Audit* on mutable business tables; J for junctions; H for history; E for workflow events
- No Postgres ENUMs for status — use master.status_code codes
- Plant-scoped tables include plant_id
- Update DATA_DICTIONARY / MIGRATION_PLAN when adding objects
```

## Acceptance checks

- [ ] Naming matches DATABASE_STANDARD
- [ ] Soft-delete columns present where required
- [ ] FKs and indexes named per convention
- [ ] Seed does not fail on re-run
- [ ] Migration timestamp ordered after existing files

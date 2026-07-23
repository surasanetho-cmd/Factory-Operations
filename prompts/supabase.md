# Prompt — Supabase

**Use when:** project linking, migrations apply, Auth, RLS, schema exposure, seeds, Management API.

## Context to load first

1. `knowledge/50_Integration/SUPABASE.md`
2. `knowledge/20_Database/MIGRATION_PLAN.md`
3. `knowledge/40_Backend/SECURITY.md`
4. `knowledge/99_ADR/ADR-001-Supabase.md`
5. `supabase/config.toml`
6. `supabase/migrations/`

## Task template

```text
Work against Supabase for Factory Operations.

Project (current): Factory-Operations / ilkzavjrjwjebcyitgaj / ap-south-1

Tasks may include:
- Add/apply migrations (forward-only)
- Enable RLS + policies using authz.* helpers
- Expose schemas on PostgREST (master, txn, history, config, …)
- Auth users → master.user_profile trigger
- Seed idempotent baseline data
- Verify with SQL counts / RPC smoke calls

Rules:
- Prefer migration files in repo over one-off undocumented SQL
- Record versions in supabase_migrations.schema_migrations when applying via API
- Never commit service role keys or PATs
- Custom tables live in master/txn/… — not only public
- After recreate project: re-apply all migrations in order, then retarget docs

Verify:
- information_schema / table counts
- seed rows (plant SF1, lines, plan PP-2026-W30 when planning present)
- rpc_auth_session_context / rpc_plan_* as applicable
```

## Acceptance checks

- [ ] Local migration files and remote history aligned
- [ ] RLS enabled on new exposed tables
- [ ] Grants for authenticated/service_role set
- [ ] `.env.local` not committed

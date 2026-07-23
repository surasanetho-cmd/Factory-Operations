# Prompt — Review

**Use when:** PR review, module review, docs/SQL/UI consistency check, Bugbot-style pass.

## Context to load first

1. `knowledge/00_Governance/PROJECT_CONSTITUTION.md`
2. `knowledge/10_Business/BUSINESS_RULES.md`
3. Relevant module under `knowledge/60_Module/`
4. `knowledge/20_Database/MIGRATION_PLAN.md`
5. Diff of the branch vs `main`

## Task template

```text
Review this change for Factory Operations.

Check:
1. Constitution compliance (soft delete, no hardcode, Calendar Engine, plant scope, RBAC)
2. Docs: knowledge/ updated if schema or behavior changed
3. SQL: naming, FKs, indexes, RLS, grants, idempotent seeds
4. App: no service role in client; permission checks; schema('master'|'txn') usage
5. Security: secrets not committed; .env.local ignored
6. Regressions: existing modules (Auth, Planning) still coherent

Output format:
- Verdict: Approve | Request changes
- Blockers (must fix)
- Risks / follow-ups (non-blocking)
- Test plan (3–7 bullets)
```

## Acceptance checks

- [ ] No invented tables outside dictionary without ADR
- [ ] No hard deletes of business rows
- [ ] No `if role === 'admin'` as sole authorization
- [ ] Migrations are forward-only on shared remotes

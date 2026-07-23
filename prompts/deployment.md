# Prompt — Deployment

**Use when:** Vercel deploy, env vars, GitHub main, Supabase remote, release checklist.

## Context to load first

1. `knowledge/50_Integration/SUPABASE.md`
2. `knowledge/50_Integration/MCP.md`
3. Legacy: `docs/60-deployment/21_DEPLOYMENT_STANDARD.md`
4. `README.md`
5. `.env.example`

## Task template

```text
Prepare / verify deployment for Factory Operations.

App: Next.js on Vercel
DB/Auth: Supabase project Factory-Operations
Repo: GitHub surasanetho-cmd/Factory-Operations

Checklist:
- [ ] main includes intended migrations + app
- [ ] Vercel env: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY
- [ ] SUPABASE_SERVICE_ROLE_KEY only on server (if used) — never NEXT_PUBLIC_
- [ ] Remote migrations applied (or CI db push documented)
- [ ] PostgREST schemas exposed if Studio/API needs master/txn
- [ ] Demo admin password rotated for shared environments
- [ ] Preview vs Production env separation understood

Do not:
- Commit .env.local or PATs
- Force-push main unless explicitly requested
- Apply destructive db reset on production
```

## Smoke after deploy

1. `/login` loads  
2. Sign-in works  
3. `/dashboard` shows session counts  
4. `/planning/plans` lists plans  

## Acceptance checks

- [ ] Env vars documented in `.env.example` without secrets
- [ ] Deployment notes added to CHANGELOG if release-worthy
- [ ] Rollback path identified (previous Vercel deployment / prior migration caution)

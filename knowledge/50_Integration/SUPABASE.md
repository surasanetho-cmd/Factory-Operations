<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# Supabase

**Product:** Smart-Factory Manufacturing Platform  
**Role:** System of record (PostgreSQL) + Auth + (optional) Storage

---

## 1. Project

| Field | Value |
|-------|-------|
| Name | Factory-Operations |
| Ref | `ilkzavjrjwjebcyitgaj` |
| Region | `ap-south-1` |

## 2. Schemas

`master`, `txn`, `history`, `log`, `config`, `integration`, `dashboard`, `authz`

Expose custom schemas on PostgREST for Data API / Studio when needed.

## 3. Auth

- Provider: Supabase Auth  
- App profile: `master.user_profile.auth_user_id` → `auth.users`  
- Trigger: create profile on signup  
- Session bootstrap RPC: `rpc_auth_session_context`

## 4. Keys

| Key | Use |
|-----|-----|
| Anon / publishable | Browser OK; RLS constrained |
| Service role | Server only — never `NEXT_PUBLIC_` |

## 5. Migrations

Path: `supabase/migrations/` · Plan: [MIGRATION_PLAN.md](../20_Database/MIGRATION_PLAN.md)

## 6. Local / remote

```bash
# Local (requires Docker)
npx supabase start
npx supabase db reset

# App env
NEXT_PUBLIC_SUPABASE_URL=https://<ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

## Related

- [SECURITY.md](../40_Backend/SECURITY.md)
- [MCP.md](MCP.md)
- [ADR-001-Supabase.md](../99_ADR/ADR-001-Supabase.md)

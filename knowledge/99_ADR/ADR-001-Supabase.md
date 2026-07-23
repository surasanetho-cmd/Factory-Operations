<!-- Canonical path: knowledge/ -->

# ADR-001 — Supabase as system of record

| Field | Value |
|-------|-------|
| Status | Accepted |
| Date | 2026-07 |

## Context

Need managed Postgres, Auth, and RLS-friendly API for a manufacturing platform on Vercel.

## Decision

Use **Supabase** (PostgreSQL + Auth). Custom schemas (`master`, `txn`, …). Migrations in `supabase/migrations/`.

## Consequences

- RLS + `authz` helpers are mandatory.  
- Service role never shipped to the browser.  
- Studio must select non-`public` schemas to see business tables.

## Related

- [SUPABASE.md](../50_Integration/SUPABASE.md)
- [SECURITY.md](../40_Backend/SECURITY.md)

# Prompt — API / Backend

**Use when:** Server Actions, route handlers, RPCs, domain services, authz helpers.

## Context to load first

1. `knowledge/40_Backend/API_STANDARD.md`
2. `knowledge/40_Backend/FOLDER_STRUCTURE.md`
3. `knowledge/40_Backend/SECURITY.md`
4. `knowledge/40_Backend/PERMISSION.md`
5. `knowledge/40_Backend/LOGGING.md`
6. Module doc under `knowledge/60_Module/`

## Task template

```text
Implement backend behavior for Factory Operations.

Prefer:
- Supabase RPC for transactional multi-step / permissioned mutations (planning workflow, drag-move)
- Server Components / Server Actions for reads and simple writes with createClient() from @/lib/supabase/server
- authz.has_permission* and plant scope via RLS + explicit permission checks

Rules:
- Authorize with permission codes (module.resource.action), not role name alone
- Never trust user_metadata for authorization
- Optimistic concurrency: require expected version where dictionary mandates
- Soft delete only; write history/outbox when the module standard requires it
- Validate inputs; return clear domain errors (version_conflict, invalid status transition)
- Service role only on trusted server paths — default to user-scoped client

Deliver:
- Code under src/lib/... and/or supabase/migrations for RPCs
- Types for request/response
- Short API notes if new public RPC names are introduced
```

## Acceptance checks

- [ ] Permission checked before mutation
- [ ] Plant scope respected
- [ ] No secrets logged
- [ ] Matches API_STANDARD error/version patterns where defined

# Template — New API / RPC / Server Action

**Standards:** `knowledge/40_Backend/API_STANDARD.md`, `PERMISSION.md`, `SECURITY.md`  
**Related prompt:** `prompts/api.md`

---

## Identity

| Field | Value |
|-------|-------|
| Kind | `RPC` / `Server Action` / `Route Handler` |
| Name | `<!-- e.g. rpc_plan_workflow / createPlan -->` |
| Module | |
| Auth | `authenticated` required: Yes / No |
| Permission(s) | `<!-- module.resource.action -->` |
| Plant scope | Yes / No |

---

## Purpose

<!-- What mutation or query does this expose? -->

## Contract

### Input

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| | | | |

### Output

```json
{
  "ok": true,
  "data": {}
}
```

### Errors

| Code / message | When |
|----------------|------|
| `not authenticated` | no session |
| `permission denied` | missing permission |
| `version_conflict` | optimistic lock fail |
| | invalid status transition |

## Side effects

- [ ] Writes `txn.*`
- [ ] Writes `history.*`
- [ ] Soft delete
- [ ] Outbox event (future)
- [ ] Increments `version`

## Implementation notes

| Layer | Location |
|-------|----------|
| SQL RPC | `supabase/migrations/…` |
| TS caller | `src/lib/…` or Server Action file |
| UI consumer | `src/app/…` |

## Security

- [ ] Uses user-scoped Supabase client by default
- [ ] Service role only if justified (document why)
- [ ] No auth from `user_metadata`
- [ ] Validates `expected_version` when required

## Test cases

1. Happy path  
2. Permission denied  
3. Version conflict / invalid state  

## Checklist

- [ ] Permission seeded + role matrix updated if new
- [ ] RLS still correct for underlying tables
- [ ] Documented in module knowledge doc
- [ ] No secrets in responses/logs

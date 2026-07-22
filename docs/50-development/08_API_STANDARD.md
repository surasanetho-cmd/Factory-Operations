# 08 — API Standard

**Product:** Smart-Factory Manufacturing Platform  
**Surface:** Next.js Route Handlers / Server Actions + Supabase (RLS)

---

## 1. Principles

1. **One capability, one API** — no duplicate endpoints for the same action.
2. **Database-backed authorization** — enforce via RLS + permission checks.
3. **Versioned contracts** — breaking changes require a new version or explicit ADR.
4. **Idempotent writes** where retries are likely (integrations, drag-drop save).
5. **No business secrets in responses**.

---

## 2. URL Conventions

| Style | Pattern | Example |
|-------|---------|---------|
| REST resources | `/api/v1/{module}/{resource}` | `/api/v1/plan/production-plans` |
| Nested | `/api/v1/{module}/{resource}/{id}/{child}` | `/api/v1/plan/production-plans/{id}/items` |
| Actions | `POST .../{id}/{action}` | `POST .../production-plans/{id}/approve` |
| Server Actions | Prefer for tightly coupled UI mutations in App Router; still obey same validation and permission rules |

Module codes match [07_MODULES.md](../20-architecture/07_MODULES.md).

---

## 3. HTTP Methods

| Method | Use |
|--------|-----|
| `GET` | Read lists/details |
| `POST` | Create or non-idempotent actions |
| `PATCH` | Partial update (includes drag-drop position changes) |
| `PUT` | Full replace (rare) |
| `DELETE` | Soft delete only (sets `deleted_at`) |

---

## 4. Request / Response Shape

### Success (single)

```json
{
  "data": { "id": "...", "version": 3 },
  "meta": { "request_id": "..." }
}
```

### Success (list)

```json
{
  "data": [ ],
  "meta": {
    "request_id": "...",
    "page": 1,
    "page_size": 50,
    "total": 120
  }
}
```

### Error

```json
{
  "error": {
    "code": "PLAN_VERSION_CONFLICT",
    "message": "Plan was updated by another user",
    "details": { "expected_version": 2, "actual_version": 3 }
  },
  "meta": { "request_id": "..." }
}
```

---

## 5. Pagination, Filter, Sort

- `page` (1-based), `page_size` (default 50, max 200)
- `sort` = `field:asc|desc`
- Filters as query params; never accept raw SQL
- Default filter: exclude soft-deleted (`deleted_at IS NULL`)

---

## 6. Concurrency

- Updates require `version` in body.
- On mismatch → `409` with entity-specific code (e.g. `PLAN_VERSION_CONFLICT`).
- Optional **plan lease** header/body (`lease_token`) when `config.feature_flag` `plan_lease` enabled — reduces multi-planner collision beyond optimistic locking ([04](../30-database/04_DATABASE_STANDARD.md)).

---

## 7. Idempotency

1. Header: `Idempotency-Key` (required for POST create and workflow actions that may retry).
2. Store: `integration.idempotency_key` with `key`, `user_id`, `route`, `request_hash`, `response_json`, `expires_at`.
3. Same key + same hash → replay stored response.
4. Same key + different hash → `409 IDEMPOTENCY_KEY_REUSE`.
5. Default TTL: 24h (configurable).

---

## 8. HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | Soft-deleted / no body |
| 400 | Validation error |
| 401 | Unauthenticated |
| 403 | Forbidden |
| 404 | Not found or soft-deleted hidden |
| 409 | Conflict (version / unique / idempotency) |
| 422 | Business rule / illegal state transition |
| 500 | Unexpected server error |

---

## 9. Error Code Registry (baseline)

| `error.code` | When |
|--------------|------|
| `VALIDATION_ERROR` | Schema/input invalid |
| `FORBIDDEN` | Permission denied |
| `NOT_FOUND` | Missing or soft-deleted |
| `PLAN_VERSION_CONFLICT` | Stale `version` |
| `ILLEGAL_STATE_TRANSITION` | Status machine violation |
| `CALENDAR_CONFLICT` | Holiday/shutdown/OT/capacity fit failure |
| `IDEMPOTENCY_KEY_REUSE` | Key reused with different body |
| `NUMBER_ALLOCATION_FAILED` | Sequence failure |

Extend in module specs; do not invent one-off codes for the same case.

---

## 10. Supabase RPC

Use RPC for complex calendar/capacity calculations: `engine_calendar_*`, `plan_*`. Document in module API specs when implemented.

---

## Related Documents

- [12_CODING_STANDARD.md](12_CODING_STANDARD.md)
- [14_SECURITY_STANDARD.md](../00-governance/14_SECURITY_STANDARD.md)
- [15_PERMISSION_STANDARD.md](../00-governance/15_PERMISSION_STANDARD.md)
- [32_STATUS_STATE_MACHINE.md](../30-database/32_STATUS_STATE_MACHINE.md)
- [34_DOMAIN_EVENTS.md](../20-architecture/34_DOMAIN_EVENTS.md)

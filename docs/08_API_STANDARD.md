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

Module codes match [07_MODULES.md](07_MODULES.md).

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
- On mismatch → `409` with `PLAN_VERSION_CONFLICT` (or entity-specific code).

---

## 7. Idempotency

- Optional header `Idempotency-Key` for POST create/actions.
- Store key in `integration` or `log` as appropriate for replay safety.

---

## 8. Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | Soft-deleted / no body |
| 400 | Validation error |
| 401 | Unauthenticated |
| 403 | Forbidden |
| 404 | Not found or soft-deleted hidden |
| 409 | Conflict (version / unique) |
| 422 | Business rule violation |
| 500 | Unexpected server error |

---

## 9. Supabase RPC

Use RPC for complex calendar/capacity calculations. RPC names: `engine_calendar_*`, `plan_*`. Document in module API specs when implemented.

---

## Related Documents

- [12_CODING_STANDARD.md](12_CODING_STANDARD.md)
- [14_SECURITY_STANDARD.md](14_SECURITY_STANDARD.md)
- [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md)

<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# Migration Plan

**Product:** Smart-Factory Manufacturing Platform  
**Engine:** Supabase PostgreSQL  
**Delivery rule:** One SQL module at a time; apply + review.

---

## 1. Module order

| # | Module | Status | Migration prefix |
|---|--------|--------|------------------|
| 1 | PLATFORM | Applied | `platform_*` |
| 2 | CALENDAR & RESOURCES | Applied | `calendar_*` |
| 3 | PRODUCT | Applied | `product_*` |
| 3b | AUTH / MENU | Applied | `auth_*` |
| 4 | PLANNING | Applied | `planning_*` |
| 5 | INTEGRATION / LOG / DASHBOARD | Pending | reserved |
| 6+ | Production / Store / OEE / … | Later | reserved |

Remote project: **Factory-Operations** (`ilkzavjrjwjebcyitgaj`, `ap-south-1`).

---

## 2. Location

```text
supabase/migrations/
```

Detailed trackers (legacy archive still authoritative for SQL lists):

- `/docs/30-database/50_SQL_MODULE_DELIVERY.md`
- `/docs/30-database/51_AUTH_MODULE_DELIVERY.md`
- `/docs/30-database/52_PLANNING_MODULE_DELIVERY.md`

---

## 3. Apply process

1. Add migration files with increasing timestamps.  
2. Apply to linked Supabase (CLI `db push` or Management SQL API).  
3. Record versions in `supabase_migrations.schema_migrations`.  
4. Verify seed + RPCs.  
5. Commit + push GitHub.

## 4. Principles

- Idempotent seeds where practical (`where not exists`).  
- Never rewrite applied migration history on shared remotes — add forward migrations.  
- Expose custom schemas (`master`, `txn`, …) on PostgREST when Studio/API must see them.

## Related

- [DATABASE_STANDARD.md](DATABASE_STANDARD.md)
- [SUPABASE.md](../50_Integration/SUPABASE.md)

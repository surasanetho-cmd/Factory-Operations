# 04 — Database Standard

**Product:** Smart-Factory Manufacturing Platform  
**Engine:** PostgreSQL (Supabase)

---

## 1. Domain Separation

Use dedicated PostgreSQL schemas (preferred) or enforced table prefixes. Canonical schemas:

| Schema | Purpose |
|--------|---------|
| `master` | Master / reference data |
| `txn` | Operational transactions |
| `history` | Immutable historical records |
| `log` | Application and security logs |
| `config` | System and feature configuration |
| `integration` | External system sync state |
| `dashboard` | Dashboard layouts and widgets |

`public` may hold views or compatibility wrappers only when necessary. Prefer domain schemas.

---

## 2. Mandatory Columns (Business Tables)

Every business table MUST include:

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | Primary key, default `gen_random_uuid()` |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Maintained by trigger or application |
| `created_by` | `uuid` | FK to user master / auth user |
| `updated_by` | `uuid` | FK to user master / auth user |
| `deleted_at` | `timestamptz` | Null when active |
| `deleted_by` | `uuid` | Set on soft delete |
| `is_active` | `boolean` | Default `true`; business enablement flag |
| `version` | `integer` | Optimistic concurrency; increment on update |

**Never hard delete** business rows. Soft delete only.

Append-only `history` and some `log` tables may omit `updated_*` / `deleted_*` when immutability is the rule — document exceptions in the dictionary and Decision Log.

---

## 3. Naming Conventions

| Object | Convention | Example |
|--------|------------|---------|
| Tables | `snake_case`, singular or consistent plural — **pick singular** | `master.machine` |
| Columns | `snake_case` | `production_line_id` |
| FK columns | `{referenced_table}_id` | `machine_id` |
| Unique business codes | `code` (text) + unique index where `deleted_at IS NULL` | `PL-110T` |
| Enums | Prefer lookup tables in `master` over Postgres enums for configurability | `master.reason_code` |

---

## 4. Keys and Relationships

1. PK = UUID.
2. All relationships use Foreign Keys.
3. Cascade: prefer `ON DELETE RESTRICT` / `NO ACTION` for masters referenced by transactions; soft-delete parents instead of cascading hard deletes.
4. Partial unique indexes: unique on `(code)` WHERE `deleted_at IS NULL`.

---

## 5. Soft Delete Rules

1. Soft delete sets `deleted_at`, `deleted_by`, and typically `is_active = false`.
2. Default queries filter `deleted_at IS NULL`.
3. Restores clear `deleted_at` / `deleted_by` and set `is_active` appropriately; bump `version`.
4. History records soft-delete events.

---

## 6. Versioning / Concurrency

1. Clients send expected `version` on update.
2. Server rejects stale versions (conflict).
3. Successful update increments `version` and writes history when required.

---

## 7. RLS and Security

1. Enable RLS on all exposed tables.
2. Policies align with [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md).
3. Do not authorize from editable `user_metadata`.
4. Service role key never ships to the browser.

See [14_SECURITY_STANDARD.md](14_SECURITY_STANDARD.md).

---

## 8. Seed and Configuration

- Production lines (110T–3200T), shifts, holidays, capacities, reason codes, file types, notification templates → **seed as master/config data**, not code constants.
- Feature toggles live in `config`.

---

## 9. Migration Discipline

1. Create migrations via Supabase CLI (`supabase migration new …`).
2. Update [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md) and [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md) in the same PR.
3. No duplicate tables for the same concept.

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [16_HISTORY_STANDARD.md](16_HISTORY_STANDARD.md)
- [17_LOG_STANDARD.md](17_LOG_STANDARD.md)
- [26_MASTER_DATA.md](26_MASTER_DATA.md)

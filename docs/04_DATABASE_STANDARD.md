# 04 — Database Standard

**Product:** Smart-Factory Manufacturing Platform  
**Engine:** PostgreSQL (Supabase)  
**Authority:** Mechanics live here. Binding laws live in [00_PROJECT_CONSTITUTION.md](00_PROJECT_CONSTITUTION.md).

---

## 1. Domain Separation (PostgreSQL Schemas Required)

**Decision:** Use real PostgreSQL schemas — **not** table-name prefixes. See ADR-008 in [29_DECISION_LOG.md](29_DECISION_LOG.md).

| Schema | Purpose |
|--------|---------|
| `master` | Master / reference data |
| `txn` | Operational transactions |
| `history` | Immutable historical records |
| `log` | Application and security logs |
| `config` | System and feature configuration |
| `integration` | External sync, outbox, idempotency |
| `dashboard` | Dashboard layouts and widgets |

`public` may hold views or compatibility wrappers only when necessary. Grant access carefully; prefer domain schemas for base tables.

---

## 2. Mandatory Columns (Business Tables)

Every **mutable business table** MUST include **Audit\***:

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK, default `gen_random_uuid()` |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Trigger or application |
| `created_by` | `uuid` | FK → `master.user_profile.id` |
| `updated_by` | `uuid` | FK → `master.user_profile.id` |
| `deleted_at` | `timestamptz` | Null when not deleted |
| `deleted_by` | `uuid` | FK → `master.user_profile.id` |
| `is_active` | `boolean` | Default `true` |
| `version` | `integer` | Optimistic concurrency; start at `1` |

**Never hard delete** business rows.

### 2.1 Audit\* Exceptions (document per table in dictionary)

| Pattern | Required columns | Omit |
|---------|------------------|------|
| Mutable business (`master.*`, most `txn.*`) | Full Audit\* | — |
| Append-only history | `id`, `created_at` (as `changed_at`), `created_by` (as `changed_by`), entity FK, snapshot fields | `updated_*`, `deleted_*`, `is_active`, live `version` bump |
| Append-only log | `id`, `created_at`, context columns | Full Audit\* |
| Junction (`role_permission`, `user_role`, `part_process`, `part_material`) | Full Audit\* **or** minimal `id`, `created_at`, `created_by` + soft-delete pair — choose one style per table and list in [05](05_DATABASE_DICTIONARY.md) | — |
| Action records (`plan_approval`, `plan_release`) | Full Audit\* preferred; action timestamps (`acted_at`) are additional, not replacements | — |

---

## 3. Naming Conventions

| Object | Convention | Example |
|--------|------------|---------|
| Tables | `snake_case`, **singular** | `master.machine` |
| Columns | `snake_case` | `production_line_id` |
| FK columns | `{referenced_table}_id` | `machine_id` |
| Business codes | `code` + partial unique where `deleted_at IS NULL` | `PL-110T` |
| Document numbers | `{entity}_no` — format in [31_NUMBERING_STANDARD.md](31_NUMBERING_STANDARD.md) | `plan_no` |
| Statuses | FK or code → `master.status_code` — [32_STATUS_STATE_MACHINE.md](32_STATUS_STATE_MACHINE.md) | — |
| Lookups | Prefer `master` tables over Postgres ENUMs | `master.uom`, `master.reason_code` |

---

## 4. Keys and Relationships

1. PK = UUID.
2. All relationships use Foreign Keys.
3. `created_by` / `updated_by` / `deleted_by` / `user_role.user_id` → **`master.user_profile.id` only** (never raw `auth.users.id` in business FKs).
4. `user_profile.auth_user_id` → `auth.users.id`, **UNIQUE NOT NULL**.
5. Cascade: `ON DELETE RESTRICT` / `NO ACTION` for masters referenced by transactions.
6. Partial unique indexes: `(code) WHERE deleted_at IS NULL` (scoped by plant when plant-owned — see [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md)).

### 4.1 Required uniqueness (baseline)

| Table | Unique when active |
|-------|-------------------|
| `master.user_profile` | `auth_user_id`; `employee_code` (per plant if multi-plant) |
| `master.role` / `permission` / many masters | `code` (+ `plant_id` when plant-scoped) |
| `master.role_permission` | `(role_id, permission_id)` |
| `master.user_role` | `(user_id, role_id)` |
| `master.holiday` | `(calendar_id, holiday_date)` |
| `txn.production_plan` | `plan_no` |
| `txn.sales_order` | `order_no` |

### 4.2 Capacity XOR rule

`master.capacity` MUST reference **exactly one** of:

- `production_line_id` (line-level capacity), **or**
- `machine_id` (machine-level capacity)

Enforce with `CHECK` (one null, one not null). Do not set both.

---

## 5. Soft Delete Rules

1. Set `deleted_at`, `deleted_by`, typically `is_active = false`.
2. Default queries: `deleted_at IS NULL`.
3. Restore clears delete fields, bumps `version`, writes history.
4. Soft delete ≠ legal erasure (see [14_SECURITY_STANDARD.md](14_SECURITY_STANDARD.md) retention).

---

## 6. Versioning / Concurrency

1. Clients send expected `version` on update.
2. Mismatch → conflict (`409`).
3. Success increments `version` and writes history when required.
4. For multi-planner boards, also support **optional plan lease / line lock** (config flag) — see [08_API_STANDARD.md](08_API_STANDARD.md). Optimistic version alone is insufficient at scale.

---

## 7. Indexes (Planning baseline)

Document indexes with tables; minimum for boards:

| Table | Index |
|-------|-------|
| `txn.production_plan_item` | `(production_plan_id)` WHERE `deleted_at IS NULL` |
| `txn.production_plan_item` | `(production_line_id, planned_start_at)` WHERE `deleted_at IS NULL` |
| `txn.production_plan_item` | `(machine_id, planned_start_at)` WHERE `deleted_at IS NULL` |
| `txn.production_plan_item` | `(planned_date)` WHERE `deleted_at IS NULL` |
| `txn.production_plan` | `(status)`, `(period_start, period_end)` |
| `master.holiday` | `(calendar_id, holiday_date)` |
| `history.*` | `(entity_id, changed_at DESC)` or specific FK |

---

## 8. RLS and Security

1. RLS on all exposed tables.
2. Policies use helpers in [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md).
3. Never authorize from editable `user_metadata`.
4. Service role never in browser.

---

## 9. Seed and Migration

1. Masters seeded via idempotent seeds — [26_MASTER_DATA.md](26_MASTER_DATA.md).
2. Migrations via `supabase migration new …` only.
3. Same PR updates [05](05_DATABASE_DICTIONARY.md) and [06](06_ER_DIAGRAM.md).
4. No duplicate tables for the same concept (reserved names in dictionary § future).

---

## 10. Scalability Notes

- Design with **`plant_id`** on plant-scoped masters/txns from day one ([33](33_PLANT_ORG_STANDARD.md)), even if Phase 1 seeds one plant.
- Plan for partitioning/archival of `history`, `log`, future `oee_sample`, `stock_movement`.
- Board projections / capacity aggregates are allowed read models — not duplicate systems of record ([34_DOMAIN_EVENTS.md](34_DOMAIN_EVENTS.md)).

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [16_HISTORY_STANDARD.md](16_HISTORY_STANDARD.md)
- [31_NUMBERING_STANDARD.md](31_NUMBERING_STANDARD.md)
- [32_STATUS_STATE_MACHINE.md](32_STATUS_STATE_MACHINE.md)
- [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md)
- [35_UOM_STANDARD.md](35_UOM_STANDARD.md)

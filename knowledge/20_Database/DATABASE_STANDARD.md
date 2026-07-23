<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 04 — Database Standard

**Product:** Smart-Factory Manufacturing Platform  
**Engine:** PostgreSQL (Supabase)  
**Authority:** Naming, Audit\*, soft-delete, keys.  
**Companions:** [05](05_DATABASE_DICTIONARY.md) · [06](06_ER_DIAGRAM.md) · [37](37_TABLE_RELATIONSHIPS.md) · [38](38_FOREIGN_KEYS.md) · [39](39_INDEX_STRATEGY.md)

---

## 1. Domain Separation (PostgreSQL Schemas Required)

| Schema | Purpose |
|--------|---------|
| `master` | Master / reference data |
| `txn` | Operational transactions |
| `history` | Immutable historical records |
| `log` | Application and security logs |
| `config` | System and feature configuration |
| `integration` | External sync, outbox, idempotency |
| `dashboard` | Dashboard layouts and widgets |
| `authz` | Private RLS helper functions (not exposed via Data API) |

`public` — views/wrappers only when necessary.

---

## 2. Naming Convention

### 2.1 General

| Object | Rule | Example |
|--------|------|---------|
| Schema | lowercase singular domain noun | `master`, `txn` |
| Table | `snake_case`, **singular** | `production_plan_item` |
| Column | `snake_case` | `planned_start_at` |
| Primary key | always `id` `uuid` | `id` |
| Foreign key column | `{referenced_table}_id` | `machine_id` → `master.machine` |
| Boolean | `is_` / `has_` prefix | `is_active`, `crosses_midnight` |
| Timestamp | `*_at` | `created_at`, `planned_end_at` |
| Date | `*_date` | `holiday_date`, `order_date` |
| Quantity | `qty_*` or `qty` | `qty_ordered` |
| JSON | `*_json` | `contact_json`, `payload_json` |
| Business code | `code` | line/machine/part codes |
| Document number | `{entity}_no` | `plan_no`, `order_no` |
| Status | `status_code` (text; lookup `master.status_code`) | `draft` |
| Soft delete | `deleted_at`, `deleted_by` | — |

### 2.2 Constraints & Indexes

| Object | Pattern | Example |
|--------|---------|---------|
| Primary key | `pk_{table}` | `pk_machine` |
| Foreign key | `fk_{table}_{column}` | `fk_machine_production_line_id` |
| Unique | `uq_{table}_{cols}` | `uq_production_line_plant_code` |
| Check | `ck_{table}_{rule}` | `ck_capacity_line_xor_machine` |
| Index | `ix_{table}_{cols}` | `ix_plan_item_line_start` |
| Partial unique | same + `_active` suffix when filtered | `uq_part_plant_code_active` |

### 2.3 Functions & Triggers

| Object | Pattern | Example |
|--------|---------|---------|
| Authz helper | `authz.{name}` | `authz.has_permission` |
| Calendar RPC | `engine_calendar_{action}` | `engine_calendar_check_fit` |
| `updated_at` trigger | `trg_{table}_set_updated_at` | — |
| Soft-delete guard | optional `trg_{table}_no_hard_delete` | — |

### 2.4 Status & Lookups

- Prefer `master.*` lookup tables over PostgreSQL `ENUM` types.
- `status_code` columns store the **code** string; must match `master.status_code` for the table’s `entity_type`.
- Do not use free-text UoM — use `uom_id`.

### 2.5 Reserved words

Avoid column names: `user`, `order`, `group`, `limit`, `offset` as bare identifiers — use `user_profile`, `sales_order`, etc.

---

## 3. Mandatory Columns (Audit\*)

Every **mutable business table** includes:

| Column | Type | Default / notes |
|--------|------|-----------------|
| `id` | `uuid` | PK, `gen_random_uuid()` |
| `created_at` | `timestamptz` | `now()` |
| `updated_at` | `timestamptz` | `now()`; maintained by trigger |
| `created_by` | `uuid` | FK → `master.user_profile.id` |
| `updated_by` | `uuid` | FK → `master.user_profile.id` |
| `deleted_at` | `timestamptz` | NULL = not deleted |
| `deleted_by` | `uuid` | FK → `master.user_profile.id` |
| `is_active` | `boolean` | `true` |
| `version` | `integer` | `1`; optimistic lock |

**Never hard delete** business rows.

### 3.1 Pattern codes (used in dictionary)

| Pattern | Columns |
|---------|---------|
| **A** (full Audit\*) | all nine columns above |
| **J** (junction) | `id`, `created_at`, `created_by`, `deleted_at`, `deleted_by`, `is_active` (no `version` / `updated_*` required) |
| **H** (history) | `id`, entity FK, `version`, `change_type`, `before_json`, `after_json`, `changed_fields`, `changed_at`, `changed_by` |
| **L** (log) | `id`, `created_at`, + event columns (no Audit\*) |
| **E** (append event with Audit\*) | full Audit\* + action-specific `acted_at` / `acted_by` |

---

## 4. Keys & Integrity

1. PK = UUID on every table.
2. All relationships declared as Foreign Keys — catalog [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md).
3. Business FKs for actors → `master.user_profile.id` only.
4. `user_profile.auth_user_id` → `auth.users(id)` UNIQUE NOT NULL.
5. Referenced masters: `ON DELETE RESTRICT` (soft-delete parent instead).
6. Optional children sometimes `ON DELETE CASCADE` only for pure owned dependents (e.g. widgets under layout) — listed explicitly in FK catalog.
7. Partial unique indexes for soft-deleted codes.

### CHECK rules (baseline)

| Constraint | Rule |
|------------|------|
| `ck_capacity_line_xor_machine` | exactly one of `production_line_id`, `machine_id` |
| `ck_ot_window_resource` | at least one of line/machine; prefer XOR same as capacity |
| `ck_shift_assignment_scope` | not both line and machine set |
| `ck_plan_item_time_order` | `planned_end_at` > `planned_start_at` |
| `ck_uom_conversion_positive` | `factor` > 0 |
| `ck_qty_non_negative` | quantities ≥ 0 |

---

## 5. Soft Delete & Concurrency

- Soft delete sets `deleted_at`, `deleted_by`, usually `is_active = false`.
- Default reads: `WHERE deleted_at IS NULL`.
- Updates require matching `version`; success increments `version`.
- Optional plan lease via feature flag ([08](../50-development/08_API_STANDARD.md)).

---

## 6. Index Strategy (summary)

Full catalog: [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md).

Principles:

1. Partial indexes on active rows (`deleted_at IS NULL`) for board/query paths.
2. Unique business keys as partial uniques.
3. Time-range access via `(resource_id, planned_start_at)` / `(start_at, end_at)`.
4. History/log ordered by `(entity_id, changed_at DESC)`.
5. Outbox worker: `(status_code, available_at)` WHERE pending.

---

## 7. RLS

Enable RLS on all exposed tables. Helpers in `authz` schema — [15_PERMISSION_STANDARD.md](../00-governance/15_PERMISSION_STANDARD.md).

---

## 8. Circular dependency: Plant ↔ Calendar

1. Insert `master.calendar` with `plant_id` (plant row may exist with `default_calendar_id` NULL).
2. Update `master.plant.default_calendar_id`.
3. FK `plant.default_calendar_id` → `calendar.id` is **DEFERRABLE** or applied after both rows exist.

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [37_TABLE_RELATIONSHIPS.md](37_TABLE_RELATIONSHIPS.md)
- [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)
- [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md)

# 40 — Database Architecture (Complete Design)

**Product:** Smart-Factory Manufacturing Platform  
**Status:** Module 1 (PLATFORM) SQL delivered — review before Module 2  
**Engine:** PostgreSQL (Supabase)  
**SQL location:** [`supabase/migrations/`](../../supabase/migrations/) · delivery notes: [50_SQL_MODULE_DELIVERY.md](50_SQL_MODULE_DELIVERY.md)

---

## 1. Purpose of this pack

This pack is the implementable database architecture derived from all `/docs` standards. It defines:

1. Module relationships  
2. Entity relationships  
3. Master / Transaction / History / Configuration / Log / Integration / Dashboard table lists  
4. Per-table: Purpose, Relationships, PK, FKs, Indexes, Scalability, Soft Delete, Audit  
5. Data Dictionary — [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

**Do not generate the next module’s SQL until Module 1 is reviewed.**

---

## 2. Architecture principles (locked)

| Principle | Rule |
|-----------|------|
| Schemas | Real Postgres schemas: `master`, `txn`, `history`, `log`, `config`, `integration`, `dashboard` (+ `authz` helpers) |
| PK | UUID `id` on every table |
| Soft delete | Never hard-delete business data |
| Audit\* | Mutable business tables use full audit set |
| Plant | `plant_id` on plant-scoped data from day one |
| Config over hardcode | Lines, shifts, statuses, sequences, templates in DB |
| Expansion | Future modules add tables; do not rewrite core patterns |

Standards: [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)

---

## 3. Shared patterns (referenced by every table)

### 3.1 Audit pattern **A** (mutable business)

Columns: `id`, `created_at`, `updated_at`, `created_by`, `updated_by`, `deleted_at`, `deleted_by`, `is_active`, `version`  
Actors FK → `master.user_profile.id`  
Strategy: bump `version` on update; write history when required.

### 3.2 Junction pattern **J**

Minimal: `id`, `created_at`, `created_by`, `deleted_at`, `deleted_by`, `is_active`  
Soft-delete junctions instead of hard-delete.

### 3.3 History pattern **H**

Append-only: `id`, entity FK, `version`, `change_type`, `before_json`, `after_json`, `changed_fields`, `changed_at`, `changed_by`  
Never update/delete history rows.

### 3.4 Log pattern **L**

Append-only operational events: `id`, `created_at`, + event fields. No soft delete; retention/archive instead.

### 3.5 Soft delete strategy (default)

1. Set `deleted_at`, `deleted_by`; set `is_active = false`  
2. Default queries: `WHERE deleted_at IS NULL`  
3. Partial unique indexes on business keys for active rows only  
4. Soft delete ≠ legal erasure ([14](../00-governance/14_SECURITY_STANDARD.md))

### 3.6 Index naming

`pk_*`, `fk_*`, `uq_*_active`, `ix_*` — [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md)

---

## 4. Document map

| # | Document | Content |
|---|----------|---------|
| 1 | [41_MODULE_RELATIONSHIPS.md](41_MODULE_RELATIONSHIPS.md) | Module ↔ schema ownership |
| 2 | [42_ENTITY_RELATIONSHIPS.md](42_ENTITY_RELATIONSHIPS.md) | Cross-entity ER overview |
| 3 | [43_MASTER_DATA_LIST.md](43_MASTER_DATA_LIST.md) | All `master.*` tables |
| 4 | [44_TRANSACTION_LIST.md](44_TRANSACTION_LIST.md) | All `txn.*` tables |
| 5 | [45_HISTORY_LIST.md](45_HISTORY_LIST.md) | All `history.*` tables |
| 6 | [46_CONFIGURATION_LIST.md](46_CONFIGURATION_LIST.md) | All `config.*` tables |
| 7 | [47_LOG_LIST.md](47_LOG_LIST.md) | All `log.*` tables |
| 8 | [48_INTEGRATION_LIST.md](48_INTEGRATION_LIST.md) | All `integration.*` tables |
| 9 | [49_DASHBOARD_LIST.md](49_DASHBOARD_LIST.md) | All `dashboard.*` tables |
| — | [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md) | Column-level dictionary |
| — | [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md) | FK catalog |
| — | [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md) | Index catalog |

---

## 5. Schema ownership summary

| Schema | Owns | Consumers |
|--------|------|-----------|
| `master` | Reference data | All modules |
| `txn` | Operational documents | Planning now; Production/Store/… later |
| `history` | Immutable change snapshots | Audit, compliance |
| `log` | Runtime / security / integration logs | Ops |
| `config` | Settings, flags, extensible prefs | Platform |
| `integration` | Outbox, sync, files, idempotency | Adapters |
| `dashboard` | Layouts / widgets | Dashboard module |

---

## 6. Review gate

Before SQL:

- [ ] Module relationships approved  
- [ ] Entity relationships approved  
- [ ] Table lists complete for Phase 1 + reserved future names  
- [ ] Per-table PK/FK/index/soft-delete/audit accepted  
- [ ] Data dictionary matches lists  
- [ ] Explicit go-ahead to generate migrations  

---

## Related Documents

- [41_MODULE_RELATIONSHIPS.md](41_MODULE_RELATIONSHIPS.md)
- [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)
- [../99-changelog/29_DECISION_LOG.md](../99-changelog/29_DECISION_LOG.md)

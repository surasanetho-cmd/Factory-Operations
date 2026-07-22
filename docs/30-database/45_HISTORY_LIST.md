# 45 — History List

**Schema:** `history`  
**Part of:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Standard:** [16_HISTORY_STANDARD.md](../00-governance/16_HISTORY_STANDARD.md)  
**Pattern:** **H** append-only — **no soft delete, no update**.  
**No SQL yet.**

---

## Inventory

| Table | Source entity |
|-------|---------------|
| `production_plan_history` | `txn.production_plan` |
| `production_plan_item_history` | `txn.production_plan_item` |
| `entity_change` | Generic cross-cutting |

---

### `history.production_plan_history`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Immutable snapshots of plan header create/update/status/soft-delete. |
| **Relationships** | N:1 production_plan; changed_by → user_profile. |
| **PK** | `id` UUID |
| **FKs** | `production_plan_id` → plan; `changed_by` → user_profile |
| **Indexes** | `ix (production_plan_id, changed_at DESC)` |
| **Future scalability** | Partition/archive by `changed_at`; retain long for compliance. |
| **Soft Delete Strategy** | **None** — never delete history rows. Retention = archive, not delete. |
| **Audit Strategy** | Row **is** the audit; `version` = live version after change; one row per successful mutation. |

### `history.production_plan_item_history`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Immutable snapshots for item edits and drag-drop reschedules. |
| **Relationships** | N:1 production_plan_item; changed_by → user_profile. |
| **PK** | `id` UUID |
| **FKs** | `production_plan_item_id`; `changed_by` |
| **Indexes** | `ix (production_plan_item_id, changed_at DESC)` |
| **Future scalability** | Highest volume history table in Phase 1; archive cold partitions. |
| **Soft Delete Strategy** | None |
| **Audit Strategy** | Pattern **H**; include before/after timestamps and resource ids in JSON |

### `history.entity_change`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Generic change log for masters/config not given dedicated history tables. |
| **Relationships** | Logical polymorphic (`entity_type`, `entity_id`); optional changed_by. |
| **PK** | `id` UUID |
| **FKs** | `changed_by` → user_profile (N) |
| **Indexes** | `ix (entity_type, entity_id, changed_at DESC)` |
| **Future scalability** | Prefer dedicated history tables when volume/query patterns justify. |
| **Soft Delete Strategy** | None |
| **Audit Strategy** | Pattern **H** |

---

## Rules

1. Application must not UPDATE/DELETE history.  
2. Soft delete of live entity → insert history with `change_type = soft_delete`.  
3. Outbox events complement history; they are not a substitute for snapshots.

---

## Related Documents

- [16_HISTORY_STANDARD.md](../00-governance/16_HISTORY_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md)

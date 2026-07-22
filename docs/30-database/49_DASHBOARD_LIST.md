# 49 — Dashboard List

**Schema:** `dashboard`  
**Part of:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Pattern:** **A**  
**No SQL yet.**

---

## Inventory

| Table | Purpose summary |
|-------|-----------------|
| `layout` | Saved dashboard layout (user/role/plant) |
| `widget` | Widget instances on a layout |

---

### `dashboard.layout`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Persisted dashboard layout ownership and scope. |
| **Relationships** | Optional user, role, plant; 1:N widgets. |
| **PK** | `id` UUID |
| **FKs** | user_id, role_id, plant_id |
| **Indexes** | ix user_id; ix plant_id |
| **Future scalability** | Role-default layouts + user overrides; plant-specific KPI boards. |
| **Soft Delete Strategy** | A — soft delete layout; widgets cascade soft or removed in domain service. |
| **Audit Strategy** | A |

### `dashboard.widget`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Positioned widget bound to a registered `query_key` (read-model), not ad-hoc SQL. |
| **Relationships** | N:1 layout (**ON DELETE CASCADE** for hard orphan prevention if layout row removed — prefer soft-delete layout and filter widgets). |
| **PK** | `id` UUID |
| **FKs** | layout_id → layout |
| **Indexes** | ix layout_id |
| **Future scalability** | Widget types grow via code registry; config_json for per-widget options; resize persisted. |
| **Soft Delete Strategy** | A |
| **Audit Strategy** | A |

---

## Rules

1. `query_key` must reference an allow-listed read model / projection.  
2. Dashboard tables are **not** systems of record for plans/OEE — they store presentation state.  
3. Capacity/OEE charts read projections fed by outbox consumers ([34](../20-architecture/34_DOMAIN_EVENTS.md)).

---

## Related Documents

- [09_UI_STANDARD.md](../40-uiux/09_UI_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md)

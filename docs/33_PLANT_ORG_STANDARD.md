# 33 — Plant & Organization Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Why Plant Exists From Day One

Even if Phase 1 operates a **single plant**, omitting `plant_id` forces a breaking schema rewrite when a second site, SAP org unit, or plant-scoped calendar appears. Constitution A3 requires expand-without-rewrite.

---

## 2. Hierarchy

```text
Plant
  └── Department (tree)
  └── Production Line
        └── Machine
  └── Calendars / Shifts / Capacities (plant-scoped)
  └── Transactions (orders, plans, …)
```

Optional future levels (Area / Work Center) may be added **under** plant without replacing it.

---

## 3. Tables

| Table | Role |
|-------|------|
| `master.plant` | Site root; `default_calendar_id`, `timezone` |
| `master.department` | `plant_id` + `parent_id` |
| Plant-scoped masters | `production_line`, `machine`, `shift`, `capacity`, … |
| Plant-scoped txns | `sales_order`, `production_plan`, `ot_window`, … |
| `master.user_role.plant_id` | Optional scope for role assignment |

---

## 4. RLS Strategy

1. User has `default_plant_id` and optional multi-plant role grants.
2. Helper: `authz_user_plant_ids()` → set of allowed plants.
3. Policies: `plant_id IS NULL OR plant_id IN (authz_user_plant_ids())` for global vs scoped rows.
4. Phase 1 seed: one plant; all users granted that plant.

---

## 5. Calendar & Timezone

- Plant has default calendar and timezone.
- Resource calendar resolution: [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md).

---

## 6. Numbering & Integrations

- Document numbers include plant prefix ([31](31_NUMBERING_STANDARD.md)).
- SAP / Drive / Telegram mappings are plant-aware via `integration.id_map` + connection config.

---

## 7. Phase 1 Seed

| code | name |
|------|------|
| `SF1` | Smart-Factory Plant 1 |

All six production lines belong to `SF1`.

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md)
- [26_MASTER_DATA.md](26_MASTER_DATA.md)

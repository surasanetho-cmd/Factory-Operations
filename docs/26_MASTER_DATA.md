# 26 — Master Data

**Product:** Smart-Factory Manufacturing Platform  
**Rule:** Design and seed masters before transactions.

---

## 1. Master Catalog

| Master | Table | Phase 1 required |
|--------|-------|------------------|
| Users | `master.user_profile` | Yes |
| Roles | `master.role` | Yes |
| Permissions | `master.permission` | Yes |
| Department | `master.department` | Yes |
| Customer | `master.customer` | Yes |
| Part List | `master.part` | Yes |
| Material | `master.material` | Yes |
| Process | `master.process` | Yes |
| Machine | `master.machine` | Yes |
| Production Line | `master.production_line` | Yes |
| Shift | `master.shift` | Yes |
| Calendar | `master.calendar` | Yes |
| Holiday | `master.holiday` | Yes |
| Capacity | `master.capacity` | Yes |
| Reason Code | `master.reason_code` | Yes |
| File Type | `master.file_type` | Yes (seed even if Drive later) |
| Notification Template | `master.notification_template` | Yes (seed for Telegram later) |

Junctions: `role_permission`, `user_role`, `part_process`.

---

## 2. Production Lines (seed)

| code | name | tonnage |
|------|------|---------|
| `PL-110T` | 110 Ton | 110 |
| `PL-250T` | 250 Ton | 250 |
| `PL-300T` | 300 Ton | 300 |
| `PL-600T` | 600 Ton | 600 |
| `PL-800T` | 800 Ton | 800 |
| `PL-3200T` | 3200 Ton | 3200 |

Machines belong to lines; capacity defaults should reflect ~20–30 jobs/day planning envelope (exact numbers seeded and editable).

---

## 3. Relationships (summary)

```text
Department → Users → Roles → Permissions
Customer → Parts → Part_Process → Process
Production_Line → Machines
Calendar → Holidays
Capacity → (Line|Machine) + Shift
```

---

## 4. Governance

1. Masters are soft-deleted, never hard-deleted.
2. Codes are stable identifiers for integrations.
3. Changing capacity/shifts is configuration — audit via history when impacting open plans.
4. UI admin screens manage masters; no deploy required for routine value changes.

---

## 5. Seed Ownership

- `supabase/seed` (future) holds baseline JSON/SQL.
- Environment-specific holidays may differ; keep structure identical.

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md)
- [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md)
- [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md)

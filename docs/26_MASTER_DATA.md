# 26 — Master Data

**Product:** Smart-Factory Manufacturing Platform  
**Rule:** Design and seed masters before transactions.  
**Column authority:** [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md).  
**Plant:** [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md).  
**Codes:** [31_NUMBERING_STANDARD.md](31_NUMBERING_STANDARD.md).  
**UoM:** [35_UOM_STANDARD.md](35_UOM_STANDARD.md).

---

## 1. Master Catalog (Phase 1 required)

| Master | Table |
|--------|-------|
| Plant | `master.plant` |
| Users | `master.user_profile` |
| Roles / Permissions | `master.role`, `master.permission`, junctions |
| Department | `master.department` |
| UoM | `master.uom`, `master.uom_conversion` |
| Customer / Part / Material / BOM | `customer`, `part`, `material`, `part_material` |
| Process / Routing | `process`, `part_process` |
| Machine / Production Line | `machine`, `production_line` |
| Shift / Assignment | `shift`, `shift_assignment` |
| Calendar / Holiday | `calendar`, `holiday` |
| Capacity | `capacity` (XOR line/machine) |
| Status codes | `status_code` |
| Reason / File type / Notification / Number sequence | respective masters |

---

## 2. Seed — Plant & Lines

**Plant:** `SF1` — Smart-Factory Plant 1

| code | name | tonnage |
|------|------|---------|
| `PL-110T` | 110 Ton | 110 |
| `PL-250T` | 250 Ton | 250 |
| `PL-300T` | 300 Ton | 300 |
| `PL-600T` | 600 Ton | 600 |
| `PL-800T` | 800 Ton | 800 |
| `PL-3200T` | 3200 Ton | 3200 |

Capacity defaults should reflect the planning envelope of ~20–30 jobs/day/line (editable in DB). Volume KPI: [01_PROJECT_VISION.md](01_PROJECT_VISION.md).

---

## 3. Relationships (summary)

```text
Plant → Departments, Lines, Machines, Calendars, Shifts, Txns
Part → part_material → Material (BOM)
Part → part_process → Process
Line/Machine → calendar_id → Calendar → Holidays
Capacity → (Line XOR Machine) + Shift
```

---

## 4. Governance

1. Soft delete only; codes stable for integrations.
2. Capacity/shift changes audited when open plans exist.
3. Idempotent seeds in `supabase/seed` (future); freeze production-line codes.
4. No hardcode of seed values in UI.

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md)
- [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md)
- [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md)

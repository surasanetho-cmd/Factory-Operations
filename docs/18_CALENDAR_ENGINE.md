# 18 — Calendar Engine

**Product:** Smart-Factory Manufacturing Platform  
**Role:** Single shared engine for time, capacity, and resource availability

---

## 1. Mandate

One Calendar Engine is used by:

- Planning
- Production
- Store
- OEE
- Dashboard

Modules must not invent private holiday/shift logic.

---

## 2. Capabilities

| Capability | Description |
|------------|-------------|
| Working Day | Resolve if a date is workable for a calendar |
| Holiday | Master holidays applied to calendars |
| Shift | Shift templates and assignments |
| OT | Overtime windows beyond standard shift |
| Machine Shutdown | Unavailability blocks |
| Maintenance | Maintenance windows (from Maintenance module later) |
| Capacity | Nominal and effective capacity per line/machine/shift |
| Timeline | Continuous time axis for boards |
| Resource | Resource-oriented lanes (machine/line) |

---

## 3. Domain Inputs (Master + Txn)

**Masters:** `calendar`, `holiday`, `shift`, `capacity`, `production_line`, `machine`  
**Future txn inputs:** shutdown events, maintenance orders, OT requests/approvals

Effective availability = base shift hours − holidays − shutdowns − maintenance + approved OT.

---

## 4. Day Types

| Type | UI treatment |
|------|--------------|
| `working` | Normal grid |
| `holiday` | Muted / blocked for standard work |
| `partial` | Shortened shift |
| `shutdown` | Blocked for machine/line |
| `ot` | Extended band |

---

## 5. Engine API (logical)

| Function | Result |
|----------|--------|
| `resolveDay(calendarId, date)` | Day type + windows |
| `listWindows(resource, from, to)` | Available intervals |
| `getCapacity(resource, date, shiftId?)` | Jobs/hours available |
| `checkFit(resource, start, end, qty)` | Feasible? conflicts? |
| `timeline(resources[], from, to)` | Board projection DTO |

Implement as server domain service and/or Postgres RPC (`engine_calendar_*`).

---

## 6. Planning Integration

1. Drag-drop calls `checkFit` before persist (or persist + validate transactionally).
2. Weekly/monthly views aggregate `getCapacity` vs planned load.
3. Release blocked when unresolved conflicts exist (policy configurable).

---

## 7. Timezone

- Each `master.calendar` has a timezone.
- Plant default calendar applies when resource-specific calendar absent.
- Store all timestamps as `timestamptz`; display in calendar/user timezone.

---

## 8. Non-Goals

- Payroll OT calculation (beyond planning windows)
- Hardware machine PLC clocks (future OEE adapters feed events in)

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [07_MODULES.md](07_MODULES.md)
- [28_SCREEN_FLOW.md](28_SCREEN_FLOW.md)
- [10_DESIGN_SYSTEM.md](10_DESIGN_SYSTEM.md)

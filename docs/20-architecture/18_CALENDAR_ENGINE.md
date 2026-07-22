# 18 — Calendar Engine

**Product:** Smart-Factory Manufacturing Platform  
**Role:** Single shared engine for time, capacity, and resource availability  
**Law:** Constitution A4 — modules must not fork holiday/shift logic.

---

## 1. Consumers

Planning, Production, Store, OEE, Dashboard (and Maintenance as a writer of windows).

---

## 2. Capabilities

| Capability | Description |
|------------|-------------|
| Working Day | Resolve if a date is workable for a calendar |
| Holiday | From `master.holiday` |
| Shift | Templates + `master.shift_assignment` |
| OT | From `txn.ot_window` (approved) |
| Machine Shutdown | From `txn.machine_shutdown` |
| Maintenance | From Maintenance module windows (future) |
| Capacity | From `master.capacity` (XOR line/machine) |
| Timeline | Board time axis DTO |
| Resource | Lanes for line/machine (crew later) |

---

## 3. Inputs (locked table names)

| Kind | Table |
|------|-------|
| Calendar | `master.calendar`, `master.holiday` |
| Shift | `master.shift`, `master.shift_assignment` |
| Capacity | `master.capacity` |
| Line / machine | `master.production_line`, `master.machine` |
| Plant default | `master.plant.default_calendar_id` |
| OT | `txn.ot_window` |
| Shutdown | `txn.machine_shutdown` |
| Maintenance | `txn.maintenance_order` (future feed) |

Effective availability ≈ assigned shift windows − holidays − shutdowns − maintenance + approved OT.

---

## 4. Calendar Resolution Order

For a resource (machine preferred, else line):

1. `machine.calendar_id` if set  
2. Else `production_line.calendar_id` if set  
3. Else `plant.default_calendar_id`  
4. Else error (misconfiguration)

Timezone for display/resolution comes from the resolved calendar (not the browser alone).

---

## 5. Day Types

| Type | Meaning |
|------|---------|
| `working` | Standard work |
| `holiday` | Non-working / blocked for standard plan |
| `partial` | Shortened shift |
| `shutdown` | Resource unavailable |
| `ot` | Extended band beyond shift |

---

## 6. Engine API (logical)

| Function | Result |
|----------|--------|
| `resolveCalendar(resource)` | calendar id + timezone |
| `resolveDay(calendarId, date)` | Day type + windows |
| `listWindows(resource, from, to)` | Available intervals |
| `getCapacity(resource, date, shiftId?)` | Jobs/hours available |
| `checkFit(resource, start, end, qty)` | Feasible + conflicts |
| `timeline(resources[], from, to)` | Board projection DTO |

Implement as domain service and/or RPC `engine_calendar_*`.

---

## 7. Timezone & DST

1. Persist all instants as `timestamptz`.
2. Civil dates (`planned_date`, holidays) are calendar-local dates.
3. Shifts with `crosses_midnight = true` span two civil dates in local TZ.
4. Engine must be DST-safe (use TZ-aware libraries / Postgres TZ).

---

## 8. Planning Integration

1. Drag-drop: `checkFit` then versioned persist + history.
2. Aggregate capacity for week/month views.
3. Release policy: block or warn on conflicts (`config.feature_flag` / settings).

---

## 9. Performance & Scale

| Concern | Guidance |
|---------|----------|
| Board volume | ~20–30 jobs/line/day × 6 lines; month view ≈ thousands of items |
| Caching | Cache resolved day windows per `(calendarId, date)` and resource windows per range; invalidate on holiday/shift/OT/shutdown writes |
| Read models | Optional `dashboard` / projection tables for capacity aggregates — fed by domain events ([34](34_DOMAIN_EVENTS.md)) |
| Hot path | Do not recompute full-plant calendar from scratch per pixel drag |

---

## 10. Non-Goals

- Payroll OT money calculation
- PLC clock sync (OEE adapters publish events later)

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](../30-database/05_DATABASE_DICTIONARY.md)
- [33_PLANT_ORG_STANDARD.md](../30-database/33_PLANT_ORG_STANDARD.md)
- [28_SCREEN_FLOW.md](../40-uiux/28_SCREEN_FLOW.md)
- [10_DESIGN_SYSTEM.md](../40-uiux/10_DESIGN_SYSTEM.md)

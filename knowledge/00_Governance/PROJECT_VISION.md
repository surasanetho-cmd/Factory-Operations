<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 01 — Project Vision

**Product:** Smart-Factory Manufacturing Platform  
**Current Phase:** Production Planning

---

## 1. Purpose

Smart-Factory is an enterprise manufacturing platform that plans, executes, measures, and improves production. It starts with **Production Planning** and expands into Production, Warehouse, OEE, Quality, Maintenance, Dashboard, and integrations **without rewriting** the core database architecture.

---

## 2. Business Context

### Production lines (current)

| Line | Class |
|------|-------|
| 110 Ton | Press / forming |
| 250 Ton | Press / forming |
| 300 Ton | Press / forming |
| 600 Ton | Press / forming |
| 800 Ton | Press / forming |
| 3200 Ton | Press / forming |

**Volume KPI:** each line ≈ **20–30 jobs/day**. Planning UX and indexes must remain usable across all lines for day/week/month horizons.

Canonical seed codes: [26_MASTER_DATA.md](26_MASTER_DATA.md). Plant: [33_PLANT_ORG_STANDARD.md](../30-database/33_PLANT_ORG_STANDARD.md).

---

## 3. Planning Capabilities (Phase 1)

Daily / weekly / monthly planning; capacity, machine, and shift planning; holiday and OT awareness; drag-and-drop; calendar timeline; resource view; hooks for future OEE and Store.

Engine: [18_CALENDAR_ENGINE.md](../20-architecture/18_CALENDAR_ENGINE.md). Screens: [28_SCREEN_FLOW.md](../40-uiux/28_SCREEN_FLOW.md).

---

## 4. End-to-End Flow

Authoritative workflow: [27_BUSINESS_FLOW.md](27_BUSINESS_FLOW.md).

```text
Order → Planning → Approve → Release → Production → QC → Store → Shipping
```

Phase 1 implements through **Release**.

---

## 5. Future Modules

Module catalog and ownership: [07_MODULES.md](../20-architecture/07_MODULES.md).  
Phased delivery: [24_ROADMAP.md](24_ROADMAP.md).

---

## 6. Success Criteria (Planning Phase)

1. All lines schedulable without hardcoded line lists.
2. Capacity / machine / shift constraints visible before release.
3. Holidays, OT, shutdowns from Calendar Engine.
4. Drag-and-drop persists with audit history and versioning.
5. New modules attach to masters, plant, calendar, and events without schema redesign.

---

## 7. Non-Goals (Phase 1)

Full MES UI, live OEE hardware, complete SAP sync, AI auto-scheduling as primary planner — see roadmap.

---

## Related Documents

- [00_PROJECT_CONSTITUTION.md](../00-governance/00_PROJECT_CONSTITUTION.md)
- [07_MODULES.md](../20-architecture/07_MODULES.md)
- [27_BUSINESS_FLOW.md](27_BUSINESS_FLOW.md)
- [24_ROADMAP.md](24_ROADMAP.md)
- [36_DOCUMENTATION_REVIEW.md](../99-changelog/36_DOCUMENTATION_REVIEW.md)

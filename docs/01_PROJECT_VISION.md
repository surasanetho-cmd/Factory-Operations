# 01 — Project Vision

**Product:** Smart-Factory Manufacturing Platform  
**Current Phase:** Production Planning

---

## 1. Purpose

Smart-Factory is an enterprise manufacturing platform that plans, executes, measures, and improves production operations. It starts with **Production Planning** and expands into Production, Warehouse, OEE, Quality, Maintenance, Dashboard, and external integrations without changing the core database architecture.

---

## 2. Business Context

### Production Lines (current)

| Line | Capacity Class |
|------|----------------|
| 110 Ton | Press / forming line |
| 250 Ton | Press / forming line |
| 300 Ton | Press / forming line |
| 600 Ton | Press / forming line |
| 800 Ton | Press / forming line |
| 3200 Ton | Press / forming line |

Each line produces approximately **20–30 jobs per day**. Planning must remain usable at that volume across all lines simultaneously.

---

## 3. Planning Capabilities (Phase 1)

Planning must support:

- **Daily / Weekly / Monthly** planning horizons
- **Capacity Planning** — available vs required capacity
- **Machine Planning** — assign jobs to machines
- **Shift Planning** — align work to shifts
- **Holiday** and **OT** awareness
- **Drag & Drop Planning**
- **Calendar Timeline** view
- **Resource View** (machines / lines / people as resources)
- Extension hooks for future **OEE** and **Store / Warehouse**

---

## 4. End-to-End Manufacturing Vision

```text
Order → Planning → Approve → Release → Production → QC → Store → Shipping
```

Phase 1 implements Planning (and approval/release states). Downstream modules consume the same masters, calendar, and audit model.

---

## 5. Future Modules

| Module | Intent |
|--------|--------|
| Production | Execute released plans on the shop floor |
| Store / Warehouse | Material and finished-goods inventory |
| OEE | Availability, performance, quality metrics |
| Quality | QC plans, inspections, non-conformance |
| Maintenance | Preventive / corrective maintenance |
| Dashboard | Cross-module KPIs and widgets |
| SAP Integration | ERP sync for orders, materials, shipping |
| Google Drive | Document and drawing storage |
| Telegram | Operational alerts and approvals |
| AI Assistant | Planning suggestions, Q&A, anomaly help |

---

## 6. Success Criteria (Planning Phase)

1. Planners can schedule all lines for a day/week/month without hardcoding line definitions.
2. Capacity, machine, and shift constraints are visible before release.
3. Holidays, OT, and machine shutdowns come from the shared Calendar Engine.
4. Drag-and-drop updates persist with audit history and versioning.
5. New modules can attach to masters and calendar without schema redesign.

---

## 7. Non-Goals (Phase 1)

- Full shop-floor MES execution UI
- Live OEE collection hardware integration
- Complete SAP bidirectional sync
- AI-driven auto-scheduling as the primary planner

These remain in the roadmap ([24_ROADMAP.md](24_ROADMAP.md)).

---

## Related Documents

- [00_PROJECT_CONSTITUTION.md](00_PROJECT_CONSTITUTION.md)
- [07_MODULES.md](07_MODULES.md)
- [27_BUSINESS_FLOW.md](27_BUSINESS_FLOW.md)
- [24_ROADMAP.md](24_ROADMAP.md)

<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# Business Analysis

**Product:** Smart-Factory Manufacturing Platform  
**Related:** [PROJECT_VISION.md](../00_Governance/PROJECT_VISION.md) · [BUSINESS_FLOW.md](BUSINESS_FLOW.md) · [REQUIREMENTS.md](REQUIREMENTS.md)

---

## 1. Problem

Factories need one operational system for **order → plan → produce → store → ship**, with shared calendar/capacity rules, instead of spreadsheets and siloed tools.

## 2. Solution (Phase focus)

| Phase | Capability |
|-------|------------|
| Now | Docs + Supabase masters + Auth + **Production Planning** (header/detail/calendar/capacity/approve/release) |
| Next | Production execution, Drive/Telegram, dashboards |
| Later | Store, OEE, QC, Maintenance, SAP, AI |

## 3. Stakeholders

| Role | Needs |
|------|-------|
| Planner | Schedule jobs on lines/machines with holiday/OT/capacity awareness |
| Supervisor | Approve / reject / release plans |
| Admin | Masters, RBAC, menus |
| Operator (future) | Execute released jobs |
| Executive (future) | Dashboard KPIs |

## 4. Scope boundaries

**In:** Plant-scoped masters, Calendar Engine inputs, planning workflow, soft-delete audit model.  
**Out (for now):** Payroll OT money, PLC clock sync, full multi-level BOM explosion UI.

## 5. Success criteria (Planning)

1. Six production lines configurable in DB (not hardcoded).  
2. Conflicts with holiday / capacity visible before release.  
3. Approvals and releases audited.  
4. Knowledge docs remain the source of truth.

## 6. Domain modules

See [60_Module](../60_Module/) — Planning delivered first; Production / Store / OEE / QC / Maintenance reserved.

<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# Requirements

**Product:** Smart-Factory Manufacturing Platform  
**Phase:** Production Planning MVP (+ Auth)

---

## 1. Functional — Authentication

| ID | Requirement |
|----|-------------|
| AUTH-01 | Users sign in via Supabase Auth |
| AUTH-02 | Profile row created/linked in `master.user_profile` |
| AUTH-03 | Roles and permissions managed in masters |
| AUTH-04 | Sidebar menus driven from `master.menu` + RBAC |

## 2. Functional — Planning

| ID | Requirement |
|----|-------------|
| PLAN-01 | Create/list production plans (header) by horizon and period |
| PLAN-02 | Maintain plan items (detail) with part, line, optional machine/shift, qty, times |
| PLAN-03 | Calendar board: line × day lanes |
| PLAN-04 | Drag-drop reschedule with optimistic versioning |
| PLAN-05 | Capacity view: scheduled load vs `master.capacity` |
| PLAN-06 | Submit / approve / reject workflow with audit events |
| PLAN-07 | Release approved plan; lock items as released |
| PLAN-08 | Respect holidays/OT/shutdown via Calendar Engine inputs |

## 3. Non-functional

| ID | Requirement |
|----|-------------|
| NFR-01 | PostgreSQL schemas: master / txn / history / … |
| NFR-02 | RLS enabled on exposed tables |
| NFR-03 | Soft delete + Audit\* on mutable business tables |
| NFR-04 | No hardcoded line/shift/capacity lists in UI |
| NFR-05 | Docs in `knowledge/` are source of truth |

## 4. Out of scope (this phase)

Production job console, Store movements, OEE samples, QC forms, Maintenance WO, SAP sync UI.

## Related

- [SCREEN_FLOW.md](../30_UI_UX/SCREEN_FLOW.md)
- [PLANNING.md](../60_Module/PLANNING.md)
- [ROADMAP.md](../00_Governance/ROADMAP.md)

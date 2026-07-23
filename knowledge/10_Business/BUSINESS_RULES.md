<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# Business Rules

**Product:** Smart-Factory Manufacturing Platform  
**Authority:** [PROJECT_CONSTITUTION.md](../00_Governance/PROJECT_CONSTITUTION.md)

---

## 1. Platform laws (summary)

1. Soft delete only for business rows — never hard delete.  
2. UUID primary keys; FKs declared; actors → `user_profile` only.  
3. Config over hardcode — lines, shifts, capacities, statuses, menus in DB.  
4. One Calendar Engine — no forked holiday/shift logic per module.  
5. RBAC via permission codes (`module.resource.action`) — not role name checks in UI alone.  
6. Plant-scoped operational data; RLS + server checks.

## 2. Planning rules

| Rule | Detail |
|------|--------|
| Horizon | Plan has `daily` / `weekly` / `monthly` |
| Editable | Drag-drop / item edits only when status `draft` or `rejected` |
| Workflow | `draft → submitted → approved\|rejected → released` |
| Capacity | XOR line/machine on capacity master; release should consider overload |
| Concurrency | Optimistic `version` on plan header and items |
| History | Status changes and item moves write history rows |

## 3. Master data rules

| Rule | Detail |
|------|--------|
| Codes | Stable business codes (`PL-110T`, `PART-001`, …) |
| Soft delete | Prefer deactivate; RESTRICT FKs on children |
| UoM | No free-text units — use `master.uom` |
| Status | Text codes via `master.status_code` — no Postgres ENUMs |

## 4. Auth / menu rules

| Rule | Detail |
|------|--------|
| Identity | Supabase Auth → `master.user_profile` |
| Menu visibility | `permission_code` and/or `role_menu` |
| Secrets | Service role server-only; never in client |

## 5. Related

- [TERMINOLOGY.md](TERMINOLOGY.md)
- Legacy detail: `/docs/30-database/32_STATUS_STATE_MACHINE.md`, `/docs/30-database/31_NUMBERING_STANDARD.md`

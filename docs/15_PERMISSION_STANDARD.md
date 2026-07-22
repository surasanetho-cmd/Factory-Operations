# 15 — Permission Standard

**Product:** Smart-Factory Manufacturing Platform  
**Model:** RBAC (Role-Based Access Control)

---

## 1. Concepts

| Entity | Meaning |
|--------|---------|
| User | `master.user_profile` linked to Supabase Auth |
| Role | Named set of permissions (`planner`, `supervisor`, `admin`, …) |
| Permission | Atomic `module` + `action` + `resource` |
| Assignment | `user_role`, `role_permission` |

Users may hold multiple roles; permissions are unioned.

---

## 2. Permission Code Format

```text
{module}.{resource}.{action}
```

Examples:

- `plan.production_plan.read`
- `plan.production_plan.create`
- `plan.production_plan.update`
- `plan.production_plan.approve`
- `plan.production_plan.release`
- `plan.production_plan.delete` (soft delete)
- `master.machine.manage`
- `dashboard.layout.manage_own`

Module codes: [07_MODULES.md](07_MODULES.md).

---

## 3. Standard Actions

| Action | Meaning |
|--------|---------|
| `read` | View |
| `create` | Insert |
| `update` | Patch / drag-drop save |
| `delete` | Soft delete |
| `approve` | Approval workflow |
| `reject` | Rejection workflow |
| `release` | Release to production |
| `manage` | Admin of master subset |
| `export` | Export data |
| `configure` | System config |

---

## 4. Seed Roles (initial)

| Role code | Intent |
|-----------|--------|
| `admin` | Full platform configuration |
| `planner` | Create/edit plans, submit |
| `supervisor` | Approve/reject/release |
| `viewer` | Read-only planning & dashboards |
| `operator` | Future production execution (minimal Phase 1) |

Exact permission matrices are seeded in DB — not hardcoded in UI conditionals beyond checking permission codes.

---

## 5. Enforcement Points

1. **UI** — hide/disable unauthorized controls.
2. **API / Server Actions** — check permission before mutation.
3. **RLS** — enforce row access using role membership functions.

---

## 6. Implementation Guidelines

- Central helper: `authorize(userId, permissionCode)` / `requirePermission(...)`.
- Do not scatter stringly role name checks (`if role === 'admin'`) in features; check permissions.
- New screens register required permissions in docs and seed data together.

---

## 7. Planning Permission Matrix (baseline)

| Permission | admin | planner | supervisor | viewer |
|------------|:-----:|:-------:|:----------:|:------:|
| `plan.*.read` | ✓ | ✓ | ✓ | ✓ |
| `plan.production_plan.create/update` | ✓ | ✓ | ✓ | |
| `plan.production_plan.approve/reject` | ✓ | | ✓ | |
| `plan.production_plan.release` | ✓ | | ✓ | |
| `master.*.manage` | ✓ | limited* | | |

\*Planners may have read on masters; manage reserved for admin unless Decision Log expands.

---

## Related Documents

- [14_SECURITY_STANDARD.md](14_SECURITY_STANDARD.md)
- [26_MASTER_DATA.md](26_MASTER_DATA.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

# 50 — SQL Module Delivery

**Product:** Smart-Factory Manufacturing Platform  
**Rule:** One module at a time. Wait for review before the next module.

---

## Delivery order

| # | Module | Status | Migrations |
|---|--------|--------|------------|
| 1 | **PLATFORM** | Applied to remote `Factory-Operations` (`ilkzavjrjwjebcyitgaj`, `ap-south-1`) | `platform_01` … `platform_09` |
| 2 | **CALENDAR & RESOURCES** | Applied to remote `Factory-Operations` (`ilkzavjrjwjebcyitgaj`, `ap-south-1`) | `calendar_01` … `calendar_09` |
| 3 | **PRODUCT** | Applied to remote `Factory-Operations` (`ilkzavjrjwjebcyitgaj`, `ap-south-1`) | `product_01` … `product_06` |
| 3b | **AUTH / MENU (Phase 5)** | Applied + app shell | `auth_01` … `auth_05` — see [51_AUTH_MODULE_DELIVERY.md](51_AUTH_MODULE_DELIVERY.md) |
| 4 | PLANNING (txn) | Pending | sales_order, production_plan*, approvals, history |
| 5 | INTEGRATION / LOG / DASHBOARD | Pending | outbox, sync, file_link, logs, layouts |
| 6+ | Production / Store / OEE / … | Later | reserved tables |

---

## Master coverage (requested)

| Master | Table | Module |
|--------|-------|--------|
| User | `master.user_profile` | 1 |
| Role | `master.role` | 1 |
| Permission | `master.permission` | 1 |
| Line | `master.production_line` | 2 |
| Machine | `master.machine` | 2 |
| Shift | `master.shift` | 2 |
| Calendar | `master.calendar` | 2 |
| Holiday | `master.holiday` | 2 |
| Customer | `master.customer` | 3 |
| Part | `master.part` | 3 |
| Process | `master.process` | 3 |

Also in Module 3: `material`, `part_material` (BOM), `part_process` (routing).

---

## Module 1 — PLATFORM

See prior section / migrations `platform_01` … `platform_09`.

---

## Module 2 — CALENDAR & RESOURCES

See prior section / migrations `calendar_01` … `calendar_09`.

---

## Module 3 — PRODUCT (this delivery)

### Includes

| Area | Objects |
|------|---------|
| Tables | `customer`, `part`, `material`, `process`, `part_material`, `part_process` |
| Views | `v_customer_active`, `v_part_active`, `v_material_active`, `v_process_active`, `v_part_bom_active`, `v_part_routing_active` |
| Seed | `CUST-DEMO`, `PART-001/002`, `MAT-STEEL/RESIN`, `PRESS/DEBURR/INSPECT`, sample BOM + routing |
| RLS | Plant-scoped select + manage permissions |

### Migration files

```text
supabase/migrations/
  20260723024631_product_01_customer_part_material.sql
  20260723024632_product_02_process_bom_routing.sql
  20260723024633_product_03_views.sql
  20260723024634_product_04_rls.sql
  20260723024635_product_05_seed.sql
  20260723024636_product_06_grants.sql
```

### Not in Module 3

- Planning transactions (`sales_order`, `production_plan*`)  
- History / outbox / dashboard tables  

---

## Review checklist (Module 3)

- [ ] Customer / part / process columns match dictionary  
- [ ] BOM XOR routing seed acceptable  
- [ ] Approve to proceed with **Module 4: PLANNING**

---

## Related Documents

- [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)
- [43_MASTER_DATA_LIST.md](43_MASTER_DATA_LIST.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

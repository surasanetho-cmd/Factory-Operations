<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 37 — Table Relationships

**Product:** Smart-Factory Manufacturing Platform  
**Purpose:** Complete relationship catalog (parent → child).  
**FK DDL names:** [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)

Legend: **1** one, **N** many, **0..1** optional one.

---

## 1. Organization & identity

| Parent | Child | Child FK | Card | On delete |
|--------|-------|----------|------|-----------|
| `master.plant` | `master.department` | `plant_id` | 1:N | RESTRICT |
| `master.department` | `master.department` | `parent_id` | 0..1:N | RESTRICT |
| `master.plant` | `master.user_profile` | `default_plant_id` | 0..1:N | RESTRICT |
| `master.department` | `master.user_profile` | `department_id` | 0..1:N | RESTRICT |
| `auth.users` | `master.user_profile` | `auth_user_id` | 1:1 | RESTRICT |
| `master.user_profile` | `master.user_role` | `user_id` | 1:N | RESTRICT |
| `master.role` | `master.user_role` | `role_id` | 1:N | RESTRICT |
| `master.plant` | `master.user_role` | `plant_id` | 0..1:N | RESTRICT |
| `master.role` | `master.role_permission` | `role_id` | 1:N | RESTRICT |
| `master.permission` | `master.role_permission` | `permission_id` | 1:N | RESTRICT |

---

## 2. Product & UoM

| Parent | Child | Child FK | Card | On delete |
|--------|-------|----------|------|-----------|
| `master.uom` | `master.uom_conversion` | `from_uom_id` | 1:N | RESTRICT |
| `master.uom` | `master.uom_conversion` | `to_uom_id` | 1:N | RESTRICT |
| `master.plant` | `master.customer` | `plant_id` | 0..1:N | RESTRICT |
| `master.plant` | `master.part` | `plant_id` | 1:N | RESTRICT |
| `master.customer` | `master.part` | `customer_id` | 0..1:N | RESTRICT |
| `master.uom` | `master.part` | `uom_id` | 1:N | RESTRICT |
| `master.plant` | `master.material` | `plant_id` | 1:N | RESTRICT |
| `master.uom` | `master.material` | `uom_id` | 1:N | RESTRICT |
| `master.part` | `master.part_material` | `part_id` | 1:N | RESTRICT |
| `master.material` | `master.part_material` | `material_id` | 1:N | RESTRICT |
| `master.uom` | `master.part_material` | `uom_id` | 1:N | RESTRICT |
| `master.plant` | `master.process` | `plant_id` | 0..1:N | RESTRICT |
| `master.part` | `master.part_process` | `part_id` | 1:N | RESTRICT |
| `master.process` | `master.part_process` | `process_id` | 1:N | RESTRICT |

---

## 3. Calendar & resources

| Parent | Child | Child FK | Card | On delete |
|--------|-------|----------|------|-----------|
| `master.plant` | `master.calendar` | `plant_id` | 0..1:N | RESTRICT |
| `master.calendar` | `master.plant` | `default_calendar_id` | 0..1:N | RESTRICT |
| `master.calendar` | `master.holiday` | `calendar_id` | 1:N | RESTRICT |
| `master.plant` | `master.production_line` | `plant_id` | 1:N | RESTRICT |
| `master.calendar` | `master.production_line` | `calendar_id` | 0..1:N | RESTRICT |
| `master.plant` | `master.machine` | `plant_id` | 1:N | RESTRICT |
| `master.production_line` | `master.machine` | `production_line_id` | 1:N | RESTRICT |
| `master.calendar` | `master.machine` | `calendar_id` | 0..1:N | RESTRICT |
| `master.plant` | `master.shift` | `plant_id` | 1:N | RESTRICT |
| `master.plant` | `master.shift_assignment` | `plant_id` | 1:N | RESTRICT |
| `master.shift` | `master.shift_assignment` | `shift_id` | 1:N | RESTRICT |
| `master.production_line` | `master.shift_assignment` | `production_line_id` | 0..1:N | RESTRICT |
| `master.machine` | `master.shift_assignment` | `machine_id` | 0..1:N | RESTRICT |
| `master.plant` | `master.capacity` | `plant_id` | 1:N | RESTRICT |
| `master.shift` | `master.capacity` | `shift_id` | 1:N | RESTRICT |
| `master.production_line` | `master.capacity` | `production_line_id` | 0..1:N | RESTRICT |
| `master.machine` | `master.capacity` | `machine_id` | 0..1:N | RESTRICT |
| `master.plant` | `master.number_sequence` | `plant_id` | 1:N | RESTRICT |
| `master.plant` | `master.reason_code` | `plant_id` | 0..1:N | RESTRICT |

---

## 4. Planning transactions

| Parent | Child | Child FK | Card | On delete |
|--------|-------|----------|------|-----------|
| `master.plant` | `txn.sales_order` | `plant_id` | 1:N | RESTRICT |
| `master.customer` | `txn.sales_order` | `customer_id` | 1:N | RESTRICT |
| `txn.sales_order` | `txn.sales_order_line` | `sales_order_id` | 1:N | RESTRICT |
| `master.part` | `txn.sales_order_line` | `part_id` | 1:N | RESTRICT |
| `master.uom` | `txn.sales_order_line` | `uom_id` | 0..1:N | RESTRICT |
| `master.plant` | `txn.production_plan` | `plant_id` | 1:N | RESTRICT |
| `master.user_profile` | `txn.production_plan` | `lease_owner_id` | 0..1:N | RESTRICT |
| `txn.production_plan` | `txn.production_plan_item` | `production_plan_id` | 1:N | RESTRICT |
| `txn.sales_order_line` | `txn.production_plan_item` | `sales_order_line_id` | 0..1:N | RESTRICT |
| `master.part` | `txn.production_plan_item` | `part_id` | 1:N | RESTRICT |
| `master.production_line` | `txn.production_plan_item` | `production_line_id` | 1:N | RESTRICT |
| `master.machine` | `txn.production_plan_item` | `machine_id` | 0..1:N | RESTRICT |
| `master.shift` | `txn.production_plan_item` | `shift_id` | 0..1:N | RESTRICT |
| `txn.production_plan` | `txn.plan_approval` | `production_plan_id` | 1:N | RESTRICT |
| `master.user_profile` | `txn.plan_approval` | `acted_by` | 1:N | RESTRICT |
| `txn.production_plan` | `txn.plan_release` | `production_plan_id` | 1:N | RESTRICT |
| `master.user_profile` | `txn.plan_release` | `released_by` | 1:N | RESTRICT |
| `txn.production_plan` | `txn.plan_amendment` | `production_plan_id` | 1:N | RESTRICT |
| `master.reason_code` | `txn.plan_amendment` | `reason_code_id` | 0..1:N | RESTRICT |
| `master.plant` | `txn.ot_window` | `plant_id` | 1:N | RESTRICT |
| `master.production_line` | `txn.ot_window` | `production_line_id` | 0..1:N | RESTRICT |
| `master.machine` | `txn.ot_window` | `machine_id` | 0..1:N | RESTRICT |
| `master.reason_code` | `txn.ot_window` | `reason_code_id` | 0..1:N | RESTRICT |
| `master.plant` | `txn.machine_shutdown` | `plant_id` | 1:N | RESTRICT |
| `master.machine` | `txn.machine_shutdown` | `machine_id` | 1:N | RESTRICT |
| `master.production_line` | `txn.machine_shutdown` | `production_line_id` | 0..1:N | RESTRICT |
| `master.reason_code` | `txn.machine_shutdown` | `reason_code_id` | 0..1:N | RESTRICT |

---

## 5. History, config, integration, dashboard

| Parent | Child | Child FK | Card | On delete |
|--------|-------|----------|------|-----------|
| `txn.production_plan` | `history.production_plan_history` | `production_plan_id` | 1:N | RESTRICT |
| `txn.production_plan_item` | `history.production_plan_item_history` | `production_plan_item_id` | 1:N | RESTRICT |
| `master.user_profile` | `history.*` / `changed_by` | `changed_by` | 0..1:N | RESTRICT |
| `master.user_profile` | `config.user_preference` | `user_id` | 1:N | RESTRICT |
| `master.plant` | `integration.connection` | `plant_id` | 0..1:N | RESTRICT |
| `integration.connection` | `integration.sync_job` | `connection_id` | 1:N | RESTRICT |
| `integration.sync_job` | `integration.sync_job_item` | `sync_job_id` | 1:N | CASCADE |
| `integration.connection` | `integration.id_map` | `connection_id` | 1:N | RESTRICT |
| `master.file_type` | `integration.file_link` | `file_type_id` | 1:N | RESTRICT |
| `master.user_profile` | `integration.idempotency_key` | `user_id` | 0..1:N | RESTRICT |
| `master.user_profile` | `dashboard.layout` | `user_id` | 0..1:N | RESTRICT |
| `master.role` | `dashboard.layout` | `role_id` | 0..1:N | RESTRICT |
| `master.plant` | `dashboard.layout` | `plant_id` | 0..1:N | RESTRICT |
| `dashboard.layout` | `dashboard.widget` | `layout_id` | 1:N | **CASCADE** |

---

## 6. Logical (non-FK) relationships

| From | To | How enforced |
|------|----|--------------|
| `*.status_code` | `master.status_code.code` | Domain service + optional trigger; match `entity_type` |
| `notification_template.code` | outbox `event_type` | Convention |
| `file_link.entity_id` | polymorphic entity | App validates `entity_type` |
| `entity_change.entity_id` | polymorphic | App validates |

---

## 7. Dependency order (create / migrate)

1. Extensions (`pgcrypto` / `gen_random_uuid`)
2. Schemas
3. `master.plant` (without default_calendar)
4. Lookups: `uom`, `role`, `permission`, `status_code`, `file_type`, `reason_code`
5. `calendar`, then set `plant.default_calendar_id`
6. Org: department, user_profile, junctions
7. Product: customer, part, material, BOM, process
8. Resources: line, machine, shift, assignment, capacity, holiday, number_sequence
9. `txn.*` planning + calendar inputs
10. `history`, `log`, `config`, `integration`, `dashboard`
11. RLS policies + `authz` functions

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md)
- [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)

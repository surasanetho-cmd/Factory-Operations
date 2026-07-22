# 38 — Foreign Keys

**Product:** Smart-Factory Manufacturing Platform  
**Rule:** Every relationship in [37](37_TABLE_RELATIONSHIPS.md) is a declared FK unless marked logical-only.  
**Default:** `ON DELETE RESTRICT` `ON UPDATE CASCADE` (uuid PKs rarely update).  
**Actor columns:** `created_by`, `updated_by`, `deleted_by` → `master.user_profile(id)` on all pattern **A**/**E**/**J** tables that include them (not repeated below for every table).

Naming: `fk_{table}_{column}`

---

## 1. Master — organization & authz

| Constraint | Table | Column | References |
|------------|-------|--------|------------|
| `fk_plant_default_calendar_id` | `master.plant` | `default_calendar_id` | `master.calendar(id)` |
| `fk_department_plant_id` | `master.department` | `plant_id` | `master.plant(id)` |
| `fk_department_parent_id` | `master.department` | `parent_id` | `master.department(id)` |
| `fk_user_profile_auth_user_id` | `master.user_profile` | `auth_user_id` | `auth.users(id)` |
| `fk_user_profile_department_id` | `master.user_profile` | `department_id` | `master.department(id)` |
| `fk_user_profile_default_plant_id` | `master.user_profile` | `default_plant_id` | `master.plant(id)` |
| `fk_role_permission_role_id` | `master.role_permission` | `role_id` | `master.role(id)` |
| `fk_role_permission_permission_id` | `master.role_permission` | `permission_id` | `master.permission(id)` |
| `fk_user_role_user_id` | `master.user_role` | `user_id` | `master.user_profile(id)` |
| `fk_user_role_role_id` | `master.user_role` | `role_id` | `master.role(id)` |
| `fk_user_role_plant_id` | `master.user_role` | `plant_id` | `master.plant(id)` |

---

## 2. Master — product & UoM

| Constraint | Table | Column | References |
|------------|-------|--------|------------|
| `fk_uom_conversion_from_uom_id` | `master.uom_conversion` | `from_uom_id` | `master.uom(id)` |
| `fk_uom_conversion_to_uom_id` | `master.uom_conversion` | `to_uom_id` | `master.uom(id)` |
| `fk_customer_plant_id` | `master.customer` | `plant_id` | `master.plant(id)` |
| `fk_part_plant_id` | `master.part` | `plant_id` | `master.plant(id)` |
| `fk_part_customer_id` | `master.part` | `customer_id` | `master.customer(id)` |
| `fk_part_uom_id` | `master.part` | `uom_id` | `master.uom(id)` |
| `fk_material_plant_id` | `master.material` | `plant_id` | `master.plant(id)` |
| `fk_material_uom_id` | `master.material` | `uom_id` | `master.uom(id)` |
| `fk_part_material_part_id` | `master.part_material` | `part_id` | `master.part(id)` |
| `fk_part_material_material_id` | `master.part_material` | `material_id` | `master.material(id)` |
| `fk_part_material_uom_id` | `master.part_material` | `uom_id` | `master.uom(id)` |
| `fk_process_plant_id` | `master.process` | `plant_id` | `master.plant(id)` |
| `fk_part_process_part_id` | `master.part_process` | `part_id` | `master.part(id)` |
| `fk_part_process_process_id` | `master.part_process` | `process_id` | `master.process(id)` |

---

## 3. Master — calendar & resources

| Constraint | Table | Column | References |
|------------|-------|--------|------------|
| `fk_calendar_plant_id` | `master.calendar` | `plant_id` | `master.plant(id)` |
| `fk_holiday_calendar_id` | `master.holiday` | `calendar_id` | `master.calendar(id)` |
| `fk_production_line_plant_id` | `master.production_line` | `plant_id` | `master.plant(id)` |
| `fk_production_line_calendar_id` | `master.production_line` | `calendar_id` | `master.calendar(id)` |
| `fk_machine_plant_id` | `master.machine` | `plant_id` | `master.plant(id)` |
| `fk_machine_production_line_id` | `master.machine` | `production_line_id` | `master.production_line(id)` |
| `fk_machine_calendar_id` | `master.machine` | `calendar_id` | `master.calendar(id)` |
| `fk_shift_plant_id` | `master.shift` | `plant_id` | `master.plant(id)` |
| `fk_shift_assignment_plant_id` | `master.shift_assignment` | `plant_id` | `master.plant(id)` |
| `fk_shift_assignment_shift_id` | `master.shift_assignment` | `shift_id` | `master.shift(id)` |
| `fk_shift_assignment_production_line_id` | `master.shift_assignment` | `production_line_id` | `master.production_line(id)` |
| `fk_shift_assignment_machine_id` | `master.shift_assignment` | `machine_id` | `master.machine(id)` |
| `fk_capacity_plant_id` | `master.capacity` | `plant_id` | `master.plant(id)` |
| `fk_capacity_production_line_id` | `master.capacity` | `production_line_id` | `master.production_line(id)` |
| `fk_capacity_machine_id` | `master.capacity` | `machine_id` | `master.machine(id)` |
| `fk_capacity_shift_id` | `master.capacity` | `shift_id` | `master.shift(id)` |
| `fk_reason_code_plant_id` | `master.reason_code` | `plant_id` | `master.plant(id)` |
| `fk_number_sequence_plant_id` | `master.number_sequence` | `plant_id` | `master.plant(id)` |

---

## 4. Transaction — planning & calendar inputs

| Constraint | Table | Column | References |
|------------|-------|--------|------------|
| `fk_sales_order_plant_id` | `txn.sales_order` | `plant_id` | `master.plant(id)` |
| `fk_sales_order_customer_id` | `txn.sales_order` | `customer_id` | `master.customer(id)` |
| `fk_sales_order_line_sales_order_id` | `txn.sales_order_line` | `sales_order_id` | `txn.sales_order(id)` |
| `fk_sales_order_line_part_id` | `txn.sales_order_line` | `part_id` | `master.part(id)` |
| `fk_sales_order_line_uom_id` | `txn.sales_order_line` | `uom_id` | `master.uom(id)` |
| `fk_production_plan_plant_id` | `txn.production_plan` | `plant_id` | `master.plant(id)` |
| `fk_production_plan_lease_owner_id` | `txn.production_plan` | `lease_owner_id` | `master.user_profile(id)` |
| `fk_production_plan_item_production_plan_id` | `txn.production_plan_item` | `production_plan_id` | `txn.production_plan(id)` |
| `fk_production_plan_item_sales_order_line_id` | `txn.production_plan_item` | `sales_order_line_id` | `txn.sales_order_line(id)` |
| `fk_production_plan_item_part_id` | `txn.production_plan_item` | `part_id` | `master.part(id)` |
| `fk_production_plan_item_production_line_id` | `txn.production_plan_item` | `production_line_id` | `master.production_line(id)` |
| `fk_production_plan_item_machine_id` | `txn.production_plan_item` | `machine_id` | `master.machine(id)` |
| `fk_production_plan_item_shift_id` | `txn.production_plan_item` | `shift_id` | `master.shift(id)` |
| `fk_plan_approval_production_plan_id` | `txn.plan_approval` | `production_plan_id` | `txn.production_plan(id)` |
| `fk_plan_approval_acted_by` | `txn.plan_approval` | `acted_by` | `master.user_profile(id)` |
| `fk_plan_release_production_plan_id` | `txn.plan_release` | `production_plan_id` | `txn.production_plan(id)` |
| `fk_plan_release_released_by` | `txn.plan_release` | `released_by` | `master.user_profile(id)` |
| `fk_plan_amendment_production_plan_id` | `txn.plan_amendment` | `production_plan_id` | `txn.production_plan(id)` |
| `fk_plan_amendment_reason_code_id` | `txn.plan_amendment` | `reason_code_id` | `master.reason_code(id)` |
| `fk_ot_window_plant_id` | `txn.ot_window` | `plant_id` | `master.plant(id)` |
| `fk_ot_window_production_line_id` | `txn.ot_window` | `production_line_id` | `master.production_line(id)` |
| `fk_ot_window_machine_id` | `txn.ot_window` | `machine_id` | `master.machine(id)` |
| `fk_ot_window_reason_code_id` | `txn.ot_window` | `reason_code_id` | `master.reason_code(id)` |
| `fk_machine_shutdown_plant_id` | `txn.machine_shutdown` | `plant_id` | `master.plant(id)` |
| `fk_machine_shutdown_machine_id` | `txn.machine_shutdown` | `machine_id` | `master.machine(id)` |
| `fk_machine_shutdown_production_line_id` | `txn.machine_shutdown` | `production_line_id` | `master.production_line(id)` |
| `fk_machine_shutdown_reason_code_id` | `txn.machine_shutdown` | `reason_code_id` | `master.reason_code(id)` |

---

## 5. History / log / config / integration / dashboard

| Constraint | Table | Column | References |
|------------|-------|--------|------------|
| `fk_production_plan_history_plan_id` | `history.production_plan_history` | `production_plan_id` | `txn.production_plan(id)` |
| `fk_production_plan_history_changed_by` | `history.production_plan_history` | `changed_by` | `master.user_profile(id)` |
| `fk_production_plan_item_history_item_id` | `history.production_plan_item_history` | `production_plan_item_id` | `txn.production_plan_item(id)` |
| `fk_production_plan_item_history_changed_by` | `history.production_plan_item_history` | `changed_by` | `master.user_profile(id)` |
| `fk_entity_change_changed_by` | `history.entity_change` | `changed_by` | `master.user_profile(id)` |
| `fk_app_event_user_id` | `log.app_event` | `user_id` | `master.user_profile(id)` |
| `fk_integration_event_connection_id` | `log.integration_event` | `connection_id` | `integration.connection(id)` |
| `fk_user_preference_user_id` | `config.user_preference` | `user_id` | `master.user_profile(id)` |
| `fk_connection_plant_id` | `integration.connection` | `plant_id` | `master.plant(id)` |
| `fk_sync_job_connection_id` | `integration.sync_job` | `connection_id` | `integration.connection(id)` |
| `fk_sync_job_item_sync_job_id` | `integration.sync_job_item` | `sync_job_id` | `integration.sync_job(id)` **ON DELETE CASCADE** |
| `fk_id_map_connection_id` | `integration.id_map` | `connection_id` | `integration.connection(id)` |
| `fk_file_link_file_type_id` | `integration.file_link` | `file_type_id` | `master.file_type(id)` |
| `fk_idempotency_key_user_id` | `integration.idempotency_key` | `user_id` | `master.user_profile(id)` |
| `fk_layout_user_id` | `dashboard.layout` | `user_id` | `master.user_profile(id)` |
| `fk_layout_role_id` | `dashboard.layout` | `role_id` | `master.role(id)` |
| `fk_layout_plant_id` | `dashboard.layout` | `plant_id` | `master.plant(id)` |
| `fk_widget_layout_id` | `dashboard.widget` | `layout_id` | `dashboard.layout(id)` **ON DELETE CASCADE** |

---

## 6. CHECK constraints (with FKs)

| Name | Table | Expression (logical) |
|------|-------|----------------------|
| `ck_capacity_line_xor_machine` | `master.capacity` | `(production_line_id IS NOT NULL) <> (machine_id IS NOT NULL)` — exactly one non-null |
| `ck_shift_assignment_not_both` | `master.shift_assignment` | `NOT (production_line_id IS NOT NULL AND machine_id IS NOT NULL)` |
| `ck_ot_window_has_resource` | `txn.ot_window` | `production_line_id IS NOT NULL OR machine_id IS NOT NULL` |
| `ck_ot_window_xor` | `txn.ot_window` | prefer exactly one resource (recommended) |
| `ck_plan_item_time_order` | `txn.production_plan_item` | `planned_end_at > planned_start_at` |
| `ck_ot_window_time_order` | `txn.ot_window` | `end_at > start_at` |
| `ck_shutdown_time_order` | `txn.machine_shutdown` | `end_at > start_at` |
| `ck_uom_conversion_factor` | `master.uom_conversion` | `factor > 0` |
| `ck_part_material_qty` | `master.part_material` | `qty_per >= 0` |
| `ck_plan_item_qty` | `txn.production_plan_item` | `qty >= 0` |
| `ck_order_line_qty` | `txn.sales_order_line` | `qty_ordered >= 0 AND qty_allocated >= 0` |

---

## 7. Non-FK status references

`status_code` columns are **text** validated against `master.status_code` for the owning `entity_type`. Optional enforcement: trigger `trg_{table}_validate_status` or domain service only (Phase 1).

| Table | entity_type |
|-------|-------------|
| `txn.sales_order` | `sales_order` |
| `txn.sales_order_line` | `sales_order_line` |
| `txn.production_plan` | `production_plan` |
| `txn.production_plan_item` | `production_plan_item` |
| `txn.plan_amendment` | `plan_amendment` |
| `txn.ot_window` | `ot_window` |
| `txn.machine_shutdown` | `machine_shutdown` |
| `integration.sync_job` | `sync_job` |
| `integration.outbox` | `outbox` |

---

## Related Documents

- [37_TABLE_RELATIONSHIPS.md](37_TABLE_RELATIONSHIPS.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)

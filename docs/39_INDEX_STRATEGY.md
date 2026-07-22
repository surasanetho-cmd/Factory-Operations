# 39 — Index Strategy

**Product:** Smart-Factory Manufacturing Platform  
**Naming:** `uq_*` unique, `ix_*` non-unique — [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)  
**Default filter for operational reads:** `deleted_at IS NULL` (partial indexes).

---

## 1. Principles

1. **Partial uniques** for soft-deleted business keys.
2. **Board hot paths** indexed for line/machine + time.
3. **Worker queues** (outbox) indexed by status + availability.
4. **History** indexed by entity + time DESC.
5. Avoid over-indexing low-cardinality flags alone (`is_active` only).
6. Prefer composite indexes matching real `WHERE` + `ORDER BY` clauses.
7. Plan for future BRIN/partitioning on high-volume `log`, `history`, `oee_sample`.

---

## 2. Unique indexes (active rows)

| Name | Table | Columns | Predicate |
|------|-------|---------|-----------|
| `uq_plant_code_active` | `master.plant` | `(code)` | `deleted_at IS NULL` |
| `uq_department_plant_code_active` | `master.department` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_user_profile_auth_user_id` | `master.user_profile` | `(auth_user_id)` | — (always unique) |
| `uq_user_profile_employee_code_active` | `master.user_profile` | `(employee_code)` | `deleted_at IS NULL` |
| `uq_role_code_active` | `master.role` | `(code)` | `deleted_at IS NULL` |
| `uq_permission_code_active` | `master.permission` | `(code)` | `deleted_at IS NULL` |
| `uq_role_permission_pair_active` | `master.role_permission` | `(role_id, permission_id)` | `deleted_at IS NULL` |
| `uq_user_role_triple_active` | `master.user_role` | `(user_id, role_id, plant_id)` | `deleted_at IS NULL` |
| `uq_uom_code_active` | `master.uom` | `(code)` | `deleted_at IS NULL` |
| `uq_uom_conversion_pair_active` | `master.uom_conversion` | `(from_uom_id, to_uom_id)` | `deleted_at IS NULL` |
| `uq_customer_plant_code_active` | `master.customer` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_part_plant_code_active` | `master.part` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_material_plant_code_active` | `master.material` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_part_material_seq_active` | `master.part_material` | `(part_id, material_id, sequence)` | `deleted_at IS NULL` |
| `uq_process_code_active` | `master.process` | `(coalesce(plant_id, …), code)` or `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_part_process_seq_active` | `master.part_process` | `(part_id, sequence)` | `deleted_at IS NULL` |
| `uq_calendar_plant_code_active` | `master.calendar` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_holiday_calendar_date_active` | `master.holiday` | `(calendar_id, holiday_date)` | `deleted_at IS NULL` |
| `uq_production_line_plant_code_active` | `master.production_line` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_machine_plant_code_active` | `master.machine` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_shift_plant_code_active` | `master.shift` | `(plant_id, code)` | `deleted_at IS NULL` |
| `uq_status_code_entity_code_active` | `master.status_code` | `(entity_type, code)` | `deleted_at IS NULL` |
| `uq_reason_code_active` | `master.reason_code` | `(plant_id, code)` or `(code)` | `deleted_at IS NULL` |
| `uq_file_type_code_active` | `master.file_type` | `(code)` | `deleted_at IS NULL` |
| `uq_notification_template_active` | `master.notification_template` | `(code, channel, locale)` | `deleted_at IS NULL` |
| `uq_number_sequence_plant_doc_active` | `master.number_sequence` | `(plant_id, doc_type)` | `deleted_at IS NULL` |
| `uq_sales_order_order_no_active` | `txn.sales_order` | `(order_no)` | `deleted_at IS NULL` |
| `uq_sales_order_line_no_active` | `txn.sales_order_line` | `(sales_order_id, line_no)` | `deleted_at IS NULL` |
| `uq_production_plan_plan_no_active` | `txn.production_plan` | `(plan_no)` | `deleted_at IS NULL` |
| `uq_plan_amendment_no_active` | `txn.plan_amendment` | `(amendment_no)` | `deleted_at IS NULL` |
| `uq_system_setting_key_active` | `config.system_setting` | `(key)` | `deleted_at IS NULL` |
| `uq_feature_flag_code_active` | `config.feature_flag` | `(code)` | `deleted_at IS NULL` |
| `uq_user_preference_user_key_active` | `config.user_preference` | `(user_id, key)` | `deleted_at IS NULL` |
| `uq_connection_code_active` | `integration.connection` | `(code)` | `deleted_at IS NULL` |
| `uq_id_map_external_active` | `integration.id_map` | `(connection_id, entity_type, external_id)` | `deleted_at IS NULL` |
| `uq_idempotency_user_route_key` | `integration.idempotency_key` | `(user_id, route, key)` | — |

> For `user_role` with nullable `plant_id`, use a unique index on `(user_id, role_id, coalesce(plant_id, '00000000-0000-0000-0000-000000000000'::uuid))` **or** disallow NULL and use an explicit “all plants” sentinel — pick one in migration ADR.

---

## 3. Operational / board indexes

| Name | Table | Columns | Predicate / notes |
|------|-------|---------|-------------------|
| `ix_plan_item_plan_active` | `txn.production_plan_item` | `(production_plan_id)` | `deleted_at IS NULL` |
| `ix_plan_item_line_start_active` | `txn.production_plan_item` | `(production_line_id, planned_start_at)` | `deleted_at IS NULL` |
| `ix_plan_item_machine_start_active` | `txn.production_plan_item` | `(machine_id, planned_start_at)` | `deleted_at IS NULL` WHERE machine not null |
| `ix_plan_item_date_active` | `txn.production_plan_item` | `(planned_date)` | `deleted_at IS NULL` |
| `ix_plan_item_part_active` | `txn.production_plan_item` | `(part_id)` | `deleted_at IS NULL` |
| `ix_plan_item_order_line_active` | `txn.production_plan_item` | `(sales_order_line_id)` | where not null |
| `ix_plan_plant_period_active` | `txn.production_plan` | `(plant_id, period_start, period_end)` | `deleted_at IS NULL` |
| `ix_plan_status_active` | `txn.production_plan` | `(status_code)` | `deleted_at IS NULL` |
| `ix_sales_order_plant_date_active` | `txn.sales_order` | `(plant_id, order_date)` | `deleted_at IS NULL` |
| `ix_sales_order_customer_active` | `txn.sales_order` | `(customer_id)` | `deleted_at IS NULL` |
| `ix_sales_order_line_order_active` | `txn.sales_order_line` | `(sales_order_id)` | `deleted_at IS NULL` |
| `ix_holiday_calendar_date` | `master.holiday` | `(calendar_id, holiday_date)` | covered by unique; keep for joins |
| `ix_machine_line_active` | `master.machine` | `(production_line_id)` | `deleted_at IS NULL` |
| `ix_capacity_line_shift_active` | `master.capacity` | `(production_line_id, shift_id, effective_from)` | `deleted_at IS NULL` |
| `ix_capacity_machine_shift_active` | `master.capacity` | `(machine_id, shift_id, effective_from)` | `deleted_at IS NULL` |
| `ix_shift_assignment_plant_from` | `master.shift_assignment` | `(plant_id, effective_from, effective_to)` | `deleted_at IS NULL` |
| `ix_ot_window_resource_time` | `txn.ot_window` | `(plant_id, start_at, end_at)` | `deleted_at IS NULL` |
| `ix_ot_window_line_time` | `txn.ot_window` | `(production_line_id, start_at)` | where line set |
| `ix_ot_window_machine_time` | `txn.ot_window` | `(machine_id, start_at)` | where machine set |
| `ix_shutdown_machine_time` | `txn.machine_shutdown` | `(machine_id, start_at, end_at)` | `deleted_at IS NULL` |
| `ix_plan_approval_plan` | `txn.plan_approval` | `(production_plan_id, acted_at DESC)` | |
| `ix_plan_release_plan` | `txn.plan_release` | `(production_plan_id, released_at DESC)` | |

---

## 4. History, log, integration workers

| Name | Table | Columns | Notes |
|------|-------|---------|-------|
| `ix_plan_history_plan_changed` | `history.production_plan_history` | `(production_plan_id, changed_at DESC)` | |
| `ix_plan_item_history_item_changed` | `history.production_plan_item_history` | `(production_plan_item_id, changed_at DESC)` | |
| `ix_entity_change_entity` | `history.entity_change` | `(entity_type, entity_id, changed_at DESC)` | |
| `ix_app_event_created` | `log.app_event` | `(created_at DESC)` | archive candidate |
| `ix_app_event_module_code` | `log.app_event` | `(module, event_code, created_at DESC)` | |
| `ix_security_event_created` | `log.security_event` | `(created_at DESC)` | |
| `ix_integration_event_created` | `log.integration_event` | `(created_at DESC)` | |
| `ix_outbox_pending` | `integration.outbox` | `(status_code, available_at)` | WHERE `status_code IN ('pending','error')` |
| `ix_outbox_aggregate` | `integration.outbox` | `(aggregate_type, aggregate_id)` | |
| `ix_idempotency_expires` | `integration.idempotency_key` | `(expires_at)` | purge job |
| `ix_sync_job_connection_started` | `integration.sync_job` | `(connection_id, started_at DESC)` | |
| `ix_file_link_entity` | `integration.file_link` | `(entity_type, entity_id)` | `deleted_at IS NULL` |
| `ix_layout_user` | `dashboard.layout` | `(user_id)` | |
| `ix_widget_layout` | `dashboard.widget` | `(layout_id)` | |

---

## 5. Authz / RLS support indexes

| Name | Table | Columns | Notes |
|------|-------|---------|-------|
| `ix_user_role_user` | `master.user_role` | `(user_id)` | `deleted_at IS NULL` |
| `ix_user_role_plant` | `master.user_role` | `(plant_id)` | |
| `ix_role_permission_role` | `master.role_permission` | `(role_id)` | |
| `ix_role_permission_permission` | `master.role_permission` | `(permission_id)` | |
| `ix_permission_code` | `master.permission` | `(code)` | covered by unique |

---

## 6. Query → index map (Planning)

| Query | Uses |
|-------|------|
| Open plan board by plan id | `ix_plan_item_plan_active` |
| Resource timeline by line + range | `ix_plan_item_line_start_active` |
| Resource timeline by machine + range | `ix_plan_item_machine_start_active` |
| Capacity vs load for day | capacity indexes + plan item date/line |
| `checkFit` overlapping jobs | line/machine + `planned_start_at`/`planned_end_at` (consider `tstzrange` + GiST later) |
| Resolve holidays | `uq_holiday_calendar_date_active` |
| Approval inbox by status | `ix_plan_status_active` + plant |
| Outbox dispatcher | `ix_outbox_pending` |

### Future enhancement

When overlap checks dominate CPU, add:

```text
ix_plan_item_line_tstzrange — GiST(production_line_id, tstzrange(planned_start_at, planned_end_at))
```

Document as ADR when introduced.

---

## 7. Maintenance

| Task | Cadence |
|------|---------|
| `ANALYZE` after large seeds / backfills | On demand |
| Purge expired idempotency keys | Daily job |
| Archive/partition old logs & outbox | Per retention config |
| Review unused indexes via `pg_stat_user_indexes` | Quarterly |

---

## Related Documents

- [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md)
- [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)

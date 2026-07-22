# 05 — Database Dictionary

**Product:** Smart-Factory Manufacturing Platform  
**Phase coverage:** Masters + Calendar + Planning + reserved future inputs  
**Audit\*:** see [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)

---

## 1. Schema: `master`

### 1.1 Organization & Identity

| Table | Purpose | Key columns (beyond Audit*) | Notes |
|-------|---------|-----------------------------|-------|
| `master.plant` | Site / plant | `code`, `name`, `timezone`, `default_calendar_id` | Required for scalability; Phase 1 seeds one plant |
| `master.department` | Org unit | `code`, `name`, `plant_id`, `parent_id` | |
| `master.user_profile` | App user | `auth_user_id` (UNIQUE NOT NULL → `auth.users`), `employee_code`, `display_name`, `email`, `department_id`, `default_plant_id`, `locale`, `timezone`, `theme_pref`, `font_scale`, `compact_mode` | Shell prefs live here |
| `master.role` | Role | `code`, `name`, `description` | Global unless noted |
| `master.permission` | Permission atom | `code`, `module`, `action`, `resource`, `description` | |
| `master.role_permission` | Role ↔ permission | `role_id`, `permission_id` | Unique pair; minimal audit OK |
| `master.user_role` | User ↔ role | `user_id` → `user_profile.id`, `role_id`, optional `plant_id` | Unique `(user_id, role_id, plant_id)` |

### 1.2 Commercial & Product

| Table | Purpose | Key columns | Notes |
|-------|---------|-------------|-------|
| `master.uom` | Unit of measure | `code`, `name`, `dimension` | [35_UOM_STANDARD.md](35_UOM_STANDARD.md) |
| `master.uom_conversion` | Conversion | `from_uom_id`, `to_uom_id`, `factor` | |
| `master.customer` | Customer | `code`, `name`, `plant_id` nullable, `contact_json` | |
| `master.part` | Part | `code`, `name`, `customer_id`, `revision`, `uom_id` | Not free-text UoM |
| `master.material` | Material | `code`, `name`, `uom_id`, `spec_json` | |
| `master.part_material` | BOM link | `part_id`, `material_id`, `qty_per`, `uom_id`, `sequence` | **Replaces** incorrect Part→Material ER edge |
| `master.process` | Process | `code`, `name`, `sequence_hint` | |
| `master.part_process` | Routing | `part_id`, `process_id`, `sequence`, `std_time_sec` | |

### 1.3 Plant, Calendar & Capacity

| Table | Purpose | Key columns | Notes |
|-------|---------|-------------|-------|
| `master.production_line` | Line | `plant_id`, `code`, `name`, `tonnage`, `sort_order`, `calendar_id` | `calendar_id` nullable → plant default |
| `master.machine` | Machine | `plant_id`, `production_line_id`, `code`, `name`, `machine_type`, `rated_capacity`, `calendar_id` | Override line calendar if set |
| `master.shift` | Shift template | `plant_id`, `code`, `name`, `start_time`, `end_time`, `break_minutes`, `crosses_midnight` | Template only |
| `master.shift_assignment` | Shift instance | `plant_id`, `shift_id`, `production_line_id` nullable, `machine_id` nullable, `effective_from`, `effective_to`, `weekday_mask` | Exactly one resource scope or plant-wide |
| `master.calendar` | Named calendar | `plant_id` nullable, `code`, `name`, `timezone` | |
| `master.holiday` | Holiday | `calendar_id`, `holiday_date`, `name`, `is_paid` | Unique `(calendar_id, holiday_date)` |
| `master.capacity` | Nominal capacity | `plant_id`, `production_line_id` **XOR** `machine_id`, `shift_id`, `jobs_per_day`, `hours_per_shift`, `effective_from`, `effective_to` | CHECK XOR |
| `master.status_code` | Status lookup | `entity_type`, `code`, `name`, `sort_order`, `is_terminal` | [32](32_STATUS_STATE_MACHINE.md) |
| `master.reason_code` | Reason codes | `code`, `category`, `name` | |
| `master.file_type` | File kinds | `code`, `mime_pattern`, `max_size_mb` | |
| `master.notification_template` | Templates | `code`, `channel`, `subject`, `body`, `locale` | |
| `master.number_sequence` | Doc numbering | `plant_id`, `doc_type`, `prefix`, `next_value`, `pad_length`, `reset_rule` | [31](31_NUMBERING_STANDARD.md) |

---

## 2. Schema: `txn` (Planning + Calendar inputs)

| Table | Purpose | Key columns | Notes |
|-------|---------|-------------|-------|
| `txn.sales_order` | Order header | `plant_id`, `order_no`, `customer_id`, `order_date`, `status_code` | |
| `txn.sales_order_line` | Order line | `sales_order_id`, `line_no`, `part_id`, `qty_ordered`, `qty_allocated`, `due_date`, `status_code` | Partial schedule via `qty_allocated` |
| `txn.production_plan` | Plan header | `plant_id`, `plan_no`, `horizon_type`, `period_start`, `period_end`, `status_code` | |
| `txn.production_plan_item` | Scheduled job | `production_plan_id`, `sales_order_line_id` nullable, `part_id`, `production_line_id`, `machine_id`, `shift_id`, `planned_date`, `planned_start_at`, `planned_end_at`, `qty`, `status_code`, `sort_order` | Header vs item status: [32](32_STATUS_STATE_MACHINE.md) |
| `txn.plan_approval` | Approval event | `production_plan_id`, `action`, `comment`, `acted_by`, `acted_at` + Audit\* | Append-style events |
| `txn.plan_release` | Release event | `production_plan_id`, `released_at`, `released_by`, `effective_from` + Audit\* | |
| `txn.plan_amendment` | Post-release change | `production_plan_id`, `reason_code_id`, `status_code`, `summary` | Reserved; unlocks Phase 2 |
| `txn.ot_window` | Approved OT | `plant_id`, `production_line_id` / `machine_id`, `start_at`, `end_at`, `status_code`, `reason_code_id` | Calendar Engine input |
| `txn.machine_shutdown` | Shutdown block | `plant_id`, `machine_id`, `production_line_id` nullable, `start_at`, `end_at`, `reason_code_id`, `status_code` | Calendar Engine input |

Status values are **codes** resolved via `master.status_code` (not free strings). Transition rules: [27_BUSINESS_FLOW.md](27_BUSINESS_FLOW.md), [32_STATUS_STATE_MACHINE.md](32_STATUS_STATE_MACHINE.md).

---

## 3. Schema: `history`

| Table | Purpose | Columns pattern |
|-------|---------|-----------------|
| `history.production_plan_history` | Plan header snapshots | `id`, `production_plan_id`, `version`, `change_type`, `before_json`, `after_json`, `changed_fields`, `changed_at`, `changed_by` |
| `history.production_plan_item_history` | Item snapshots | same pattern on `production_plan_item_id` |
| `history.entity_change` | Generic | `entity_type`, `entity_id`, plus snapshot fields |

History is append-only. `version` is the **live entity version after the change**. Multiple history rows may share analysis metadata but one primary row per successful mutation. See [16_HISTORY_STANDARD.md](16_HISTORY_STANDARD.md).

---

## 4. Schema: `log`

| Table | Purpose |
|-------|---------|
| `log.app_event` | Application events |
| `log.security_event` | Authz / security |
| `log.integration_event` | External calls |

Append-only; no Audit\*. See [17_LOG_STANDARD.md](17_LOG_STANDARD.md).

---

## 5. Schema: `config`

| Table | Purpose | Key columns | Ownership |
|-------|---------|-------------|-----------|
| `config.system_setting` | System key/value | `key`, `value_json`, `module` | Platform |
| `config.feature_flag` | Flags | `code`, `is_enabled`, `payload_json` | Platform |
| `config.user_preference` | Extensible prefs | `user_id` → `user_profile.id`, `key`, `value_json` | Keys **not** duplicated on profile (theme/font/compact stay on profile) |

---

## 6. Schema: `integration`

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `integration.connection` | External connection metadata | `code`, `system_type`, `config_json` (no secrets) |
| `integration.sync_job` | Sync run | `connection_id`, `direction`, `status_code`, `cursor_json`, `started_at`, `finished_at` |
| `integration.sync_job_item` | Per-record | `sync_job_id`, `external_key`, `status_code`, `payload_hash`, `error_message` |
| `integration.id_map` | ID mapping | `connection_id`, `entity_type`, `internal_id`, `external_id` |
| `integration.file_link` | Attachment metadata | `entity_type`, `entity_id`, `drive_file_id` nullable, `storage_path` nullable, `file_type_id`, `name` | Drive and/or Storage |
| `integration.outbox` | Domain event outbox | `event_type`, `payload_json`, `status_code`, `available_at`, `attempts` | [34](34_DOMAIN_EVENTS.md) |
| `integration.idempotency_key` | API idempotency | `key`, `user_id`, `route`, `request_hash`, `response_json`, `expires_at` | [08](08_API_STANDARD.md) |

---

## 7. Schema: `dashboard`

| Table | Purpose |
|-------|---------|
| `dashboard.layout` | Saved layout (`user_id`, optional `role_id`, `plant_id`) |
| `dashboard.widget` | Widget instance (`layout_id`, `type`, position/size, `query_key`) |

`query_key` must reference registered read-model queries — not ad-hoc SQL.

---

## 8. Future Module Tables (reserved names — do not duplicate)

| Module | Reserved tables |
|--------|-----------------|
| Production | `txn.production_job`, `txn.production_job_event` |
| Store | `txn.stock_balance`, `txn.stock_movement`, `txn.stock_valuation_event` |
| OEE | `txn.oee_sample`, `txn.downtime_event` |
| Quality | `txn.inspection`, `txn.ncr` |
| Maintenance | `txn.maintenance_order` (feeds calendar via shutdown/maintenance windows) |

---

## 9. Preference Ownership (single home)

| Preference | Home |
|------------|------|
| Theme, font scale, compact mode, sidebar collapsed | `master.user_profile` |
| Extensible key/value UI prefs | `config.user_preference` |
| Dashboard widget layouts | `dashboard.layout` / `widget` |

---

## Related Documents

- [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md)
- [26_MASTER_DATA.md](26_MASTER_DATA.md)
- [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md)
- [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md)
- [36_DOCUMENTATION_REVIEW.md](36_DOCUMENTATION_REVIEW.md)

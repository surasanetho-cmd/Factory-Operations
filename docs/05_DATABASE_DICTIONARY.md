# 05 — Database Dictionary

**Product:** Smart-Factory Manufacturing Platform  
**Phase coverage:** Masters + Calendar + Planning transactions + supporting history/log/config/integration/dashboard stubs

Column groups abbreviated as **Audit\*** = mandatory audit set from [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md).

---

## 1. Schema: `master`

### 1.1 Identity & Access

| Table | Purpose | Key columns (beyond Audit*) |
|-------|---------|-----------------------------|
| `master.user_profile` | App user profile linked to auth | `auth_user_id`, `employee_code`, `display_name`, `email`, `department_id`, `locale`, `timezone`, `theme_pref`, `font_scale`, `compact_mode` |
| `master.role` | Role definition | `code`, `name`, `description` |
| `master.permission` | Permission atom | `code`, `module`, `action`, `resource`, `description` |
| `master.role_permission` | Role ↔ permission | `role_id`, `permission_id` |
| `master.user_role` | User ↔ role | `user_id`, `role_id` |
| `master.department` | Org unit | `code`, `name`, `parent_id` |

### 1.2 Commercial & Product Masters

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `master.customer` | Customer | `code`, `name`, `contact_json` |
| `master.part` | Part list | `code`, `name`, `customer_id`, `revision`, `uom` |
| `master.material` | Material | `code`, `name`, `uom`, `spec_json` |
| `master.process` | Process step | `code`, `name`, `sequence_hint` |
| `master.part_process` | Part routing | `part_id`, `process_id`, `sequence`, `std_time_sec` |

### 1.3 Plant & Capacity Masters

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `master.production_line` | Line (110T…3200T) | `code`, `name`, `tonnage`, `sort_order` |
| `master.machine` | Machine | `code`, `name`, `production_line_id`, `machine_type`, `rated_capacity` |
| `master.shift` | Shift template | `code`, `name`, `start_time`, `end_time`, `break_minutes` |
| `master.calendar` | Named calendar | `code`, `name`, `timezone` |
| `master.holiday` | Holiday | `calendar_id`, `holiday_date`, `name`, `is_paid` |
| `master.capacity` | Nominal capacity | `production_line_id` / `machine_id`, `shift_id`, `jobs_per_day`, `hours_per_shift`, `effective_from`, `effective_to` |
| `master.reason_code` | Reason codes | `code`, `category`, `name` |
| `master.file_type` | Allowed file kinds | `code`, `mime_pattern`, `max_size_mb` |
| `master.notification_template` | Message templates | `code`, `channel`, `subject`, `body`, `locale` |

---

## 2. Schema: `txn` (Planning Phase)

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `txn.sales_order` | Customer order header (stub for flow) | `order_no`, `customer_id`, `order_date`, `status` |
| `txn.sales_order_line` | Order line | `sales_order_id`, `part_id`, `qty`, `due_date` |
| `txn.production_plan` | Plan header (day/week/month) | `plan_no`, `horizon_type`, `period_start`, `period_end`, `status` |
| `txn.production_plan_item` | Scheduled job | `production_plan_id`, `sales_order_line_id`, `part_id`, `production_line_id`, `machine_id`, `shift_id`, `planned_date`, `planned_start_at`, `planned_end_at`, `qty`, `status`, `sort_order` |
| `txn.plan_approval` | Approval record | `production_plan_id`, `action`, `comment`, `acted_by`, `acted_at` |
| `txn.plan_release` | Release to production | `production_plan_id`, `released_at`, `released_by`, `effective_from` |

**Plan statuses (config-driven codes):** `draft`, `submitted`, `approved`, `rejected`, `released`, `cancelled`.

---

## 3. Schema: `history`

| Table | Purpose |
|-------|---------|
| `history.production_plan_history` | Snapshots of plan header changes |
| `history.production_plan_item_history` | Snapshots of plan item moves / edits |
| `history.entity_change` | Generic change log (entity_type, entity_id, before_json, after_json, change_type) |

See [16_HISTORY_STANDARD.md](16_HISTORY_STANDARD.md).

---

## 4. Schema: `log`

| Table | Purpose |
|-------|---------|
| `log.app_event` | Application events |
| `log.security_event` | Authz failures, suspicious access |
| `log.integration_event` | External call results |

See [17_LOG_STANDARD.md](17_LOG_STANDARD.md).

---

## 5. Schema: `config`

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `config.system_setting` | Key/value settings | `key`, `value_json`, `module` |
| `config.feature_flag` | Feature toggles | `code`, `is_enabled`, `payload_json` |
| `config.user_preference` | Per-user UI prefs | `user_id`, `key`, `value_json` |

---

## 6. Schema: `integration`

| Table | Purpose |
|-------|---------|
| `integration.connection` | Named external connection metadata (no secrets) |
| `integration.sync_job` | Job run header |
| `integration.sync_job_item` | Per-record sync status |
| `integration.id_map` | External ↔ internal ID mapping |

---

## 7. Schema: `dashboard`

| Table | Purpose |
|-------|---------|
| `dashboard.layout` | Saved layout per user/role |
| `dashboard.widget` | Widget instance (type, position, size, query_key) |

---

## 8. Future Module Tables (stubs — do not implement until phase)

Reserved concepts (names may be finalized later; **do not duplicate**):

- Production: `txn.production_job`, `txn.production_job_event`
- Store: `txn.stock_balance`, `txn.stock_movement`
- OEE: `txn.oee_sample`, `txn.downtime_event`
- Quality: `txn.inspection`, `txn.ncr`
- Maintenance: `txn.maintenance_order`

---

## Related Documents

- [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md)
- [26_MASTER_DATA.md](26_MASTER_DATA.md)
- [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md)

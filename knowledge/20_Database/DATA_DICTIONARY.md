<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 05 — Database Dictionary (Complete)

**Product:** Smart-Factory Manufacturing Platform  
**Engine:** PostgreSQL  
**Status:** Design dictionary — **await SQL generation until architecture review is approved**  
**Architecture pack:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Table strategies (Purpose / PK / FK / Indexes / Soft Delete / Audit):**  
[43 Master](43_MASTER_DATA_LIST.md) · [44 Txn](44_TRANSACTION_LIST.md) · [45 History](45_HISTORY_LIST.md) · [46 Config](46_CONFIGURATION_LIST.md) · [47 Log](47_LOG_LIST.md) · [48 Integration](48_INTEGRATION_LIST.md) · [49 Dashboard](49_DASHBOARD_LIST.md)

**Patterns:** **A** / **J** / **H** / **L** / **E** — [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)  
**Null:** columns are NOT NULL unless marked **N** (nullable).  
**Types:** PostgreSQL types.

Audit\* columns for pattern **A** are not repeated on every table — assume present unless another pattern is stated.

---

## 0. Conventions in this dictionary

| Symbol | Meaning |
|--------|---------|
| PK | Primary key |
| FK | Foreign key (see [38](38_FOREIGN_KEYS.md)) |
| UK | Unique / partial unique |
| N | Nullable |
| **A** | Full Audit\* |
| `timestamptz` | Timestamp with time zone |
| `numeric(18,6)` | Quantities / factors (adjust scale per seed if needed) |

---

## 1. Schema `master`

### 1.1 `master.plant` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | UK active; seed `SF1` |
| `name` | `text` | |
| `timezone` | `text` | IANA TZ, e.g. `Asia/Bangkok` |
| `default_calendar_id` | `uuid` | N, FK → `calendar`; see circular rule |

### 1.2 `master.department` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK → plant |
| `parent_id` | `uuid` | N, FK → department |
| `code` | `text` | UK `(plant_id, code)` active |
| `name` | `text` | |

### 1.3 `master.user_profile` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `auth_user_id` | `uuid` | UK NOT NULL → `auth.users` |
| `employee_code` | `text` | UK active (optionally per plant) |
| `display_name` | `text` | |
| `email` | `text` | |
| `department_id` | `uuid` | N, FK |
| `default_plant_id` | `uuid` | N, FK → plant |
| `locale` | `text` | default `en` |
| `timezone` | `text` | N; fallback plant TZ |
| `theme_pref` | `text` | `light`\|`dark`\|`auto` |
| `font_scale` | `numeric(4,2)` | e.g. `1.00` |
| `compact_mode` | `boolean` | default false |
| `sidebar_collapsed` | `boolean` | default false |

### 1.4 `master.role` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | UK active; `admin`, `planner`, … |
| `name` | `text` | |
| `description` | `text` | N |

### 1.5 `master.permission` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | UK; `module.resource.action` |
| `module` | `text` | |
| `action` | `text` | |
| `resource` | `text` | |
| `description` | `text` | N |

### 1.6 `master.role_permission` — **J**

| Column | Type | Notes |
|--------|------|-------|
| `role_id` | `uuid` | FK |
| `permission_id` | `uuid` | FK |
| | | UK `(role_id, permission_id)` active |

### 1.7 `master.user_role` — **J**

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | `uuid` | FK → user_profile |
| `role_id` | `uuid` | FK |
| `plant_id` | `uuid` | N, FK; NULL = all granted plants policy |
| | | UK `(user_id, role_id, plant_id)` active (use sentinel if needed for NULL) |

### 1.8 `master.uom` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | UK; `EA`, `KG`, … |
| `name` | `text` | |
| `dimension` | `text` | `count`\|`mass`\|`length`\|`time`\|… |

### 1.9 `master.uom_conversion` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `from_uom_id` | `uuid` | FK |
| `to_uom_id` | `uuid` | FK |
| `factor` | `numeric(18,8)` | multiply from→to; > 0 |
| | | UK `(from_uom_id, to_uom_id)` active |

### 1.10 `master.customer` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | N, FK |
| `code` | `text` | UK `(plant_id, code)` or global UK |
| `name` | `text` | |
| `contact_json` | `jsonb` | N |

### 1.11 `master.part` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `customer_id` | `uuid` | N, FK |
| `code` | `text` | UK `(plant_id, code)` active |
| `name` | `text` | |
| `revision` | `text` | N |
| `uom_id` | `uuid` | FK → uom |

### 1.12 `master.material` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `code` | `text` | UK `(plant_id, code)` |
| `name` | `text` | |
| `uom_id` | `uuid` | FK |
| `spec_json` | `jsonb` | N |

### 1.13 `master.part_material` — **J** (+ optional `version` if treated as business)

| Column | Type | Notes |
|--------|------|-------|
| `part_id` | `uuid` | FK |
| `material_id` | `uuid` | FK |
| `qty_per` | `numeric(18,6)` | ≥ 0 |
| `uom_id` | `uuid` | FK |
| `sequence` | `integer` | default 1 |
| | | UK `(part_id, material_id, sequence)` active |

### 1.14 `master.process` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | N, FK |
| `code` | `text` | UK |
| `name` | `text` | |
| `sequence_hint` | `integer` | N |

### 1.15 `master.part_process` — **J**

| Column | Type | Notes |
|--------|------|-------|
| `part_id` | `uuid` | FK |
| `process_id` | `uuid` | FK |
| `sequence` | `integer` | |
| `std_time_sec` | `integer` | N |
| | | UK `(part_id, sequence)` active |

### 1.16 `master.calendar` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | N, FK |
| `code` | `text` | UK `(plant_id, code)` |
| `name` | `text` | |
| `timezone` | `text` | IANA |

### 1.17 `master.holiday` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `calendar_id` | `uuid` | FK |
| `holiday_date` | `date` | |
| `name` | `text` | |
| `is_paid` | `boolean` | default true |
| | | UK `(calendar_id, holiday_date)` active |

### 1.18 `master.production_line` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `code` | `text` | UK `(plant_id, code)`; `PL-110T`… |
| `name` | `text` | |
| `tonnage` | `integer` | |
| `sort_order` | `integer` | |
| `calendar_id` | `uuid` | N, FK → calendar |

### 1.19 `master.machine` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `production_line_id` | `uuid` | FK |
| `code` | `text` | UK `(plant_id, code)` |
| `name` | `text` | |
| `machine_type` | `text` | N |
| `rated_capacity` | `numeric(18,6)` | N |
| `calendar_id` | `uuid` | N, FK |

### 1.20 `master.shift` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `code` | `text` | UK `(plant_id, code)` |
| `name` | `text` | |
| `start_time` | `time` | local civil time |
| `end_time` | `time` | |
| `break_minutes` | `integer` | default 0 |
| `crosses_midnight` | `boolean` | default false |

### 1.21 `master.shift_assignment` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `shift_id` | `uuid` | FK |
| `production_line_id` | `uuid` | N, FK |
| `machine_id` | `uuid` | N, FK |
| `effective_from` | `date` | |
| `effective_to` | `date` | N |
| `weekday_mask` | `smallint` | bitmask Mon–Sun (1=Mon …) |
| | | CHECK not both line and machine |

### 1.22 `master.capacity` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `production_line_id` | `uuid` | N, FK |
| `machine_id` | `uuid` | N, FK |
| `shift_id` | `uuid` | FK |
| `jobs_per_day` | `integer` | N |
| `hours_per_shift` | `numeric(8,2)` | N |
| `effective_from` | `date` | |
| `effective_to` | `date` | N |
| | | CHECK XOR line/machine |

### 1.23 `master.status_code` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `entity_type` | `text` | e.g. `production_plan` |
| `code` | `text` | |
| `name` | `text` | |
| `sort_order` | `integer` | |
| `is_terminal` | `boolean` | default false |
| | | UK `(entity_type, code)` active |

### 1.24 `master.reason_code` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | N, FK |
| `code` | `text` | UK |
| `category` | `text` | e.g. `ot`, `shutdown`, `amendment` |
| `name` | `text` | |

### 1.25 `master.file_type` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | UK |
| `mime_pattern` | `text` | |
| `max_size_mb` | `numeric(8,2)` | |

### 1.26 `master.notification_template` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | event code; UK `(code, channel, locale)` |
| `channel` | `text` | `telegram`, … |
| `subject` | `text` | N |
| `body` | `text` | placeholders `{{…}}` |
| `locale` | `text` | |

### 1.27 `master.number_sequence` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `doc_type` | `text` | `sales_order`, `production_plan`, … |
| `prefix` | `text` | |
| `next_value` | `bigint` | |
| `pad_length` | `integer` | |
| `reset_rule` | `text` | `never`\|`yearly`\|`monthly` |
| `last_reset_at` | `timestamptz` | N |
| | | UK `(plant_id, doc_type)` active |

---

## 2. Schema `txn`

### 2.1 `txn.sales_order` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `order_no` | `text` | UK active |
| `customer_id` | `uuid` | FK |
| `order_date` | `date` | |
| `status_code` | `text` | entity `sales_order` |
| `remark` | `text` | N |

### 2.2 `txn.sales_order_line` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `sales_order_id` | `uuid` | FK |
| `line_no` | `integer` | UK `(sales_order_id, line_no)` |
| `part_id` | `uuid` | FK |
| `qty_ordered` | `numeric(18,6)` | ≥ 0 |
| `qty_allocated` | `numeric(18,6)` | default 0 |
| `due_date` | `date` | N |
| `status_code` | `text` | entity `sales_order_line` |
| `uom_id` | `uuid` | N, FK; default part UoM |

### 2.3 `txn.production_plan` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `plan_no` | `text` | UK active |
| `horizon_type` | `text` | `daily`\|`weekly`\|`monthly` |
| `period_start` | `date` | |
| `period_end` | `date` | |
| `status_code` | `text` | entity `production_plan` |
| `title` | `text` | N |
| `lease_owner_id` | `uuid` | N, FK user_profile |
| `lease_expires_at` | `timestamptz` | N |

### 2.4 `txn.production_plan_item` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `production_plan_id` | `uuid` | FK |
| `sales_order_line_id` | `uuid` | N, FK |
| `part_id` | `uuid` | FK |
| `production_line_id` | `uuid` | FK |
| `machine_id` | `uuid` | N, FK |
| `shift_id` | `uuid` | N, FK |
| `planned_date` | `date` | civil date in calendar TZ |
| `planned_start_at` | `timestamptz` | |
| `planned_end_at` | `timestamptz` | > start |
| `qty` | `numeric(18,6)` | ≥ 0 |
| `status_code` | `text` | entity `production_plan_item` |
| `sort_order` | `integer` | default 0 |
| `remark` | `text` | N |

### 2.5 `txn.plan_approval` — **E**

| Column | Type | Notes |
|--------|------|-------|
| `production_plan_id` | `uuid` | FK |
| `action` | `text` | `submit`\|`approve`\|`reject` |
| `comment` | `text` | N |
| `acted_by` | `uuid` | FK user_profile |
| `acted_at` | `timestamptz` | |

### 2.6 `txn.plan_release` — **E**

| Column | Type | Notes |
|--------|------|-------|
| `production_plan_id` | `uuid` | FK |
| `released_by` | `uuid` | FK |
| `released_at` | `timestamptz` | |
| `effective_from` | `timestamptz` | |

### 2.7 `txn.plan_amendment` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `production_plan_id` | `uuid` | FK |
| `amendment_no` | `text` | UK active |
| `reason_code_id` | `uuid` | N, FK |
| `status_code` | `text` | entity `plan_amendment` |
| `summary` | `text` | |
| `payload_json` | `jsonb` | N; structured change set |

### 2.8 `txn.ot_window` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `production_line_id` | `uuid` | N, FK |
| `machine_id` | `uuid` | N, FK |
| `start_at` | `timestamptz` | |
| `end_at` | `timestamptz` | > start |
| `status_code` | `text` | entity `ot_window` |
| `reason_code_id` | `uuid` | N, FK |
| | | CHECK resource present (XOR preferred) |

### 2.9 `txn.machine_shutdown` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `plant_id` | `uuid` | FK |
| `machine_id` | `uuid` | FK |
| `production_line_id` | `uuid` | N, FK |
| `start_at` | `timestamptz` | |
| `end_at` | `timestamptz` | > start |
| `status_code` | `text` | entity `machine_shutdown` |
| `reason_code_id` | `uuid` | N, FK |

---

## 3. Schema `history` — pattern **H**

### 3.1 `history.production_plan_history`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK |
| `production_plan_id` | `uuid` | FK |
| `version` | `integer` | live version after change |
| `change_type` | `text` | |
| `before_json` | `jsonb` | N |
| `after_json` | `jsonb` | N |
| `changed_fields` | `text[]` | N |
| `changed_at` | `timestamptz` | |
| `changed_by` | `uuid` | FK user_profile |

### 3.2 `history.production_plan_item_history`

Same as above with `production_plan_item_id`.

### 3.3 `history.entity_change`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK |
| `entity_type` | `text` | |
| `entity_id` | `uuid` | |
| `version` | `integer` | N |
| `change_type` | `text` | |
| `before_json` / `after_json` | `jsonb` | N |
| `changed_fields` | `text[]` | N |
| `changed_at` | `timestamptz` | |
| `changed_by` | `uuid` | N, FK |

---

## 4. Schema `log` — pattern **L**

### 4.1 `log.app_event`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK |
| `level` | `text` | `debug`\|`info`\|`warn`\|`error` |
| `module` | `text` | |
| `event_code` | `text` | |
| `message` | `text` | |
| `context_json` | `jsonb` | N |
| `request_id` | `text` | N |
| `user_id` | `uuid` | N, FK user_profile |
| `plant_id` | `uuid` | N |
| `created_at` | `timestamptz` | |

### 4.2 `log.security_event`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK |
| `event_code` | `text` | |
| `message` | `text` | |
| `actor_user_id` | `uuid` | N |
| `ip_address` | `inet` | N |
| `context_json` | `jsonb` | N |
| `created_at` | `timestamptz` | |

### 4.3 `log.integration_event`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK |
| `connection_id` | `uuid` | N, FK |
| `direction` | `text` | `in`\|`out` |
| `status_code` | `text` | |
| `latency_ms` | `integer` | N |
| `message` | `text` | N |
| `context_json` | `jsonb` | N |
| `created_at` | `timestamptz` | |

---

## 5. Schema `config` — **A**

### 5.1 `config.system_setting`

| Column | Type | Notes |
|--------|------|-------|
| `key` | `text` | UK active |
| `value_json` | `jsonb` | |
| `module` | `text` | N |

### 5.2 `config.feature_flag`

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | UK |
| `is_enabled` | `boolean` | |
| `payload_json` | `jsonb` | N |

### 5.3 `config.user_preference`

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | `uuid` | FK user_profile |
| `key` | `text` | |
| `value_json` | `jsonb` | |
| | | UK `(user_id, key)` active |

---

## 6. Schema `integration`

### 6.1 `integration.connection` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `code` | `text` | UK |
| `system_type` | `text` | `google_drive`\|`telegram`\|`sap`\|`openai` |
| `plant_id` | `uuid` | N, FK |
| `config_json` | `jsonb` | no secrets |

### 6.2 `integration.sync_job` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `connection_id` | `uuid` | FK |
| `direction` | `text` | |
| `status_code` | `text` | entity `sync_job` |
| `cursor_json` | `jsonb` | N |
| `started_at` | `timestamptz` | N |
| `finished_at` | `timestamptz` | N |

### 6.3 `integration.sync_job_item` — **J** or minimal

| Column | Type | Notes |
|--------|------|-------|
| `sync_job_id` | `uuid` | FK |
| `external_key` | `text` | |
| `status_code` | `text` | |
| `payload_hash` | `text` | N |
| `error_message` | `text` | N |

### 6.4 `integration.id_map` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `connection_id` | `uuid` | FK |
| `entity_type` | `text` | |
| `internal_id` | `uuid` | |
| `external_id` | `text` | |
| | | UK `(connection_id, entity_type, external_id)` |

### 6.5 `integration.file_link` — **A**

| Column | Type | Notes |
|--------|------|-------|
| `entity_type` | `text` | |
| `entity_id` | `uuid` | |
| `file_type_id` | `uuid` | FK |
| `name` | `text` | |
| `drive_file_id` | `text` | N |
| `storage_path` | `text` | N |
| `checksum` | `text` | N |

### 6.6 `integration.outbox` — **L**-like + status

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK |
| `event_type` | `text` | |
| `aggregate_type` | `text` | |
| `aggregate_id` | `uuid` | |
| `payload_json` | `jsonb` | |
| `status_code` | `text` | `pending`\|`processing`\|`done`\|`error` |
| `available_at` | `timestamptz` | default now() |
| `attempts` | `integer` | default 0 |
| `last_error` | `text` | N |
| `created_at` | `timestamptz` | |
| `processed_at` | `timestamptz` | N |

### 6.7 `integration.idempotency_key`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK |
| `key` | `text` | |
| `user_id` | `uuid` | N, FK |
| `route` | `text` | |
| `request_hash` | `text` | |
| `response_json` | `jsonb` | N |
| `expires_at` | `timestamptz` | |
| `created_at` | `timestamptz` | |
| | | UK `(user_id, route, key)` |

---

## 7. Schema `dashboard` — **A**

### 7.1 `dashboard.layout`

| Column | Type | Notes |
|--------|------|-------|
| `user_id` | `uuid` | N, FK |
| `role_id` | `uuid` | N, FK |
| `plant_id` | `uuid` | N, FK |
| `code` | `text` | |
| `name` | `text` | |

### 7.2 `dashboard.widget`

| Column | Type | Notes |
|--------|------|-------|
| `layout_id` | `uuid` | FK; ON DELETE CASCADE |
| `widget_type` | `text` | |
| `query_key` | `text` | registered read-model key |
| `pos_x` | `integer` | |
| `pos_y` | `integer` | |
| `width` | `integer` | |
| `height` | `integer` | |
| `config_json` | `jsonb` | N |

---

## 8. Reserved future tables (names locked)

| Table | Purpose | Key columns (preview) |
|-------|---------|----------------------|
| `txn.production_job` | Execution of released item | `plant_id`, `job_no`, `production_plan_item_id`, `status_code` |
| `txn.production_job_event` | Start/stop/scrap events | `production_job_id`, `event_type`, `event_at` |
| `txn.stock_balance` | On-hand | `plant_id`, `material_id`/`part_id`, `qty`, `uom_id` |
| `txn.stock_movement` | Movements | `movement_type`, `qty`, refs |
| `txn.stock_valuation_event` | Valuation hooks | `method`, `amount`, `posted_at` |
| `txn.oee_sample` | Time-series sample | `machine_id`, `sampled_at`, A/P/Q metrics |
| `txn.downtime_event` | Downtime | `machine_id`, `start_at`, `end_at`, `reason_code_id` |
| `txn.inspection` | QC | `production_job_id`, `result_code` |
| `txn.ncr` | Non-conformance | `ncr_no`, `status_code` |
| `txn.maintenance_order` | PM/CM | `machine_id`, `window_start`, `window_end` |

Do not invent alternate names for these concepts.

---

## 9. Preference ownership

| Preference | Table |
|------------|-------|
| Theme / font / compact / sidebar | `master.user_profile` |
| Extensible keys | `config.user_preference` |
| Dashboard grid | `dashboard.layout` / `widget` |

---

## Related Documents

- [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)
- [43_MASTER_DATA_LIST.md](43_MASTER_DATA_LIST.md)
- [44_TRANSACTION_LIST.md](44_TRANSACTION_LIST.md)
- [45_HISTORY_LIST.md](45_HISTORY_LIST.md)
- [46_CONFIGURATION_LIST.md](46_CONFIGURATION_LIST.md)
- [47_LOG_LIST.md](47_LOG_LIST.md)
- [48_INTEGRATION_LIST.md](48_INTEGRATION_LIST.md)
- [49_DASHBOARD_LIST.md](49_DASHBOARD_LIST.md)
- [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md)
- [37_TABLE_RELATIONSHIPS.md](37_TABLE_RELATIONSHIPS.md)
- [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)
- [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md)

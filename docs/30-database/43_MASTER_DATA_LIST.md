# 43 — Master Data List

**Schema:** `master`  
**Part of:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Columns:** [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)  
**Patterns:** Soft delete + Audit default = **A** unless noted **J**.  
**No SQL yet.**

---

## Inventory

| Table | Pattern | Plant-scoped |
|-------|---------|--------------|
| `plant` | A | — (root) |
| `department` | A | Yes |
| `user_profile` | A | default plant |
| `role` | A | Global |
| `permission` | A | Global |
| `role_permission` | J | — |
| `user_role` | J | Optional |
| `uom` | A | Global |
| `uom_conversion` | A | Global |
| `customer` | A | Optional |
| `part` | A | Yes |
| `material` | A | Yes |
| `part_material` | J | via part |
| `process` | A | Optional |
| `part_process` | J | via part |
| `calendar` | A | Optional |
| `holiday` | A | via calendar |
| `production_line` | A | Yes |
| `machine` | A | Yes |
| `shift` | A | Yes |
| `shift_assignment` | A | Yes |
| `capacity` | A | Yes |
| `status_code` | A | Global |
| `reason_code` | A | Optional |
| `file_type` | A | Global |
| `notification_template` | A | Global |
| `number_sequence` | A | Yes |

---

## Tables

### `master.plant`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Site/plant root for multi-site scalability; owns timezone and default calendar. |
| **Relationships** | 1:N departments, lines, machines, shifts, plans, orders; 0..1 default calendar. |
| **Primary Key** | `id` UUID |
| **Foreign Keys** | `default_calendar_id` → `calendar.id` (nullable; circular create order) |
| **Indexes** | `uq_plant_code_active (code)` |
| **Future scalability** | Add plants without schema change; RLS by `plant_id` elsewhere. |
| **Soft Delete** | Pattern A; restrict delete if children exist (prefer deactivate). |
| **Audit** | Pattern A |

### `master.department`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Organizational units (tree) under a plant. |
| **Relationships** | N:1 plant; optional parent department; 1:N users. |
| **PK** | `id` UUID |
| **FKs** | `plant_id` → plant; `parent_id` → department |
| **Indexes** | `uq_department_plant_code_active`; `ix` on `plant_id`, `parent_id` |
| **Scalability** | Deep trees; optional area/work-center later under plant. |
| **Soft Delete** | A |
| **Audit** | A |

### `master.user_profile`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Application user linked to Supabase Auth; shell preferences. |
| **Relationships** | 1:1 `auth.users`; N:1 department/plant; 1:N user_role, prefs, layouts. |
| **PK** | `id` UUID |
| **FKs** | `auth_user_id` → `auth.users`; `department_id`; `default_plant_id` |
| **Indexes** | `uq` auth_user_id; `uq` employee_code active |
| **Scalability** | Multi-plant via `user_role.plant_id`; prefs stay on profile vs config. |
| **Soft Delete** | A (disable login path when deleted) |
| **Audit** | A |

### `master.role` / `master.permission`

| Aspect | Detail |
|--------|--------|
| **Purpose** | RBAC role definitions and atomic permissions (`module.resource.action`). |
| **Relationships** | N:M via `role_permission`; roles to users via `user_role`. |
| **PK** | `id` UUID each |
| **FKs** | none (global) |
| **Indexes** | `uq` code active each |
| **Scalability** | Add permissions per module without schema change. |
| **Soft Delete** | A |
| **Audit** | A |

### `master.role_permission` / `master.user_role`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Junction assignments for RBAC (and optional plant-scoped role grant). |
| **Relationships** | role↔permission; user↔role↔optional plant. |
| **PK** | `id` UUID |
| **FKs** | role_id, permission_id / user_id, role_id, plant_id |
| **Indexes** | unique pairs/triples active; `ix_user_role_user` |
| **Scalability** | Plant-scoped grants for multi-site RLS. |
| **Soft Delete** | **J** |
| **Audit** | **J** (created_by + soft delete) |

### `master.uom` / `master.uom_conversion`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Units of measure and conversion factors (no free-text UoM). |
| **Relationships** | Used by part, material, BOM, order lines. |
| **PK** | `id` UUID |
| **FKs** | conversion: from_uom_id, to_uom_id → uom |
| **Indexes** | uq code; uq conversion pair; CHECK factor > 0 |
| **Scalability** | New UoMs/conversions without code deploy. |
| **Soft Delete / Audit** | A |

### `master.customer`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Customer master for orders and parts. |
| **Relationships** | 1:N parts, sales_orders; optional plant. |
| **PK** | `id` UUID |
| **FKs** | `plant_id` → plant (N) |
| **Indexes** | uq (plant_id, code) active |
| **Scalability** | Shared vs plant-local customers via nullable plant_id. |
| **Soft Delete / Audit** | A |

### `master.part`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Finished/part list for planning and orders. |
| **Relationships** | N:1 customer, uom, plant; BOM and routing children; plan items. |
| **PK** | `id` UUID |
| **FKs** | plant_id, customer_id, uom_id |
| **Indexes** | uq (plant_id, code); ix customer_id |
| **Scalability** | Revision field; future effectivity without new table if careful. |
| **Soft Delete / Audit** | A |

### `master.material`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Raw/component materials for BOM and future Store. |
| **Relationships** | N:1 plant, uom; N:M parts via part_material. |
| **PK** | `id` UUID |
| **FKs** | plant_id, uom_id |
| **Indexes** | uq (plant_id, code) |
| **Scalability** | Stock tables reference material without redesign. |
| **Soft Delete / Audit** | A |

### `master.part_material` (BOM)

| Aspect | Detail |
|--------|--------|
| **Purpose** | Bill of materials link part → material with qty_per. |
| **Relationships** | N:1 part, material, uom. |
| **PK** | `id` UUID |
| **FKs** | part_id, material_id, uom_id |
| **Indexes** | uq (part_id, material_id, sequence) |
| **Scalability** | Multi-level BOM later via component part_id extension (ADR). |
| **Soft Delete / Audit** | **J** |

### `master.process` / `master.part_process`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Process catalog and part routing with sequence / std time. |
| **Relationships** | part N:M process. |
| **PK** | `id` UUID |
| **FKs** | part_id, process_id; process.plant_id optional |
| **Indexes** | uq part+sequence; process code |
| **Scalability** | Supports future Production routing confirmation. |
| **Soft Delete / Audit** | process A; part_process **J** |

### `master.calendar` / `master.holiday`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Named calendars and holiday dates for Calendar Engine. |
| **Relationships** | plant optional; holidays 1:N; referenced by line/machine/plant default. |
| **PK** | `id` UUID |
| **FKs** | calendar.plant_id; holiday.calendar_id |
| **Indexes** | uq calendar (plant_id, code); uq holiday (calendar_id, date) |
| **Scalability** | Per-line calendars; multi-TZ plants. |
| **Soft Delete / Audit** | A |

### `master.production_line`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Production lines (110T–3200T seed). |
| **Relationships** | N:1 plant, optional calendar; 1:N machines, capacities, plan items. |
| **PK** | `id` UUID |
| **FKs** | plant_id, calendar_id |
| **Indexes** | uq (plant_id, code); ix sort_order |
| **Scalability** | Add lines via seed/admin — never hardcode. |
| **Soft Delete / Audit** | A |

### `master.machine`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Machines on a line for resource planning. |
| **Relationships** | N:1 plant, line; optional calendar; plan items, shutdowns, capacity. |
| **PK** | `id` UUID |
| **FKs** | plant_id, production_line_id, calendar_id |
| **Indexes** | uq (plant_id, code); ix production_line_id |
| **Scalability** | OEE samples attach here later. |
| **Soft Delete / Audit** | A |

### `master.shift` / `master.shift_assignment`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Shift templates and dated/scoped assignments (plant/line/machine). |
| **Relationships** | shift 1:N assignments; assignments scope line XOR machine or plant-wide. |
| **PK** | `id` UUID |
| **FKs** | plant_id, shift_id, optional line/machine |
| **Indexes** | uq shift (plant_id, code); ix assignment (plant_id, effective_from) |
| **Scalability** | Weekday_mask + effective range supports complex rotas. |
| **Soft Delete / Audit** | A |
| **CHECK** | assignment not both line and machine |

### `master.capacity`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Nominal jobs/hours capacity per line XOR machine + shift + effectivity. |
| **Relationships** | plant, shift, exactly one of line/machine. |
| **PK** | `id` UUID |
| **FKs** | plant_id, shift_id, production_line_id, machine_id |
| **Indexes** | ix line+shift+from; ix machine+shift+from |
| **Scalability** | Versioned by effective_from/to; events invalidate projections. |
| **Soft Delete / Audit** | A |
| **CHECK** | XOR line/machine |

### `master.status_code`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Config-driven status values per entity_type (no Postgres ENUMs). |
| **Relationships** | Logical reference from txn status_code columns. |
| **PK** | `id` UUID |
| **FKs** | none |
| **Indexes** | uq (entity_type, code) |
| **Scalability** | New entities add rows only. |
| **Soft Delete / Audit** | A |

### `master.reason_code`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Reason codes for OT, shutdown, amendment, overrides. |
| **Relationships** | Referenced by OT, shutdown, amendment. |
| **PK** | `id` UUID |
| **FKs** | optional plant_id |
| **Indexes** | uq code (plant-scoped or global) |
| **Scalability** | Category field groups reasons. |
| **Soft Delete / Audit** | A |

### `master.file_type`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Allowed attachment kinds (mime/size). |
| **Relationships** | 1:N file_link. |
| **PK** | `id` UUID |
| **FKs** | none |
| **Indexes** | uq code |
| **Scalability** | Drive/Storage share same types. |
| **Soft Delete / Audit** | A |

### `master.notification_template`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Message templates for Telegram/etc. (no hardcoded copy). |
| **Relationships** | Matched to outbox event_type by code. |
| **PK** | `id` UUID |
| **FKs** | none |
| **Indexes** | uq (code, channel, locale) |
| **Scalability** | New channels/locales as rows. |
| **Soft Delete / Audit** | A |

### `master.number_sequence`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Document number allocation (plan_no, order_no, …). |
| **Relationships** | N:1 plant; used transactionally when inserting docs. |
| **PK** | `id` UUID |
| **FKs** | plant_id |
| **Indexes** | uq (plant_id, doc_type) |
| **Scalability** | reset_rule yearly/monthly; row lock on allocate. |
| **Soft Delete / Audit** | A |

---

## Related Documents

- [26_MASTER_DATA.md](../10-business/26_MASTER_DATA.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)
- [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md)

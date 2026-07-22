# 44 — Transaction List

**Schema:** `txn`  
**Part of:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Columns:** [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)  
**Default pattern:** Soft delete + Audit = **A** (events **E**).  
**No SQL yet.**

---

## Inventory (Phase 1)

| Table | Pattern | Purpose summary |
|-------|---------|-----------------|
| `sales_order` | A | Demand header |
| `sales_order_line` | A | Demand lines + allocation |
| `production_plan` | A | Plan header (day/week/month) |
| `production_plan_item` | A | Scheduled jobs |
| `plan_approval` | E | Submit/approve/reject events |
| `plan_release` | E | Release events |
| `plan_amendment` | A | Post-release controlled changes |
| `ot_window` | A | Approved overtime windows |
| `machine_shutdown` | A | Unavailability blocks |

## Reserved (future — names locked)

| Table | Module |
|-------|--------|
| `production_job`, `production_job_event` | PROD |
| `stock_balance`, `stock_movement`, `stock_valuation_event` | STORE |
| `oee_sample`, `downtime_event` | OEE |
| `inspection`, `ncr` | QA |
| `maintenance_order` | MAINT |

---

## Phase 1 tables

### `txn.sales_order`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Customer order header entering the Order → Planning flow. |
| **Relationships** | N:1 plant, customer; 1:N lines. |
| **PK** | `id` UUID |
| **FKs** | plant_id, customer_id |
| **Indexes** | uq order_no active; ix (plant_id, order_date); ix customer_id |
| **Scalability** | SAP sync via id_map; plant-scoped numbers. |
| **Soft Delete** | A; lines remain referenced historically. |
| **Audit** | A; status via status_code |

### `txn.sales_order_line`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Ordered part/qty/due; tracks `qty_allocated` to plan items. |
| **Relationships** | N:1 order, part; 0..N plan items. |
| **PK** | `id` UUID |
| **FKs** | sales_order_id, part_id, uom_id (N) |
| **Indexes** | uq (sales_order_id, line_no); ix part_id |
| **Scalability** | Partial scheduling without splitting order rows. |
| **Soft Delete / Audit** | A |

### `txn.production_plan`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Planning document for a horizon (daily/weekly/monthly). |
| **Relationships** | N:1 plant; 1:N items, approvals, releases, amendments; optional lease owner. |
| **PK** | `id` UUID |
| **FKs** | plant_id, lease_owner_id |
| **Indexes** | uq plan_no; ix (plant_id, period_start, period_end); ix status_code |
| **Scalability** | Month boards = many items; lease reduces 409 storms; projections later. |
| **Soft Delete** | A (cascade soft-delete policy for items in domain service). |
| **Audit** | A + history on change |

### `txn.production_plan_item`

| Aspect | Detail |
|--------|--------|
| **Purpose** | One scheduled job on timeline/resource board (drag-drop unit). |
| **Relationships** | N:1 plan, part, line; optional machine, shift, order line. |
| **PK** | `id` UUID |
| **FKs** | production_plan_id, sales_order_line_id, part_id, production_line_id, machine_id, shift_id |
| **Indexes** | ix plan_id; ix (line_id, planned_start_at); ix (machine_id, planned_start_at); ix planned_date; future GiST range |
| **Scalability** | Hot path for Calendar `checkFit`; cache windows; optional range index later. |
| **Soft Delete** | A |
| **Audit** | A + item history on move/edit; CHECK end > start |

### `txn.plan_approval`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Append-style workflow events: submit / approve / reject. |
| **Relationships** | N:1 plan; acted_by user. |
| **PK** | `id` UUID |
| **FKs** | production_plan_id, acted_by |
| **Indexes** | ix (production_plan_id, acted_at DESC) |
| **Scalability** | Immutable event log; header status remains source of current state. |
| **Soft Delete** | A (rare); prefer retain events |
| **Audit** | **E** (Audit\* + acted_at/by) |

### `txn.plan_release`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Records release of plan to Production. |
| **Relationships** | N:1 plan; released_by user. |
| **PK** | `id` UUID |
| **FKs** | production_plan_id, released_by |
| **Indexes** | ix (production_plan_id, released_at DESC) |
| **Scalability** | Production jobs key off released snapshot + outbox `plan.released`. |
| **Soft Delete / Audit** | **E** |

### `txn.plan_amendment`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Controlled post-release change set (no silent edits). |
| **Relationships** | N:1 plan; optional reason_code. |
| **PK** | `id` UUID |
| **FKs** | production_plan_id, reason_code_id |
| **Indexes** | uq amendment_no; ix production_plan_id |
| **Scalability** | Unlocks Phase 2 corrections without rewriting release immutability. |
| **Soft Delete / Audit** | A |

### `txn.ot_window`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Approved overtime intervals consumed by Calendar Engine. |
| **Relationships** | N:1 plant; line and/or machine; reason. |
| **PK** | `id` UUID |
| **FKs** | plant_id, production_line_id, machine_id, reason_code_id |
| **Indexes** | ix (plant_id, start_at, end_at); ix line/machine + start |
| **Scalability** | Cache invalidation via `calendar.windows_changed` outbox. |
| **Soft Delete / Audit** | A; CHECK time order + resource present |

### `txn.machine_shutdown`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Machine (optional line) unavailability for planning exclusion. |
| **Relationships** | N:1 plant, machine; optional line; reason. |
| **PK** | `id` UUID |
| **FKs** | plant_id, machine_id, production_line_id, reason_code_id |
| **Indexes** | ix (machine_id, start_at, end_at) |
| **Scalability** | Maintenance module can generate these rows later. |
| **Soft Delete / Audit** | A |

---

## Future reserved tables (summary only)

| Table | Purpose | Scalability note |
|-------|---------|------------------|
| `production_job` | Execute released item | High write; partition by date later |
| `production_job_event` | Start/stop/scrap | Append-only high volume |
| `stock_balance` / `stock_movement` | Inventory | Movement ledger; valuation events separate |
| `oee_sample` | Time-series OEE | Partition + retention mandatory |
| `downtime_event` | Downtime | Feeds OEE + calendar |
| `inspection` / `ncr` | Quality | Links to jobs |
| `maintenance_order` | PM/CM windows | Writes calendar inputs |

Do **not** invent alternate names.

---

## Related Documents

- [27_BUSINESS_FLOW.md](../10-business/27_BUSINESS_FLOW.md)
- [32_STATUS_STATE_MACHINE.md](32_STATUS_STATE_MACHINE.md)
- [18_CALENDAR_ENGINE.md](../20-architecture/18_CALENDAR_ENGINE.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

# 27 — Business Flow

**Product:** Smart-Factory Manufacturing Platform

---

## 1. End-to-End Manufacturing Flow

```text
Order → Planning → Approve → Release → Production → QC → Store → Shipping
```

```mermaid
flowchart LR
  Order[Order]
  Plan[Planning]
  Approve[Approve]
  Release[Release]
  Prod[Production]
  QC[QC]
  Store[Store]
  Ship[Shipping]
  Order --> Plan --> Approve --> Release --> Prod --> QC --> Store --> Ship
```

Phase 1 implements through **Release**. Downstream stages are specified for architecture continuity.

---

## 2. Stage Definitions

| Stage | Owner module | Description |
|-------|--------------|-------------|
| Order | Planning (stub) / SAP later | Customer demand enters as sales order + lines |
| Planning | Planning | Schedule jobs onto lines/machines/shifts |
| Approve | Planning | Supervisor validates capacity and priorities |
| Release | Planning | Frozen plan handed to Production |
| Production | Production | Execute jobs, report progress |
| QC | Quality | Inspect; pass/fail/NCR |
| Store | Store | Put-away FG / issue materials |
| Shipping | Store / SAP | Dispatch to customer |

---

## 3. Planning Detail Flow

```mermaid
stateDiagram-v2
  [*] --> Draft
  Draft --> Submitted: submit
  Submitted --> Approved: approve
  Submitted --> Rejected: reject
  Rejected --> Draft: revise
  Approved --> Released: release
  Draft --> Cancelled: cancel
  Submitted --> Cancelled: cancel
  Approved --> Cancelled: cancel
  Released --> [*]
```

### Rules

1. Only `draft` / `rejected` freely editable (policy may allow limited approved edits pre-release).
2. `released` plans/items are **not** silently edited — use `txn.plan_amendment` ([32_STATUS_STATE_MACHINE.md](../30-database/32_STATUS_STATE_MACHINE.md), ADR-009).
3. Calendar Engine validates working time and capacity on submit and release.
4. Each transition writes history **and** an outbox domain event ([34_DOMAIN_EVENTS.md](../20-architecture/34_DOMAIN_EVENTS.md)); Telegram consumes events via templates.
5. Header vs item status rules: [32_STATUS_STATE_MACHINE.md](../30-database/32_STATUS_STATE_MACHINE.md).
6. Partial order fulfillment uses `sales_order_line.qty_allocated`.

---

## 4. Actors

| Actor | Typical actions |
|-------|-----------------|
| Planner | Create/edit plans, drag-drop, submit |
| Supervisor | Approve/reject/release |
| Admin | Masters, calendars, capacities, plant |
| Viewer | Read boards |
| Operator | Future production confirmations |

---

## 5. Exception Paths

| Situation | Handling |
|-----------|----------|
| Capacity overflow | Warn/block per `config`; reason code required to override if allowed |
| Holiday collision | Block or create/approve `txn.ot_window` |
| Machine shutdown | Auto-exclude via `txn.machine_shutdown` windows |
| Order change after plan | Amend allocation; re-approve if status requires |
| Change after release | `plan_amendment` workflow — not direct PATCH |

---

## Related Documents

- [01_PROJECT_VISION.md](01_PROJECT_VISION.md)
- [07_MODULES.md](../20-architecture/07_MODULES.md)
- [28_SCREEN_FLOW.md](../40-uiux/28_SCREEN_FLOW.md)
- [18_CALENDAR_ENGINE.md](../20-architecture/18_CALENDAR_ENGINE.md)
- [32_STATUS_STATE_MACHINE.md](../30-database/32_STATUS_STATE_MACHINE.md)

<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 52 — Planning Module Delivery

**Product:** Smart-Factory Manufacturing Platform  
**Scope:** Planning Header · Detail · Calendar · Capacity · Drag Drop · Approve · Release

---

## Status

Applied to Supabase `Factory-Operations` (`ilkzavjrjwjebcyitgaj`) + Next.js UI.

| Feature | Delivery |
|---------|----------|
| Planning Header | `txn.production_plan` · `/planning/plans` |
| Planning Detail | `txn.production_plan_item` · `/planning/plans/[id]` |
| Calendar | line × day board · `/planning/plans/[id]/calendar` |
| Capacity | `rpc_plan_capacity_summary` · `/…/capacity` |
| Drag Drop | `rpc_plan_item_move` (versioned) |
| Approve | `rpc_plan_workflow` + `txn.plan_approval` · `/…/approve` |
| Release | `rpc_plan_workflow` + `txn.plan_release` · `/…/release` |

---

## Migrations

```text
supabase/migrations/
  20260723025626_planning_01_sales_order.sql
  20260723025627_planning_02_production_plan.sql
  20260723025628_planning_03_approval_release.sql
  20260723025629_planning_04_history.sql
  20260723025630_planning_05_workflow_functions.sql
  20260723025631_planning_06_views_rls.sql
  20260723025632_planning_07_seed.sql
  20260723025633_planning_08_grants.sql
```

---

## Seed

- Sales order `SO-2026-0001`
- Plan `PP-2026-W30` (draft) with 5 scheduled items across lines

---

## Workflow

```text
draft → submit → approved|rejected → (approved) release → released
```

Editable drag-drop only while status is `draft` or `rejected`.

---

## Related

- [44_TRANSACTION_LIST.md](44_TRANSACTION_LIST.md)
- [28_SCREEN_FLOW.md](../40-uiux/28_SCREEN_FLOW.md)
- [50_SQL_MODULE_DELIVERY.md](50_SQL_MODULE_DELIVERY.md)

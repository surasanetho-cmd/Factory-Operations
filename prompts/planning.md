# Prompt — Planning Module

**Use when:** production plan header/detail, calendar board, capacity, drag-drop, approve, release.

## Context to load first

1. `knowledge/00_Governance/PROJECT_CONSTITUTION.md`
2. `knowledge/60_Module/PLANNING.md`
3. `knowledge/10_Business/BUSINESS_FLOW.md`
4. `knowledge/10_Business/BUSINESS_RULES.md`
5. `knowledge/30_UI_UX/SCREEN_FLOW.md`
6. `knowledge/20_Database/DATA_DICTIONARY.md` (plan tables)
7. `knowledge/99_ADR/ADR-003-Calendar.md`

## Task template

```text
You are working on Factory Operations Planning.

Goals:
- [ ] Planning Header (txn.production_plan)
- [ ] Planning Detail (txn.production_plan_item)
- [ ] Calendar board (line × day)
- [ ] Capacity summary vs master.capacity
- [ ] Drag-drop reschedule with version concurrency
- [ ] Approve workflow (submit / approve / reject)
- [ ] Release to production

Rules:
- Soft delete only; UUID PKs; plant-scoped
- No hardcoded lines/shifts/capacities
- Use Calendar Engine — do not fork holiday/shift logic
- Editable only when status is draft or rejected
- Workflow: draft → submitted → approved|rejected → released
- Write history on status change and item move
- Update knowledge/ + docs sync in the same change set when schema/behavior changes

Deliver:
1. Migrations under supabase/migrations/ (one concern per file if new SQL)
2. RPCs if needed (rpc_plan_*)
3. UI under src/app/(shell)/planning/
4. Brief note in knowledge/60_Module/PLANNING.md if behavior changed
```

## Acceptance checks

- [ ] Plan list + detail render from `txn` schema
- [ ] Drag-drop calls `rpc_plan_item_move` and handles version conflict
- [ ] Capacity uses `rpc_plan_capacity_summary`
- [ ] Approve/Release use `rpc_plan_workflow`
- [ ] RLS / permissions: `plan.production_plan.*`

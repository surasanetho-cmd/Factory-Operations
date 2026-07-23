# Template — New Dashboard

**Standards:** `knowledge/30_UI_UX/DESIGN_SYSTEM.md`, `UI_STANDARD.md`  
**Data:** prefer views / RPCs / future `dashboard.*` layouts — not ad-hoc heavy joins in the client  
**Related prompt:** `prompts/ui.md`

---

## Identity

| Field | Value |
|-------|-------|
| Name | |
| Route | `/dashboard/…` or module home |
| Audience | planner / supervisor / exec |
| Permission | |

---

## Purpose

<!-- One question this dashboard answers -->

## Widgets

| Widget | Type (KPI / chart / table / list) | Query / RPC | Refresh |
|--------|-----------------------------------|-------------|---------|
| | | | |

## Layout

```text
[ Filters: plant, date range, line ]
[ KPI row ]
[ Main chart / board ]
[ Detail table ]
```

## Filters

| Filter | Source | Default |
|--------|--------|---------|
| Plant | session plants | default plant |
| Date range | | |
| Line | `master.production_line` | all |

## Non-goals

- Marketing heroes inside app shell  
- Duplicate Calendar Engine logic in the chart layer  
- Embedding secrets or service role in the browser  

## Performance

- [ ] Aggregate in SQL / RPC
- [ ] Limit rows; paginate tables
- [ ] Avoid N+1 client fetches

## Files

```text
src/app/(shell)/dashboard/…/page.tsx
src/components/charts/…   (if Chart.js)
knowledge/30_UI_UX/SCREEN_FLOW.md
```

## Future layout persistence

| Table (reserved) | Use |
|------------------|-----|
| `dashboard.layout` | Saved layouts per user/role/plant |
| `dashboard.widget` | Widget instances |

## Checklist

- [ ] Plant-scoped
- [ ] Empty and error states
- [ ] Responsive per RESPONSIVE_GUIDE
- [ ] Menu entry + permission
- [ ] Numbers formatted consistently (locale-aware later)

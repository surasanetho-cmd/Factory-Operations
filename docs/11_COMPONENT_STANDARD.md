# 11 — Component Standard

**Product:** Smart-Factory Manufacturing Platform  
**Library:** shadcn/ui + shared product components

---

## 1. Laws

1. **No duplicate components** for the same UX purpose.
2. Prefer composing shadcn primitives over new base widgets.
3. Product-level components live in a shared folder; module-specific compositions stay in the module folder but reuse shared primitives.
4. Every interactive component must support light/dark and compact density where applicable.
5. Accessibility is part of the definition of done.

---

## 2. Component Layers

| Layer | Location (target) | Examples |
|-------|-------------------|----------|
| Primitives | `components/ui` | Button, Dialog, Dropdown, Input, Table |
| Product | `components/shared` | AppSidebar, TopNav, ThemeToggle, DataTable, ConfirmDialog, StatusBadge |
| Domain | `modules/{module}/components` | PlanTimeline, ResourceRow, CapacityMeter |
| Charts | `components/charts` | CapacityBarChart (Chart.js wrapper) |

Do not copy `Button` or `Dialog` into modules.

---

## 3. Creation Rules

Before adding a component:

1. Search existing shared and UI folders.
2. If 80% match exists, extend via props/composition.
3. If new, name by purpose (`PlanItemBlock`), not page (`Page2Card`).
4. Export from a barrel only when it clarifies public API.

---

## 4. Props & State

- Controlled vs uncontrolled: follow React norms; prefer controlled for form fields in wizards.
- Forward refs on interactive primitives.
- Do not fetch data inside pure presentational components; containers/hooks own data.
- Loading / empty / error variants are first-class props or slots.

---

## 5. Planning-Specific Shared Pieces

| Component | Responsibility |
|-----------|----------------|
| `PlanTimeline` | Time axis + drag/drop context |
| `ResourceLane` | One machine/line row |
| `PlanItemBlock` | Draggable job block |
| `CalendarDayTypeLegend` | Working/holiday/OT/shutdown |
| `CapacitySummary` | Available vs loaded |

These are unique — do not reinvent per view.

---

## 6. Forms

- Shared form field wrappers (label, error, hint)
- Validation messages from schema (e.g. Zod) — not hardcoded per screen copy when templates apply
- Date/time pickers timezone-aware via user/calendar settings

---

## 7. Anti-Patterns

- Multiple modal implementations
- One-off tables instead of shared `DataTable`
- Embedding business API calls inside primitive UI
- Styling with inline hex bypassing tokens

---

## Related Documents

- [09_UI_STANDARD.md](09_UI_STANDARD.md)
- [10_DESIGN_SYSTEM.md](10_DESIGN_SYSTEM.md)
- [12_CODING_STANDARD.md](12_CODING_STANDARD.md)
- [13_FOLDER_STRUCTURE.md](13_FOLDER_STRUCTURE.md)

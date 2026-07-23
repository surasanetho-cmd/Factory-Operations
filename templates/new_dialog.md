# Template — New Dialog / Modal / Sheet

**Standards:** `knowledge/30_UI_UX/COMPONENT_LIBRARY.md`, `UI_STANDARD.md`  
**Related:** `templates/new_screen.md`, `prompts/ui.md`

---

## Identity

| Field | Value |
|-------|-------|
| Name | `<!-- e.g. EditPlanItemDialog -->` |
| Type | Modal / Sheet / Confirm |
| Parent screen | route `/…` |
| Permission | |

---

## Purpose

<!-- Single job: create / edit / confirm / warn -->

## Open / close triggers

| Open | Close |
|------|-------|
| Button / row action | Cancel, Escape, success |

## Fields

| Field | Control | Required | Validation |
|-------|---------|----------|------------|
| | | | |

## Submit

| Step | Detail |
|------|--------|
| API | Server Action / RPC |
| Optimistic UI | Yes / No |
| On success | close + `router.refresh()` |
| On error | inline message |

## Confirm pattern (destructive / workflow)

```text
Title: …
Body: …
Primary: … (dangerous?)
Secondary: Cancel
```

## Accessibility

- [ ] Focus trap
- [ ] Esc closes (unless blocking)
- [ ] Labelled fields
- [ ] Announce errors

## Files

```text
src/components/…/SomethingDialog.tsx
```

## Checklist

- [ ] Does not hardcode lookup options — load from masters
- [ ] Disabled while pending
- [ ] Respects read-only plan/entity status
- [ ] No nested scroll traps on mobile

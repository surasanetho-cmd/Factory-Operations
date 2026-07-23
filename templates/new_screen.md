# Template — New Screen

**Standards:** `knowledge/30_UI_UX/SCREEN_FLOW.md`, `UI_STANDARD.md`, `RESPONSIVE_GUIDE.md`  
**Related prompt:** `prompts/ui.md` · template dialogs: `new_dialog.md`

---

## Identity

| Field | Value |
|-------|-------|
| Name | |
| Route | `/…` |
| Shell | `(shell)` / `(auth)` / public |
| Module | |
| Permission to open | `<!-- code or authenticated -->` |

---

## Purpose

<!-- One sentence — one job per screen -->

## Layout

```text
[ AppShell ]
  [ Page header: title + primary actions ]
  [ Filters / context bar (optional) ]
  [ Main content: table | board | form ]
```

## Data sources

| Data | Source | Schema |
|------|--------|--------|
| | supabase.from / rpc | `master` / `txn` |

## Actions

| Action | Permission | API / RPC |
|--------|------------|-----------|
| | | |

## States

- [ ] Loading
- [ ] Empty
- [ ] Error
- [ ] Ready
- [ ] Read-only (status / permission)

## Responsive

| Viewport | Behavior |
|----------|----------|
| Mobile | |
| Tablet | |
| Desktop | |

## Menu registration

| Menu code | Label | Path | `permission_code` |
|-----------|-------|------|-------------------|
| | | | |

## Files to add/change

```text
src/app/(shell)/…/page.tsx
src/components/…/
knowledge/30_UI_UX/SCREEN_FLOW.md  (add row)
```

## Checklist

- [ ] No hardcoded masters (lines/shifts/statuses)
- [ ] Unauthorized actions hidden/disabled
- [ ] Uses existing shell — no duplicate chrome
- [ ] SCREEN_FLOW updated
- [ ] Works with `schema('master'|'txn')` queries

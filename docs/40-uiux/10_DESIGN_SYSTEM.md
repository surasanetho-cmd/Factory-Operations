# 10 — Design System

**Product:** Smart-Factory Manufacturing Platform  
**Foundation:** Material Design 3 tokens expressed via CSS variables + Tailwind + shadcn/ui  
**Shell metaphor:** Google Workspace (Drive / Calendar)

---

## 1. Design Direction

- Clean, dense, operational UI for planners and supervisors
- Neutral surfaces with a single sharp brand accent (configurable; default blue-family MD3 primary — **not** purple-gradient clichés)
- Light and dark color schemes from the same token set
- Motion is purposeful (panel expand, drag ghost, toast) — not decorative noise

---

## 2. Token Layers

| Layer | Examples |
|-------|----------|
| Color | `--md-sys-color-primary`, `--md-sys-color-surface`, `--md-sys-color-outline`, status colors |
| Typography | `--font-sans`, `--font-mono`, scale roles: display, title, body, label |
| Elevation | Surface levels 0–3 (subtle; avoid heavy multi-shadow stacks) |
| Shape | Corner radii: none / sm / md (calendars prefer tighter radii) |
| Motion | Duration short/medium; easing standard |
| Density | Comfortable vs compact spacing scale |

Tokens map into Tailwind theme extensions. Components consume tokens — never raw one-off hex in feature code.

---

## 3. Typography

- Prefer a high-quality geometric sans suitable for enterprise UI (configured in app theme; avoid Inter/Roboto/Arial as the identity choice when selecting final fonts).
- Monospace for codes (plan no, part no, machine code).
- User font scale multiplies the base rem scale.

---

## 4. Color Semantics

| Role | Use |
|------|-----|
| Primary | Key actions, active nav |
| Secondary | Secondary actions |
| Tertiary | Optional accents |
| Error / Warning / Success / Info | Status only |
| Surface / On-surface | Backgrounds and text |
| Inverse | Snackbars / high-contrast chips |

Capacity conflict and OT should use semantic warning/error tokens, not ad-hoc colors.

---

## 5. Calendar / Timeline Visual Language

- Working hours: stronger grid
- Non-working / holiday: muted surface hatch or tint
- OT windows: distinct warning-tint band
- Shutdown / maintenance: blocked pattern
- Plan items: solid blocks with part code + qty; selection ring uses primary

Align with [18_CALENDAR_ENGINE.md](../20-architecture/18_CALENDAR_ENGINE.md) day types.

---

## 6. Charts (Chart.js)

- Use design-system colors via token → chart color bridge
- Prefer simple bar/line for capacity and OEE
- Legends readable in dark and light themes

---

## 7. Iconography

- Consistent icon set (e.g. Lucide via shadcn)
- One icon meaning per action across modules

---

## 8. Motion Guidelines

Ship intentional motions:

1. Sidebar collapse / expand
2. Drag ghost + drop settle on planning board
3. Theme cross-fade or preference apply

Avoid continuous ambient animations on operational screens.

---

## Related Documents

- [09_UI_STANDARD.md](09_UI_STANDARD.md)
- [11_COMPONENT_STANDARD.md](11_COMPONENT_STANDARD.md)

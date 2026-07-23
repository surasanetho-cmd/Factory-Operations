# Prompt — UI / UX

**Use when:** screens, shell, forms, boards, components, responsive behavior.

## Context to load first

1. `knowledge/30_UI_UX/DESIGN_SYSTEM.md`
2. `knowledge/30_UI_UX/UI_STANDARD.md`
3. `knowledge/30_UI_UX/SCREEN_FLOW.md`
4. `knowledge/30_UI_UX/COMPONENT_LIBRARY.md`
5. `knowledge/30_UI_UX/RESPONSIVE_GUIDE.md`
6. `knowledge/40_Backend/PERMISSION.md` (hide unauthorized actions)

## Task template

```text
Build / update UI for Factory Operations.

Stack: Next.js App Router, React, TypeScript, Tailwind, existing shell patterns.

Rules:
- Google Workspace–like operational shell — no marketing hero layouts inside the app
- Reuse AppShell + shared DataTable / existing components — no duplicate chrome
- Masters and menus come from DB — never hardcode line/shift lists
- Hide/disable controls the user lacks permission for; server still enforces
- Planning calendar: desktop board + horizontal scroll on smaller viewports
- Match existing dark enterprise visual language in src/app/globals.css unless redesign requested
- Keep first viewport of any branded public page brand-first (marketing pages only)

Deliver:
- Routes under src/app/(shell)/...
- Client islands only where interaction needs them (drag-drop, forms)
- Empty / loading / error states
```

## Acceptance checks

- [ ] Screen exists in SCREEN_FLOW or SCREEN_FLOW updated
- [ ] Works on mobile and desktop per RESPONSIVE_GUIDE
- [ ] No service role or secrets in client bundles
- [ ] Sidebar still driven by session menus when applicable

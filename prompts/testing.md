# Prompt — Testing

**Use when:** test plans, manual QA, smoke checks, regression after migrations/UI.

## Context to load first

1. `knowledge/10_Business/REQUIREMENTS.md`
2. Relevant `knowledge/60_Module/*.md`
3. Legacy testing notes: `docs/50-development/22_TESTING_STANDARD.md` (archive)
4. Feature prompts: `prompts/planning.md`, `prompts/ui.md`, `prompts/api.md`

## Task template

```text
Produce / execute a test plan for Factory Operations.

Layers:
1. SQL smoke — schemas, seed counts, RPC happy path + denied path
2. Auth — login, session context, menu visibility by role
3. Planning — list, detail, calendar drag-drop, capacity, submit/approve/reject/release
4. RLS — user without permission cannot mutate
5. Regression — Auth settings pages still load

Use seed masters (lines 110T–3200T, shifts, calendar, demo plan) — not production data.

Output:
- Preconditions (user, role, plant)
- Steps
- Expected results
- Bugs found (severity, repro)
```

## Minimum Planning smoke

1. Login as admin.  
2. Open `/planning/plans` → open `PP-2026-W30`.  
3. Calendar: drag one job to another line/day → refreshes without version error.  
4. Capacity page shows rows.  
5. Approve: Submit → Approve.  
6. Release: Release → status `released`; drag-drop disabled.

## Acceptance checks

- [ ] Happy path documented
- [ ] At least one negative permission / version-conflict case
- [ ] No reliance on hardcoded IDs outside seed codes

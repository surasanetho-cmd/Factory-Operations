# 22 — Testing Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Goals

- Protect Calendar Engine and planning invariants
- Prevent permission regressions
- Keep soft-delete and versioning correct
- Enable confident refactors without duplicating logic

---

## 2. Test Pyramid

| Layer | Scope | Tools (target) |
|-------|-------|----------------|
| Unit | Pure functions (calendar math, validators) | Vitest / Jest |
| Integration | API + DB (RLS, plan update) | Vitest + Supabase local |
| Component | Shared UI behavior | React Testing Library |
| E2E | Critical planner journeys | Playwright |

---

## 3. Must-Cover Scenarios (Planning)

1. Create plan item on working day succeeds.
2. Place item on holiday fails or warns per policy.
3. Drag-drop updates timestamps and writes history.
4. Version conflict returns 409.
5. Soft delete hides item from default lists.
6. Approve/release permission enforced.
7. Capacity overflow flagged.

---

## 4. Data Rules for Tests

- Use seed masters (lines 110T–3200T, shifts, calendar) — not production data.
- Prefer factories over brittle fixtures.
- Clean up with soft-delete or transaction rollback strategies.

---

## 5. Definition of Done

Feature PRs include:

- Tests for new business rules
- Updated docs when behavior changes
- No skipped tests without ticket/ADR reference

---

## 6. Performance Smoke

- Board with ~30 jobs × 6 lines remains interactive (budget defined when UI exists).

---

## Related Documents

- [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md)
- [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md)
- [12_CODING_STANDARD.md](12_CODING_STANDARD.md)

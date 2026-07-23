# Template — New Module

**Copy to:** `knowledge/60_Module/<MODULE>.md`  
**Also update:** `knowledge/README.md`, `knowledge/00_Governance/ROADMAP.md`, `knowledge/20_Database/MIGRATION_PLAN.md`  
**Related prompts:** `prompts/database.md`, `prompts/planning.md`, `prompts/ui.md`

---

## Module card

| Field | Value |
|-------|-------|
| Code | `<!-- e.g. PLAN / PROD / STORE / OEE / QA / MAINT -->` |
| Name | `<!-- Human name -->` |
| Status | `Reserved` / `In progress` / `Delivered` |
| Phase | `<!-- Roadmap phase -->` |
| Owner schema(s) | `master` / `txn` / `history` / … |
| Depends on | `<!-- modules / masters -->` |

---

## 1. Purpose

<!-- One paragraph: what business problem this module solves -->

## 2. In scope

- 

## 3. Out of scope

- 

## 4. Masters used

| Table | Read / Write | Notes |
|-------|--------------|-------|
| | | |

## 5. Transactions

| Table | Pattern (A/E/H) | Purpose |
|-------|-----------------|---------|
| | | |

## 6. Status codes (`entity_type`)

| entity_type | codes |
|-------------|-------|
| | |

## 7. Permissions

| Code | Who (roles) |
|------|-------------|
| `<module>.<resource>.read` | |
| `<module>.<resource>.create` | |
| `<module>.<resource>.update` | |
| `<module>.<resource>.approve` | |

## 8. Screens (routes)

| Screen | Route | Prompt/template |
|--------|-------|-----------------|
| | `/…` | `templates/new_screen.md` |

## 9. Calendar Engine impact

- [ ] None
- [ ] Reads calendar/shift/capacity/OT/shutdown
- [ ] Writes windows (OT/shutdown/maintenance)

## 10. Domain events (outbox) — future

| Event | When |
|-------|------|
| | |

## 11. Migration plan

| Order | Migration name | Objects |
|-------|----------------|---------|
| 1 | `<module>_01_…` | |
| 2 | `<module>_02_…` | |

## 12. Acceptance

- [ ] Dictionary + ER updated before SQL
- [ ] One SQL module at a time
- [ ] Seed idempotent
- [ ] RLS + grants
- [ ] Knowledge doc merged
- [ ] No hardcoded masters in UI

## 13. Related ADRs

- 

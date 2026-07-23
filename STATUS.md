# Manufacturing Platform

**Repo:** Factory-Operations · **Canonical docs:** [`knowledge/`](knowledge/README.md)  
**Updated:** 2026-07-23

---

## Current Phase

| Phase | Status |
|-------|--------|
| Foundation (constitution, knowledge, prompts, templates) | ✅ Done |
| Database Design (dictionary, ER, masters, migrations) | ✅ Done |
| Login / Auth / Menu / RBAC | ✅ Done |
| Planning Module (header, detail, calendar, capacity, drag-drop, approve, release) | ✅ Done |
| Dashboard (home session shell) | 🟡 Basic |
| Store | ⬜ Reserved |
| OEE | ⬜ Reserved |
| Production / QC / Maintenance | ⬜ Reserved |

---

## Current Sprint

| Focus | Status |
|-------|--------|
| Database Dictionary | ✅ |
| ER Diagram | ✅ |
| Master Tables (+ SQL applied on Supabase) | ✅ |
| Knowledge restructure (`knowledge/`) | ✅ |
| Prompts + Templates packs | ✅ |
| Dashboard widgets / layouts | 🟡 Next polish |

---

## Completed

- PROJECT_CONSTITUTION  
- DESIGN_SYSTEM  
- BUSINESS_FLOW  
- BUSINESS_RULES (incl. Planning)  
- DATA_DICTIONARY / ER / TABLE_RELATIONSHIP / INDEX_STANDARD  
- SQL Modules 1–4: PLATFORM → CALENDAR → PRODUCT → AUTH → PLANNING  
- Login + Role + Permission + Menu  
- Planning UI + RPCs on Supabase `ilkzavjrjwjebcyitgaj`

---

## Next Task

1. **Dashboard** — KPI widgets / saved layouts (see `templates/new_dashboard.md`)  
2. Optional: deepen Calendar Engine domain service (beyond SQL helpers)  
3. Module 5 — Integration / Log / Outbox (when approved)  
4. Keep `STATUS.md` in sync each sprint

---

## Issues

| Issue | Status | Resolution |
|-------|--------|------------|
| Waiting for Business Rule of Planning | ✅ Closed | See [`knowledge/10_Business/BUSINESS_RULES.md`](knowledge/10_Business/BUSINESS_RULES.md) §2 + [`knowledge/60_Module/PLANNING.md`](knowledge/60_Module/PLANNING.md) |
| Need confirmation for Calendar logic | ✅ Confirmed | ADR accepted: [`knowledge/99_ADR/ADR-003-Calendar.md`](knowledge/99_ADR/ADR-003-Calendar.md) · Engine doc: `docs/20-architecture/18_CALENDAR_ENGINE.md` |

Open:

- Dashboard beyond home shell still thin  
- Store / OEE not started (by roadmap)

---

## Quick links

| Need | Path |
|------|------|
| Knowledge index | [`knowledge/README.md`](knowledge/README.md) |
| Migration plan | [`knowledge/20_Database/MIGRATION_PLAN.md`](knowledge/20_Database/MIGRATION_PLAN.md) |
| Prompts | [`prompts/README.md`](prompts/README.md) |
| Templates | [`templates/README.md`](templates/README.md) |
| Review prompt | [`prompts/review.md`](prompts/review.md) |

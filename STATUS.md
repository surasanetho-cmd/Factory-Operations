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
| Next.js scaffold (TS, Tailwind, ESLint, Prettier, shadcn, Supabase Auth) | ✅ Done |
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

1. **Review** [`knowledge/10_Business/PLANNING_BUSINESS_ANALYSIS.md`](knowledge/10_Business/PLANNING_BUSINESS_ANALYSIS.md) (wait for approval)  
2. **Dashboard** — KPI widgets / saved layouts (see `templates/new_dashboard.md`)  
3. Optional: deepen Calendar Engine domain service (beyond SQL helpers)  
4. Module 5 — Integration / Log / Outbox (when approved)  

---

## Issues

| Issue | Status | Resolution |
|-------|--------|------------|
| Waiting for Business Rule of Planning | 🟡 In review | Full BA draft: [`PLANNING_BUSINESS_ANALYSIS.md`](knowledge/10_Business/PLANNING_BUSINESS_ANALYSIS.md) — confirm §17 open points |
| Need confirmation for Calendar logic | ✅ Confirmed | [`ADR-003-Calendar.md`](knowledge/99_ADR/ADR-003-Calendar.md); detailed in BA §13–16 |

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

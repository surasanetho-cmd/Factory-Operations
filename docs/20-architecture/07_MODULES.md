# 07 — Modules

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Module Catalog

| Code | Module | Phase | Status |
|------|--------|-------|--------|
| `PLAN` | Production Planning | 1 | Active design |
| `PROD` | Production | 2 | Future |
| `STORE` | Store / Warehouse | 2–3 | Future |
| `OEE` | OEE | 3 | Future |
| `QA` | Quality | 3 | Future |
| `MAINT` | Maintenance | 3 | Future |
| `DASH` | Dashboard | 2+ | Future (shell widgets early) |
| `SAP` | SAP Integration | 4 | Future |
| `GDRIVE` | Google Drive | 2 | Future (standard ready) |
| `TG` | Telegram | 2 | Future (standard ready) |
| `AI` | AI Assistant | 4 | Future |

---

## 2. Production Planning (Phase 1)

### Owns

- Daily / weekly / monthly plan boards
- Capacity, machine, and shift planning
- Holiday / OT constrained scheduling
- Drag-and-drop timeline and resource views
- Plan submit / approve / reject / release

### Depends on

- Master: lines, machines, shifts, calendar, holiday, capacity, parts, customers, reason codes
- Calendar Engine
- Permission Engine
- History / Log standards

### Does not own

- Shop-floor execution confirmation (Production)
- Inventory consumption (Store)
- OEE calculation (OEE)

---

## 3. Future Module Summaries

### Production

Consumes released plan items; records start/stop, scrap, operators; feeds OEE and Store.

### Store / Warehouse

Material issue/receipt, finished goods, locations; integrates with planning material readiness later.

### OEE

Availability, performance, quality from production and downtime events; calendar-aware.

### Quality

Inspection plans, results, NCR; gates shipping.

### Maintenance

PM/CM work orders; writes machine shutdown windows into Calendar Engine inputs.

### Dashboard

Cross-module KPIs; saved layouts; Chart.js visualizations.

### SAP Integration

Orders, materials, shipping sync via `integration` schema.

### Google Drive

Attachments for parts, plans, QC docs — see [19_GOOGLE_DRIVE_STANDARD.md](19_GOOGLE_DRIVE_STANDARD.md).

### Telegram

Alerts and optional approve actions — see [20_TELEGRAM_STANDARD.md](20_TELEGRAM_STANDARD.md).

### AI Assistant

Natural-language help over plans and KPIs via OpenAI; never bypasses permissions.

---

## 4. Cross-Module Rules

1. No duplicate masters across modules.
2. Status transitions are documented in [27_BUSINESS_FLOW.md](../10-business/27_BUSINESS_FLOW.md).
3. Time and capacity always resolve through Calendar Engine.
4. Each module registers permissions under its module code.

---

## Related Documents

- [01_PROJECT_VISION.md](../10-business/01_PROJECT_VISION.md)
- [02_SYSTEM_ARCHITECTURE.md](02_SYSTEM_ARCHITECTURE.md)
- [24_ROADMAP.md](../10-business/24_ROADMAP.md)
- [28_SCREEN_FLOW.md](../40-uiux/28_SCREEN_FLOW.md)

# Knowledge Base

**Product:** Smart-Factory / Factory Operations Manufacturing Platform  
**Canonical documentation root:** `knowledge/`

```text
manufacturing-platform/
├── .cursor/
├── .docs/                 ← pointers / agent notes
├── knowledge/             ← SOURCE OF TRUTH (this tree)
│   ├── 00_Governance/
│   ├── 10_Business/
│   ├── 20_Database/
│   ├── 30_UI_UX/
│   ├── 40_Backend/
│   ├── 50_Integration/
│   ├── 60_Module/
│   └── 99_ADR/
├── docs/                  ← legacy archive (pre-restructure)
├── src/
└── supabase/
```

---

## 00 — Governance

| Document | Description |
|----------|-------------|
| [PROJECT_CONSTITUTION.md](00_Governance/PROJECT_CONSTITUTION.md) | Binding platform laws |
| [PROJECT_VISION.md](00_Governance/PROJECT_VISION.md) | Vision & goals |
| [ROADMAP.md](00_Governance/ROADMAP.md) | Phased roadmap |
| [CHANGELOG.md](00_Governance/CHANGELOG.md) | Change log |
| [STATUS.md](00_Governance/STATUS.md) | Pointer to repo status board |

## 10 — Business

| Document | Description |
|----------|-------------|
| [BUSINESS_ANALYSIS.md](10_Business/BUSINESS_ANALYSIS.md) | Problem / stakeholders / scope |
| [PLANNING_BUSINESS_ANALYSIS.md](10_Business/PLANNING_BUSINESS_ANALYSIS.md) | **Production Planning BA (review draft)** |
| [BUSINESS_FLOW.md](10_Business/BUSINESS_FLOW.md) | Order → planning → ship flow |
| [BUSINESS_RULES.md](10_Business/BUSINESS_RULES.md) | Enforceable business rules |
| [TERMINOLOGY.md](10_Business/TERMINOLOGY.md) | Glossary |
| [REQUIREMENTS.md](10_Business/REQUIREMENTS.md) | Functional / NFR catalog |

## 20 — Database

| Document | Description |
|----------|-------------|
| [DATABASE_STANDARD.md](20_Database/DATABASE_STANDARD.md) | Naming, Audit*, soft delete |
| [DATA_DICTIONARY.md](20_Database/DATA_DICTIONARY.md) | Columns |
| [ER_DIAGRAM.md](20_Database/ER_DIAGRAM.md) | ER diagrams |
| [TABLE_RELATIONSHIP.md](20_Database/TABLE_RELATIONSHIP.md) | Relationship matrix |
| [INDEX_STANDARD.md](20_Database/INDEX_STANDARD.md) | Index strategy |
| [MIGRATION_PLAN.md](20_Database/MIGRATION_PLAN.md) | SQL module delivery order |

## 30 — UI / UX

| Document | Description |
|----------|-------------|
| [DESIGN_SYSTEM.md](30_UI_UX/DESIGN_SYSTEM.md) | Tokens / visual language |
| [UI_STANDARD.md](30_UI_UX/UI_STANDARD.md) | Shell & UI rules |
| [SCREEN_FLOW.md](30_UI_UX/SCREEN_FLOW.md) | Screens & journeys |
| [COMPONENT_LIBRARY.md](30_UI_UX/COMPONENT_LIBRARY.md) | Component standard |
| [RESPONSIVE_GUIDE.md](30_UI_UX/RESPONSIVE_GUIDE.md) | Breakpoints & boards |

## 40 — Backend

| Document | Description |
|----------|-------------|
| [API_STANDARD.md](40_Backend/API_STANDARD.md) | API / Server Actions |
| [FOLDER_STRUCTURE.md](40_Backend/FOLDER_STRUCTURE.md) | App folder layout |
| [SECURITY.md](40_Backend/SECURITY.md) | Security standard |
| [PERMISSION.md](40_Backend/PERMISSION.md) | RBAC |
| [LOGGING.md](40_Backend/LOGGING.md) | Logging |

## 50 — Integration

| Document | Description |
|----------|-------------|
| [SUPABASE.md](50_Integration/SUPABASE.md) | Postgres + Auth |
| [GOOGLE_DRIVE.md](50_Integration/GOOGLE_DRIVE.md) | Drive attachments |
| [TELEGRAM.md](50_Integration/TELEGRAM.md) | Telegram alerts |
| [SAP.md](50_Integration/SAP.md) | Future SAP sync |
| [MCP.md](50_Integration/MCP.md) | MCP config |

## 60 — Modules

| Document | Description |
|----------|-------------|
| [PLANNING.md](60_Module/PLANNING.md) | Planning (delivered) |
| [PRODUCTION.md](60_Module/PRODUCTION.md) | Production (reserved) |
| [STORE.md](60_Module/STORE.md) | Store (reserved) |
| [OEE.md](60_Module/OEE.md) | OEE (reserved) |
| [QC.md](60_Module/QC.md) | Quality (reserved) |
| [MAINTENANCE.md](60_Module/MAINTENANCE.md) | Maintenance (reserved) |

## 99 — ADR

| Document | Description |
|----------|-------------|
| [ADR-001-Supabase.md](99_ADR/ADR-001-Supabase.md) | Supabase SoR |
| [ADR-002-GoogleDrive.md](99_ADR/ADR-002-GoogleDrive.md) | Drive for docs |
| [ADR-003-Calendar.md](99_ADR/ADR-003-Calendar.md) | Shared Calendar Engine |
| [ADR-004-SoftDelete.md](99_ADR/ADR-004-SoftDelete.md) | Soft delete + Audit* |

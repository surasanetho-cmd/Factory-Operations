# Smart-Factory Documentation

Source of truth for the Manufacturing Platform.  
**No application code is generated until instructed.**

## Structure

```text
docs/
├── 00-governance/      ← Constitution, Standards, Decisions
├── 10-business/        ← Business Flow, Requirements
├── 20-architecture/    ← System, Modules, Integrations
├── 30-database/        ← ERD, Data Dictionary, Standards
├── 40-uiux/            ← Design System, Screen Flow
├── 50-development/     ← Coding, API, Folder Structure
├── 60-deployment/      ← MCP, Vercel, GitHub, Environment
└── 99-changelog/       ← Change Log, ADR (Architecture Decision Records)
```

---

## 00 — Governance

| Document | Description |
|----------|-------------|
| [00_PROJECT_CONSTITUTION.md](00-governance/00_PROJECT_CONSTITUTION.md) | Binding platform laws |
| [14_SECURITY_STANDARD.md](00-governance/14_SECURITY_STANDARD.md) | Security |
| [15_PERMISSION_STANDARD.md](00-governance/15_PERMISSION_STANDARD.md) | RBAC / permissions |
| [16_HISTORY_STANDARD.md](00-governance/16_HISTORY_STANDARD.md) | History / audit trail |
| [17_LOG_STANDARD.md](00-governance/17_LOG_STANDARD.md) | Application logging |
| [23_CURSOR_RULES.md](00-governance/23_CURSOR_RULES.md) | Agent / Cursor rules |

## 10 — Business

| Document | Description |
|----------|-------------|
| [01_PROJECT_VISION.md](10-business/01_PROJECT_VISION.md) | Vision & goals |
| [24_ROADMAP.md](10-business/24_ROADMAP.md) | Phased roadmap |
| [26_MASTER_DATA.md](10-business/26_MASTER_DATA.md) | Master data catalog |
| [27_BUSINESS_FLOW.md](10-business/27_BUSINESS_FLOW.md) | Order → Shipping flow |

## 20 — Architecture

| Document | Description |
|----------|-------------|
| [02_SYSTEM_ARCHITECTURE.md](20-architecture/02_SYSTEM_ARCHITECTURE.md) | System architecture |
| [03_TECH_STACK.md](20-architecture/03_TECH_STACK.md) | Tech stack |
| [07_MODULES.md](20-architecture/07_MODULES.md) | Module catalog |
| [18_CALENDAR_ENGINE.md](20-architecture/18_CALENDAR_ENGINE.md) | Shared calendar engine |
| [19_GOOGLE_DRIVE_STANDARD.md](20-architecture/19_GOOGLE_DRIVE_STANDARD.md) | Google Drive |
| [20_TELEGRAM_STANDARD.md](20-architecture/20_TELEGRAM_STANDARD.md) | Telegram |
| [34_DOMAIN_EVENTS.md](20-architecture/34_DOMAIN_EVENTS.md) | Domain events / outbox |

## 30 — Database

| Document | Description |
|----------|-------------|
| [04_DATABASE_STANDARD.md](30-database/04_DATABASE_STANDARD.md) | DB standard & naming |
| [05_DATABASE_DICTIONARY.md](30-database/05_DATABASE_DICTIONARY.md) | Complete data dictionary |
| [06_ER_DIAGRAM.md](30-database/06_ER_DIAGRAM.md) | ER diagrams |
| [31_NUMBERING_STANDARD.md](30-database/31_NUMBERING_STANDARD.md) | Document numbering |
| [32_STATUS_STATE_MACHINE.md](30-database/32_STATUS_STATE_MACHINE.md) | Status machines |
| [33_PLANT_ORG_STANDARD.md](30-database/33_PLANT_ORG_STANDARD.md) | Plant & organization |
| [35_UOM_STANDARD.md](30-database/35_UOM_STANDARD.md) | Units of measure |
| [37_TABLE_RELATIONSHIPS.md](30-database/37_TABLE_RELATIONSHIPS.md) | Relationships |
| [38_FOREIGN_KEYS.md](30-database/38_FOREIGN_KEYS.md) | Foreign keys & CHECKs |
| [39_INDEX_STRATEGY.md](30-database/39_INDEX_STRATEGY.md) | Index strategy |

## 40 — UI / UX

| Document | Description |
|----------|-------------|
| [09_UI_STANDARD.md](40-uiux/09_UI_STANDARD.md) | UI standard |
| [10_DESIGN_SYSTEM.md](40-uiux/10_DESIGN_SYSTEM.md) | Design system |
| [11_COMPONENT_STANDARD.md](40-uiux/11_COMPONENT_STANDARD.md) | Components |
| [28_SCREEN_FLOW.md](40-uiux/28_SCREEN_FLOW.md) | Screen flow |

## 50 — Development

| Document | Description |
|----------|-------------|
| [08_API_STANDARD.md](50-development/08_API_STANDARD.md) | API standard |
| [12_CODING_STANDARD.md](50-development/12_CODING_STANDARD.md) | Coding standard |
| [13_FOLDER_STRUCTURE.md](50-development/13_FOLDER_STRUCTURE.md) | Target app folders |
| [22_TESTING_STANDARD.md](50-development/22_TESTING_STANDARD.md) | Testing |

## 60 — Deployment

| Document | Description |
|----------|-------------|
| [21_DEPLOYMENT_STANDARD.md](60-deployment/21_DEPLOYMENT_STANDARD.md) | Vercel / Supabase / GitHub |
| [25_MCP_CONFIG.md](60-deployment/25_MCP_CONFIG.md) | MCP configuration |

## 99 — Changelog & ADR

| Document | Description |
|----------|-------------|
| [29_DECISION_LOG.md](99-changelog/29_DECISION_LOG.md) | Architecture Decision Records |
| [30_CHANGELOG.md](99-changelog/30_CHANGELOG.md) | Changelog |
| [36_DOCUMENTATION_REVIEW.md](99-changelog/36_DOCUMENTATION_REVIEW.md) | Documentation review |

---

## Reading order (new contributors / agents)

1. [00_PROJECT_CONSTITUTION.md](00-governance/00_PROJECT_CONSTITUTION.md)  
2. [01_PROJECT_VISION.md](10-business/01_PROJECT_VISION.md)  
3. [02_SYSTEM_ARCHITECTURE.md](20-architecture/02_SYSTEM_ARCHITECTURE.md)  
4. [04](30-database/04_DATABASE_STANDARD.md)–[06](30-database/06_ER_DIAGRAM.md) database pack  
5. [23_CURSOR_RULES.md](00-governance/23_CURSOR_RULES.md) before writing code  

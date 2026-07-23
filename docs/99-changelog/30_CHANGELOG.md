# 30 — Changelog

**Product:** Smart-Factory Manufacturing Platform  
**Scope:** Documentation and (later) product releases

Format inspired by Keep a Changelog; SemVer when software releases begin.

---

## [Unreleased]

- (none)

---

## [0.4.0] — 2026-07-23

### Added

- Supabase project init (`supabase/config.toml`)
- **Module 1 PLATFORM** SQL migrations (`platform_01`–`platform_09`):
  schemas, audit helpers, org/RBAC, lookups, config, authz+RLS, views, seed, grants
- [50_SQL_MODULE_DELIVERY.md](../30-database/50_SQL_MODULE_DELIVERY.md)

### Notes

- Next module (Calendar & Resources) waits for Module 1 review
- Local apply requires Docker: `npx supabase db reset`

---

## [0.3.0] — 2026-07-22

### Added

- Complete database architecture pack (design only — **no SQL**):
  - [40_DATABASE_ARCHITECTURE.md](../30-database/40_DATABASE_ARCHITECTURE.md)
  - [41_MODULE_RELATIONSHIPS.md](../30-database/41_MODULE_RELATIONSHIPS.md)
  - [42_ENTITY_RELATIONSHIPS.md](../30-database/42_ENTITY_RELATIONSHIPS.md)
  - [43_MASTER_DATA_LIST.md](../30-database/43_MASTER_DATA_LIST.md) through [49_DASHBOARD_LIST.md](../30-database/49_DASHBOARD_LIST.md)
- Per-table: Purpose, Relationships, PK, FKs, Indexes, Scalability, Soft Delete, Audit
- Review gate before generating migrations

---

## [0.2.1] — 2026-07-22

### Changed

- Reorganized `/docs` into category folders:
  - `00-governance/`, `10-business/`, `20-architecture/`, `30-database/`,
    `40-uiux/`, `50-development/`, `60-deployment/`, `99-changelog/`
- Updated cross-links, root README, and docs catalog index

---

## [0.2.0] — 2026-07-22

### Added

- Complete PostgreSQL database design documentation:
  - Expanded [04_DATABASE_STANDARD.md](../30-database/04_DATABASE_STANDARD.md) naming convention
  - Complete [05_DATABASE_DICTIONARY.md](../30-database/05_DATABASE_DICTIONARY.md) column-level dictionary
  - Complete [06_ER_DIAGRAM.md](../30-database/06_ER_DIAGRAM.md)
  - [37_TABLE_RELATIONSHIPS.md](../30-database/37_TABLE_RELATIONSHIPS.md)
  - [38_FOREIGN_KEYS.md](../30-database/38_FOREIGN_KEYS.md)
  - [39_INDEX_STRATEGY.md](../30-database/39_INDEX_STRATEGY.md)

### Notes

- Design-only; no SQL migrations or application code in this release

---

## [0.1.1] — 2026-07-22

### Changed

- Documentation review remediation across `00`–`30`
- Database standard: schemas required, Audit\* exceptions, indexes, capacity XOR, auth FK rules
- Dictionary + ER: plant, BOM (`part_material`), UoM, status codes, shift assignment, OT/shutdown, outbox, idempotency, file_link, prefs ownership
- Calendar Engine: resolution order, performance/caching, locked input tables
- API: idempotency store, error registry, optional plan lease
- Security: retention / soft-delete ≠ erasure
- Permissions: locked RLS helper function names
- Business flow: amendment + outbox events
- Vision/architecture: deduplicated in favor of single-source docs

### Added

- [31_NUMBERING_STANDARD.md](../30-database/31_NUMBERING_STANDARD.md)
- [32_STATUS_STATE_MACHINE.md](../30-database/32_STATUS_STATE_MACHINE.md)
- [33_PLANT_ORG_STANDARD.md](../30-database/33_PLANT_ORG_STANDARD.md)
- [34_DOMAIN_EVENTS.md](../20-architecture/34_DOMAIN_EVENTS.md)
- [35_UOM_STANDARD.md](../30-database/35_UOM_STANDARD.md)
- [36_DOCUMENTATION_REVIEW.md](36_DOCUMENTATION_REVIEW.md)
- ADRs 008–011 in [29_DECISION_LOG.md](29_DECISION_LOG.md)

---

## [0.1.0] — 2026-07-22

### Added

- Documentation foundation under `/docs` (`00`–`30`)
- Initial ADRs 001–007
- Root README index

### Notes

- No application source code

---

## Versioning Guide

| Bump | When |
|------|------|
| MAJOR | Incompatible architecture/schema constitution changes |
| MINOR | New module docs or backward-compatible standards |
| PATCH | Clarifications, review fixes, non-breaking doc edits |

---

## Related Documents

- [24_ROADMAP.md](../10-business/24_ROADMAP.md)
- [29_DECISION_LOG.md](29_DECISION_LOG.md)
- [36_DOCUMENTATION_REVIEW.md](36_DOCUMENTATION_REVIEW.md)

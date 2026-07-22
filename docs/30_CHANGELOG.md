# 30 — Changelog

**Product:** Smart-Factory Manufacturing Platform  
**Scope:** Documentation and (later) product releases

Format inspired by Keep a Changelog; SemVer when software releases begin.

---

## [Unreleased]

- (none)

---

## [0.2.0] — 2026-07-22

### Added

- Complete PostgreSQL database design documentation:
  - Expanded [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md) naming convention
  - Complete [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md) column-level dictionary
  - Complete [06_ER_DIAGRAM.md](06_ER_DIAGRAM.md)
  - [37_TABLE_RELATIONSHIPS.md](37_TABLE_RELATIONSHIPS.md)
  - [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)
  - [39_INDEX_STRATEGY.md](39_INDEX_STRATEGY.md)

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

- [31_NUMBERING_STANDARD.md](31_NUMBERING_STANDARD.md)
- [32_STATUS_STATE_MACHINE.md](32_STATUS_STATE_MACHINE.md)
- [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md)
- [34_DOMAIN_EVENTS.md](34_DOMAIN_EVENTS.md)
- [35_UOM_STANDARD.md](35_UOM_STANDARD.md)
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

- [24_ROADMAP.md](24_ROADMAP.md)
- [29_DECISION_LOG.md](29_DECISION_LOG.md)
- [36_DOCUMENTATION_REVIEW.md](36_DOCUMENTATION_REVIEW.md)

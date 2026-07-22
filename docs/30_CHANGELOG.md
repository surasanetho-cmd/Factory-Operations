# 30 — Changelog

**Product:** Smart-Factory Manufacturing Platform  
**Scope:** Documentation and (later) product releases

All notable changes to this project are recorded here.  
Format inspired by Keep a Changelog; versions follow SemVer when software releases begin.

---

## [Unreleased]

- (none)

---

## [0.1.0] — 2026-07-22

### Added

- Documentation foundation under `/docs`:
  - `00`–`30` standards covering constitution, vision, architecture, stack, database, modules, API/UI/design/component/coding standards, folder structure, security, permissions, history, logs, calendar engine, Google Drive, Telegram, deployment, testing, Cursor rules, roadmap, MCP config, master data, business flow, screen flow, decision log, and this changelog
- Initial ADRs in [29_DECISION_LOG.md](29_DECISION_LOG.md)
- Root README index pointing to documentation as source of truth

### Notes

- No application source code in this release
- Next instruction expected before scaffolding Next.js / Supabase implementation

---

## Versioning Guide

| Version bump | When |
|--------------|------|
| MAJOR | Incompatible architecture/schema constitution changes |
| MINOR | New module docs or backward-compatible standards |
| PATCH | Clarifications, typo fixes, non-breaking doc edits |

---

## Related Documents

- [24_ROADMAP.md](24_ROADMAP.md)
- [29_DECISION_LOG.md](29_DECISION_LOG.md)

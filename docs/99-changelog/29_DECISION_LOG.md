# 29 — Decision Log

**Product:** Smart-Factory Manufacturing Platform  
**Format:** Architecture Decision Records (ADR-lite)

---

## How to Add an Entry

1. Increment ID (`ADR-XXX`).
2. State context, decision, consequences.
3. Link related docs.
4. Never delete entries — mark superseded.

---

## ADR-001 — Documentation-First Bootstrap

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Greenfield manufacturing platform with many future modules |
| Decision | Create complete `/docs` standards before application code |
| Consequences | Slower first UI; stronger consistency; agents must follow docs |

---

## ADR-002 — Modular Monolith on Next.js + Supabase

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Need multi-module platform without premature microservices |
| Decision | Single Next.js app with module folders; Postgres schemas for domains |
| Consequences | Simpler deploy on Vercel; clear extraction points later |

---

## ADR-003 — Universal Soft Delete + Audit Columns

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Manufacturing auditability and recoverability |
| Decision | Mandatory audit columns; never hard delete business data |
| Consequences | All queries filter `deleted_at`; history complements live tables |

---

## ADR-004 — Shared Calendar Engine

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Planning, Production, Store, OEE, Dashboard all need time semantics |
| Decision | One Calendar Engine API/domain; modules consume it |
| Consequences | No per-module holiday logic; calendar changes become cross-cutting |

---

## ADR-005 — Config-Driven Masters (No Hardcode)

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Six production lines and evolving shifts/capacities |
| Decision | Seed lines/shifts/capacities/templates in DB; UI/admin editable |
| Consequences | Deployments do not require code changes for master value updates |

---

## ADR-006 — UI Language: Workspace Shell + MD3 Tokens

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Planners expect familiar productivity UX |
| Decision | Google Workspace–like shell; Material Design 3 tokens via Tailwind/shadcn |
| Consequences | Shared shell mandatory; marketing-style heroes out of scope in-app |

---

## ADR-007 — RBAC in Database

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Supabase Auth identity only; need fine-grained permissions |
| Decision | Roles/permissions in `master`; enforce in API + RLS |
| Consequences | No authorization from editable user_metadata |

---

## ADR-008 — PostgreSQL Schemas Required (Not Prefixes)

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Docs allowed schema or prefix; ambiguity risks inconsistent DDL |
| Decision | Use real Postgres schemas: `master`, `txn`, `history`, `log`, `config`, `integration`, `dashboard` |
| Consequences | Migrations create schemas first; `public` only for views/wrappers |

---

## ADR-009 — Post-Release Plan Amendment

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Released plans must stay stable for Production, but corrections will be needed |
| Decision | No silent edits after release; use `txn.plan_amendment` + status machine |
| Consequences | Phase 2 Production can rely on released snapshots; amendment is explicit |

---

## ADR-010 — Plant Dimension From Day One

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Single plant today; multi-site / SAP org later |
| Decision | `master.plant` + `plant_id` on plant-scoped masters/txns; seed `SF1` |
| Consequences | Slightly more FKs now; avoids breaking redesign later |

---

## ADR-011 — BOM via part_material; Capacity XOR; Calendar Assignment

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Review found wrong Part→Material ER, polymorphic capacity, missing calendar FKs |
| Decision | `part_material` BOM; capacity XOR check; `calendar_id` on line/machine with plant default resolution; OT/shutdown txn tables named |
| Consequences | Dictionary and ER updated; Calendar Engine inputs locked |

---

## ADR-012 — Complete Database Design Pack

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Need implementable PostgreSQL design before migrations |
| Decision | Treat `04`+`05`+`06`+`37`+`38`+`39` as the complete design pack (naming, dictionary, ER, relationships, FKs, indexes) |
| Consequences | Migrations must follow these docs; no ad-hoc tables |

---

## ADR-013 — Documentation Category Folder Layout

| Field | Value |
|-------|-------|
| Date | 2026-07-22 |
| Status | Accepted |
| Context | Flat `/docs` list became hard to navigate as standards grew |
| Decision | Organize docs under `00-governance`, `10-business`, `20-architecture`, `30-database`, `40-uiux`, `50-development`, `60-deployment`, `99-changelog`; keep `NN_TOPIC.md` filenames stable |
| Consequences | Cross-links use relative paths; catalog at `docs/README.md` |

---

## Related Documents

- [00_PROJECT_CONSTITUTION.md](../00-governance/00_PROJECT_CONSTITUTION.md)
- [30_CHANGELOG.md](30_CHANGELOG.md)
- [36_DOCUMENTATION_REVIEW.md](36_DOCUMENTATION_REVIEW.md)

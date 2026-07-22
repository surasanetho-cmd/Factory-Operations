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

## Related Documents

- [00_PROJECT_CONSTITUTION.md](00_PROJECT_CONSTITUTION.md)
- [30_CHANGELOG.md](30_CHANGELOG.md)

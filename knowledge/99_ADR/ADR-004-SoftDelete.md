<!-- Canonical path: knowledge/ -->

# ADR-004 — Soft delete + Audit*

| Field | Value |
|-------|-------|
| Status | Accepted |
| Date | 2026-07 |

## Context

Manufacturing records need retainable history; accidental hard deletes are unacceptable.

## Decision

**Soft delete** (`deleted_at` / `deleted_by` / usually `is_active=false`) on business tables. Full **Audit\*** columns on mutable masters/txns. Immutable **history** tables for plan changes. FKs `ON DELETE RESTRICT`.

## Consequences

- Default reads filter `deleted_at IS NULL`.  
- Partial unique indexes for active codes.  
- Soft delete is not a security or legal-erasure boundary.

## Related

- [DATABASE_STANDARD.md](../20_Database/DATABASE_STANDARD.md)
- [LOGGING.md](../40_Backend/LOGGING.md)

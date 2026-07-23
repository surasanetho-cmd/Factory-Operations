<!-- Canonical path: knowledge/ -->

# ADR-003 — Shared Calendar Engine

| Field | Value |
|-------|-------|
| Status | Accepted |
| Date | 2026-07 |

## Context

Planning, Production, Store, OEE, and Maintenance all need consistent working-day / shift / OT / shutdown / capacity logic.

## Decision

One **Calendar Engine** reading `calendar`, `holiday`, `shift`, `shift_assignment`, `capacity`, `ot_window`, `machine_shutdown`. Modules must not fork holiday/shift rules.

## Consequences

- Resolution order: machine → line → plant default calendar.  
- Civil dates in calendar TZ; instants as `timestamptz`.  
- SQL helpers + future domain service share the same rules.

## Related

- Legacy: `/docs/20-architecture/18_CALENDAR_ENGINE.md`
- [PLANNING.md](../60_Module/PLANNING.md)

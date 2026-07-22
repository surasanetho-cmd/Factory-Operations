# 16 — History Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Purpose

Immutable audit trail of significant business changes for compliance, disputes, and planning analysis.

---

## 2. Principles

1. History rows are **append-only** — never update or hard-delete history.
2. Soft delete / restore of a business entity writes a history event.
3. `version` on the history row equals the **live entity version after** the mutation.
4. One primary history row per successful mutation (do not duplicate via triggers + app both without coordination).
5. Store enough to reconstruct before/after without needing deleted-only joins.

---

## 3. When to Write History

| Event | Required |
|-------|----------|
| Create / update meaningful fields | Yes |
| Soft delete / restore | Yes |
| Status transitions | Yes |
| Drag-and-drop reschedule | Yes |
| Pure UI preference change | No |
| High-volume telemetry | Prefer `log` / samples |

---

## 4. Column Pattern (entity-specific)

| Column | Notes |
|--------|-------|
| `id` | UUID |
| `{entity}_id` | FK to live row |
| `version` | Live version after change |
| `change_type` | `create` \| `update` \| `soft_delete` \| `restore` \| `status` |
| `before_json` / `after_json` | Snapshots |
| `changed_fields` | List of fields |
| `changed_at` | timestamptz |
| `changed_by` | → `user_profile.id` |

Generic: `history.entity_change` with `entity_type`, `entity_id`.

History tables **omit** full Audit\* (`updated_*`, `deleted_*`, `is_active`) — see [04](../30-database/04_DATABASE_STANDARD.md) exceptions.

---

## 5. Retention

- Business default: retain planning history long-term; archive cold later via config.
- Soft delete of live rows does **not** delete history.
- Legal erasure of PII may redact `changed_by` display fields per [14](14_SECURITY_STANDARD.md) — process TBD (P2).

---

## 6. Access

Requires entity `*.read` plus optional `*.history.read` if separated. History is not an RLS bypass.

---

## Related Documents

- [04_DATABASE_STANDARD.md](../30-database/04_DATABASE_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](../30-database/05_DATABASE_DICTIONARY.md)
- [17_LOG_STANDARD.md](17_LOG_STANDARD.md)
- [34_DOMAIN_EVENTS.md](../20-architecture/34_DOMAIN_EVENTS.md)

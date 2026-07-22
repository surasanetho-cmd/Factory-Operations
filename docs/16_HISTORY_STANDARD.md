# 16 — History Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Purpose

History provides an immutable audit trail of significant business changes for compliance, dispute resolution, and planning rollback analysis.

---

## 2. Principles

1. History rows are **append-only** — never update or hard-delete history.
2. Soft delete of a business entity writes a history event.
3. Optimistic `version` on the live row must match the latest history sequence conceptually.
4. Store enough context to reconstruct before/after without joining deleted-only data.

---

## 3. When to Write History

| Event | Required |
|-------|----------|
| Create entity | Yes (optional snapshot) |
| Update meaningful fields | Yes |
| Soft delete / restore | Yes |
| Status transitions (approve, release) | Yes |
| Drag-and-drop reschedule | Yes |
| Pure UI preference change | No (config only) |
| High-volume telemetry | Prefer `log` or dedicated samples, not history |

---

## 4. Table Patterns

### Entity-specific

Example: `history.production_plan_item_history`

| Column | Notes |
|--------|-------|
| `id` | UUID |
| `production_plan_item_id` | FK to live row |
| `version` | Version after change |
| `change_type` | `create` \| `update` \| `soft_delete` \| `restore` \| `status` |
| `before_json` | Previous state |
| `after_json` | New state |
| `changed_fields` | Array/text list |
| `changed_at` | timestamptz |
| `changed_by` | uuid |

### Generic

`history.entity_change` for cross-cutting entities with `entity_type`, `entity_id`.

---

## 5. Payload Guidelines

- Prefer structured JSON snapshots of business fields (exclude secrets).
- Include foreign key IDs and display codes when helpful.
- Do not store entire unrelated graphs.

---

## 6. Retention

- Planning history: long retention (business default: retain indefinitely unless legal policy says otherwise).
- Define archival jobs later via `config` — do not hardcode retention in app logic.

---

## 7. Access

- Reading history requires `*.read` plus optional `*.history.read` if separated.
- History is not a bypass for RLS on sensitive fields — redact as needed.

---

## Related Documents

- [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)
- [17_LOG_STANDARD.md](17_LOG_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

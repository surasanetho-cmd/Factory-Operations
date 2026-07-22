# 34 — Domain Events & Outbox

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Purpose

Decouple Planning from Telegram, Dashboard projections, SAP, and future modules without circular table writes. **Transactional outbox** is the standard.

---

## 2. Principles

1. Domain services write business tables **and** `integration.outbox` in the **same transaction**.
2. Workers publish outbox rows to consumers (Telegram adapter, projection builder, SAP sync).
3. Consumers are idempotent (use `integration.idempotency_key` or event id).
4. UI never calls external APIs directly (Constitution I1).

---

## 3. Outbox Table

`integration.outbox`:

| Column | Meaning |
|--------|---------|
| `event_type` | Stable name |
| `aggregate_type` / `aggregate_id` | Source entity |
| `payload_json` | Minimal facts (ids, codes, versions) |
| `status_code` | `pending`, `processing`, `done`, `error` |
| `available_at` | Delay / schedule |
| `attempts` | Retry count |

---

## 4. Initial Event Catalog

| Event type | When | Consumers |
|------------|------|-----------|
| `plan.submitted` | Submit | Telegram, audit projection |
| `plan.approved` | Approve | Telegram |
| `plan.rejected` | Reject | Telegram |
| `plan.released` | Release | Production (future), Telegram, capacity projection |
| `plan.item.rescheduled` | Drag-drop save | Capacity projection |
| `calendar.windows_changed` | Holiday/OT/shutdown change | Calendar cache bust |
| `master.capacity_changed` | Capacity master edit | Capacity projection |

Notification copy still comes from `master.notification_template` ([20](20_TELEGRAM_STANDARD.md)).

---

## 5. Sync Jobs vs Outbox

| Mechanism | Use |
|-----------|-----|
| Outbox | Domain events originating inside Smart-Factory |
| `sync_job` / `sync_job_item` | Batch pull/push with external cursors (SAP) |

Do not replace outbox with ad-hoc Telegram sends inside UI actions.

---

## 6. Scalability

- Partition or archive old outbox rows after `done`.
- Projection tables may denormalize board aggregates; they are not systems of record.
- Poison messages: dead-letter status after N attempts; alert via `log.integration_event`.

---

## Related Documents

- [02_SYSTEM_ARCHITECTURE.md](02_SYSTEM_ARCHITECTURE.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [20_TELEGRAM_STANDARD.md](20_TELEGRAM_STANDARD.md)
- [08_API_STANDARD.md](08_API_STANDARD.md)

# 17 — Log Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Purpose

Logs capture operational, security, and integration events for diagnostics and monitoring. Logs complement (not replace) History.

| Concern | Store |
|---------|-------|
| Business state changes | `history` |
| Runtime / ops events | `log` |
| External sync | `log` + `integration` |

---

## 2. Log Tables

### `log.app_event`

Application events: warnings, handled errors, significant batch jobs.

| Column | Notes |
|--------|-------|
| `id` | UUID |
| `level` | `debug` \| `info` \| `warn` \| `error` |
| `module` | Module code |
| `event_code` | Stable code |
| `message` | Human text |
| `context_json` | Structured data |
| `request_id` | Correlation |
| `user_id` | Nullable |
| `created_at` | timestamptz |

### `log.security_event`

Auth failures, permission denials, suspicious patterns.

### `log.integration_event`

Outbound/inbound calls to Drive, Telegram, SAP, OpenAI — status, latency, error.

---

## 3. Levels

| Level | Use |
|-------|-----|
| debug | Dev only; minimize in prod |
| info | Lifecycle milestones |
| warn | Recoverable issues |
| error | Failed operations needing attention |

---

## 4. Rules

1. Never log secrets, tokens, passwords, or full personal documents.
2. Always include `request_id` when available.
3. Prefer stable `event_code` for alerting.
4. Do not use logs as the system of record for plan state.
5. PII: minimize; mask when possible.

---

## 5. Correlation

- Generate `request_id` at API edge; propagate to services and log rows.
- Drag-drop saves: one request_id per persist call.

---

## 6. Retention

Configurable via `config.system_setting` (e.g. 30–90 days for app logs; longer for security). Archival strategy documented when implemented.

---

## Related Documents

- [16_HISTORY_STANDARD.md](16_HISTORY_STANDARD.md)
- [14_SECURITY_STANDARD.md](14_SECURITY_STANDARD.md)
- [20_TELEGRAM_STANDARD.md](../20-architecture/20_TELEGRAM_STANDARD.md)

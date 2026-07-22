# 20 — Telegram Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Purpose

Telegram delivers operational notifications and optional lightweight actions (e.g. approve reminder links) to planners and supervisors.

---

## 2. Principles

1. Message bodies come from `master.notification_template` — **no hardcoded message strings** in feature code.
2. Delivery via Integration adapter; credentials server-side only.
3. Telegram is not a source of truth; button actions call back into secured APIs.
4. Users opt-in chat mapping stored as master/integration data.

---

## 3. Event Catalog (initial)

| Event code | When | Audience |
|------------|------|----------|
| `plan.submitted` | Plan submitted for approval | Supervisors |
| `plan.approved` | Plan approved | Planners |
| `plan.rejected` | Plan rejected | Planners |
| `plan.released` | Plan released | Production leads (future) |
| `plan.conflict` | Capacity conflict unresolved | Planners |
| `system.alert` | Generic ops alert | Admins |

---

## 4. Template Model

`master.notification_template`:

- `code` = event code
- `channel` = `telegram`
- `body` with placeholders: `{{plan_no}}`, `{{line_code}}`, `{{actor_name}}`, …
- `locale`

Renderer substitutes placeholders; missing values fail safe (log + skip or generic fallback template).

---

## 5. Delivery Rules

1. Check feature flag `telegram_notifications`.
2. Prefer consuming **outbox** events ([34_DOMAIN_EVENTS.md](34_DOMAIN_EVENTS.md)) — do not send Telegram directly from UI handlers.
3. Resolve recipients by role/subscription/plant.
4. Send via Bot API; record `log.integration_event`.
5. Retry transient failures with backoff; dead-letter after N attempts.

---

## 6. Security

- Bot token in secrets only.
- Validate webhook signatures if webhooks used.
- Action deep links require auth in the web app; do not trust Telegram user id alone without binding.

---

## Related Documents

- [17_LOG_STANDARD.md](../00-governance/17_LOG_STANDARD.md)
- [15_PERMISSION_STANDARD.md](../00-governance/15_PERMISSION_STANDARD.md)
- [26_MASTER_DATA.md](../10-business/26_MASTER_DATA.md)

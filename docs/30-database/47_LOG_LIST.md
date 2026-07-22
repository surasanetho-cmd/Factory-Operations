# 47 — Log List

**Schema:** `log`  
**Part of:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Standard:** [17_LOG_STANDARD.md](../00-governance/17_LOG_STANDARD.md)  
**Pattern:** **L** append-only.  
**No SQL yet.**

---

## Inventory

| Table | Purpose summary |
|-------|-----------------|
| `app_event` | Application operational events |
| `security_event` | Authz / security incidents |
| `integration_event` | External call results |

---

### `log.app_event`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Structured app logs (info/warn/error) with module + event_code + request_id. |
| **Relationships** | Optional user_id → user_profile; optional plant_id (no hard FK required). |
| **PK** | `id` UUID |
| **FKs** | `user_id` → user_profile (N) |
| **Indexes** | `(created_at DESC)`; `(module, event_code, created_at DESC)` |
| **Future scalability** | Partition by month; retention 30–90 days then archive. |
| **Soft Delete Strategy** | **None** — purge/archive by retention job. |
| **Audit Strategy** | Not business audit; do not store secrets/PII beyond need. |

### `log.security_event`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Permission denials, suspicious access, auth anomalies. |
| **Relationships** | Optional actor_user_id. |
| **PK** | `id` UUID |
| **FKs** | optional actor → user_profile (logical or FK) |
| **Indexes** | `(created_at DESC)` |
| **Future scalability** | Longer retention than app_event; alert hooks later. |
| **Soft Delete Strategy** | None — retention policy only. |
| **Audit Strategy** | Security audit trail; restricted read permission. |

### `log.integration_event`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Results of Drive/Telegram/SAP/OpenAI calls (status, latency). |
| **Relationships** | Optional connection_id → integration.connection. |
| **PK** | `id` UUID |
| **FKs** | `connection_id` → connection (N) |
| **Indexes** | `(created_at DESC)`; connection_id |
| **Future scalability** | Correlate with sync_job / outbox attempts. |
| **Soft Delete Strategy** | None |
| **Audit Strategy** | Ops diagnostics; redact payloads. |

---

## Rules

1. Logs ≠ history (business state).  
2. Never log tokens or full document bodies.  
3. Propagate `request_id` from API edge.

---

## Related Documents

- [17_LOG_STANDARD.md](../00-governance/17_LOG_STANDARD.md)
- [14_SECURITY_STANDARD.md](../00-governance/14_SECURITY_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

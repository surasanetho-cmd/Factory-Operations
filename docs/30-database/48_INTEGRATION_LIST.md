# 48 — Integration List

**Schema:** `integration`  
**Part of:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Events:** [34_DOMAIN_EVENTS.md](../20-architecture/34_DOMAIN_EVENTS.md)  
**No SQL yet.**

---

## Inventory

| Table | Pattern | Purpose summary |
|-------|---------|-----------------|
| `connection` | A | External system connection metadata (no secrets) |
| `sync_job` | A | Batch sync run header |
| `sync_job_item` | J/min | Per-record sync status |
| `id_map` | A | External ↔ internal IDs |
| `file_link` | A | Attachment metadata (Drive/Storage) |
| `outbox` | L-like | Transactional domain event outbox |
| `idempotency_key` | special | API idempotency store |

---

### `integration.connection`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Named connection to Drive/Telegram/SAP/OpenAI; config without secrets. |
| **Relationships** | Optional plant; 1:N sync_job, id_map. |
| **PK** | `id` UUID |
| **FKs** | plant_id (N) |
| **Indexes** | uq code active |
| **Future scalability** | Multi-connection per system_type per plant. |
| **Soft Delete / Audit** | A |

### `integration.sync_job`

| Aspect | Detail |
|--------|--------|
| **Purpose** | One batch pull/push execution with cursor and status. |
| **Relationships** | N:1 connection; 1:N items. |
| **PK** | `id` UUID |
| **FKs** | connection_id |
| **Indexes** | ix (connection_id, started_at DESC) |
| **Future scalability** | Cursor/watermark in cursor_json; poison handling via item status. |
| **Soft Delete / Audit** | A |

### `integration.sync_job_item`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Per external key result within a sync job. |
| **Relationships** | N:1 sync_job (CASCADE delete of items if job hard-removed — prefer soft on job). |
| **PK** | `id` UUID |
| **FKs** | sync_job_id **ON DELETE CASCADE** |
| **Indexes** | ix sync_job_id; external_key |
| **Future scalability** | payload_hash for skip unchanged. |
| **Soft Delete** | Minimal/J; or rely on parent |
| **Audit** | Minimal |

### `integration.id_map`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Stable mapping between internal UUID and external IDs (SAP, Drive). |
| **Relationships** | N:1 connection. |
| **PK** | `id` UUID |
| **FKs** | connection_id |
| **Indexes** | uq (connection_id, entity_type, external_id) |
| **Future scalability** | Essential for idempotent SAP sync. |
| **Soft Delete / Audit** | A |

### `integration.file_link`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Attachment metadata for any entity (polymorphic). |
| **Relationships** | N:1 file_type; logical entity_type/entity_id. |
| **PK** | `id` UUID |
| **FKs** | file_type_id |
| **Indexes** | ix (entity_type, entity_id) active |
| **Future scalability** | One table for all modules — no per-module file tables. |
| **Soft Delete / Audit** | A |

### `integration.outbox`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Transactional outbox for domain events (plan.*, calendar.*, …). |
| **Relationships** | Logical aggregate_type/id; consumed by workers. |
| **PK** | `id` UUID |
| **FKs** | none required |
| **Indexes** | `ix_outbox_pending (status_code, available_at)`; ix aggregate |
| **Future scalability** | Archive done rows; retry/dead-letter via attempts + status. |
| **Soft Delete Strategy** | None — status lifecycle + archive. |
| **Audit Strategy** | Event issuance record; pair with history for business facts. |

### `integration.idempotency_key`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Store Idempotency-Key results for safe POST retries. |
| **Relationships** | Optional user_id. |
| **PK** | `id` UUID |
| **FKs** | user_id (N) |
| **Indexes** | uq (user_id, route, key); ix expires_at |
| **Future scalability** | TTL purge job (default 24h). |
| **Soft Delete Strategy** | Expire/purge — not business soft delete. |
| **Audit Strategy** | Stores response_json for replay; no secrets. |

---

## Related Documents

- [34_DOMAIN_EVENTS.md](../20-architecture/34_DOMAIN_EVENTS.md)
- [19_GOOGLE_DRIVE_STANDARD.md](../20-architecture/19_GOOGLE_DRIVE_STANDARD.md)
- [08_API_STANDARD.md](../50-development/08_API_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

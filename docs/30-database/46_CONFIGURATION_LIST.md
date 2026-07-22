# 46 — Configuration List

**Schema:** `config`  
**Part of:** [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)  
**Pattern:** **A** (mutable; soft delete allowed).  
**No SQL yet.**

---

## Inventory

| Table | Purpose summary |
|-------|-----------------|
| `system_setting` | Platform key/value settings |
| `feature_flag` | Feature toggles + payload |
| `user_preference` | Extensible per-user prefs (not theme/font/compact) |

---

### `config.system_setting`

| Aspect | Detail |
|--------|--------|
| **Purpose** | System-wide configuration (`key` → `value_json`), e.g. retention days, conflict policy. |
| **Relationships** | None required; optional `module` tag. |
| **PK** | `id` UUID |
| **FKs** | Audit actors → user_profile |
| **Indexes** | `uq_system_setting_key_active (key)` |
| **Future scalability** | Namespace keys `module.key`; avoid wide tables. |
| **Soft Delete Strategy** | A — soft delete retired keys; do not reuse keys casually. |
| **Audit Strategy** | A; important changes may also write `entity_change`. |

### `config.feature_flag`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Enable/disable features (`plan_lease`, `telegram_notifications`, …). |
| **Relationships** | None. |
| **PK** | `id` UUID |
| **FKs** | Audit actors |
| **Indexes** | `uq` code active |
| **Future scalability** | `payload_json` for percentage rollout / plant allow-lists. |
| **Soft Delete / Audit** | A |

### `config.user_preference`

| Aspect | Detail |
|--------|--------|
| **Purpose** | Extensible UI prefs as key/value per user. |
| **Relationships** | N:1 user_profile. |
| **PK** | `id` UUID |
| **FKs** | `user_id` → user_profile |
| **Indexes** | `uq (user_id, key)` active |
| **Future scalability** | Unlimited keys without altering profile columns. |
| **Soft Delete / Audit** | A |
| **Ownership note** | Theme / font_scale / compact_mode / sidebar live on `user_profile` — do not duplicate here. |

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md) § Preference ownership
- [09_UI_STANDARD.md](../40-uiux/09_UI_STANDARD.md)

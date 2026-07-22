# 19 — Google Drive Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Purpose

Google Drive stores collaborative documents (drawings, work instructions, plan exports) while PostgreSQL stores **metadata and links**. Drive is not the system of record for plans or masters.

---

## 2. Principles

1. All Drive access goes through the Integration layer.
2. File type constraints come from `master.file_type`.
3. Permissions: app RBAC decides who may attach/open; Drive ACLs configured per connection policy.
4. Never store OAuth refresh tokens in frontend code or git.

---

## 3. Data Model (Integration)

| Concept | Storage |
|---------|---------|
| Connection | `integration.connection` (`system_type=google_drive`) |
| External file id map | `integration.id_map` |
| Attachments | `integration.file_link` (`entity_type`, `entity_id`, `drive_file_id`, `storage_path`, `file_type_id`, `name`) |
| Sync runs | `integration.sync_job` |

`file_link` is in the dictionary ([05](../30-database/05_DATABASE_DICTIONARY.md)). Prefer Drive for collaborative docs; Supabase Storage only for app-private blobs. One attachment table — do not duplicate per module.

---

## 4. Supported Operations

- Upload / replace file (respect `file_type` size/mime)
- Link existing Drive file
- Open / download via authorized URL
- List attachments for an entity (part, plan, NCR, …)

---

## 5. Security

- Service account or OAuth with least Drive scopes.
- Secrets in Vercel env / secret manager.
- Log calls to `log.integration_event`.
- Virus/mime validation before accept.

---

## 6. UX

- Attachments panel shared component.
- Show file name, type icon, uploader, timestamp.
- Preview when Drive allows; else open-in-new.

---

## Related Documents

- [02_SYSTEM_ARCHITECTURE.md](02_SYSTEM_ARCHITECTURE.md)
- [14_SECURITY_STANDARD.md](../00-governance/14_SECURITY_STANDARD.md)
- [26_MASTER_DATA.md](../10-business/26_MASTER_DATA.md)

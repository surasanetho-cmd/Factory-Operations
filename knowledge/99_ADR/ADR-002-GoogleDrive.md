<!-- Canonical path: knowledge/ -->

# ADR-002 — Google Drive for enterprise documents

| Field | Value |
|-------|-------|
| Status | Accepted |
| Date | 2026-07 |

## Context

Drawings and collaboration files should live where the business already collaborates.

## Decision

Use **Google Drive API** for enterprise docs/attachments. Keep core business data in Postgres. Optional Supabase Storage only for app-private blobs.

## Consequences

- Integration credentials and audited calls required.  
- File metadata may link via `integration.file_link` (reserved).

## Related

- [GOOGLE_DRIVE.md](../50_Integration/GOOGLE_DRIVE.md)

# 14 — Security Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Principles

1. Least privilege by default.
2. Defense in depth: Auth + RBAC + RLS + server checks.
3. Secrets never in source, client bundles, or plaintext DB columns.
4. Soft-deleted data remains protected by the same access rules.
5. External integrations use dedicated credentials and audited calls.

---

## 2. Authentication

| Topic | Rule |
|-------|------|
| Provider | Supabase Auth |
| Session | Secure cookies / official SSR helpers |
| Sign-out | Invalidate session; do not assume JWT gone forever without refresh strategy |
| MFA | Optional later; design permissions without depending on MFA alone |

---

## 3. Authorization

1. Roles and permissions from `master` tables — see [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md).
2. **Never** authorize from editable `user_metadata`.
3. Prefer `app_metadata` only if carefully controlled server-side; database RBAC is primary.
4. UI hides actions for UX; server/RLS enforces for real.

---

## 4. Supabase Keys

| Key | Allowed |
|-----|---------|
| Publishable / anon | Browser OK; constrained by RLS |
| Service role | Server only (Vercel server / Edge carefully); never `NEXT_PUBLIC_` |

---

## 5. RLS

1. Enable RLS on all exposed tables.
2. Policies mirror permission model (select/insert/update).
3. UPDATE requires compatible SELECT policy.
4. Views use `security_invoker` where supported; otherwise lock down grants.

---

## 6. Data Protection & Retention

- Soft delete is **not** a security boundary — RLS still applies.
- Soft delete is **not** legal erasure (GDPR-style). Erasure requires a documented process that redacts PII while retaining non-personal audit keys where law allows.
- PII minimized; audit access to sensitive logs.
- Default retention targets (override in `config.system_setting`):
  - `log.*`: 30–90 days then archive/delete
  - `integration.outbox` completed: 30 days
  - `history.*`: long retention (business default retain; archive cold storage later)
  - Integration payloads: minimize; purge per connection policy

---

## 7. Transport & Headers

- HTTPS only in deployed environments.
- Security headers via Next.js / Vercel defaults + harden as needed.
- CSRF: follow Next.js Server Action protections; validate origins for sensitive cookie flows.

---

## 8. Dependency & Supply Chain

- Lockfiles committed.
- Review new dependencies for maintenance and license.
- No remote code execution from untrusted AI tool output without review.

---

## 9. Incident Logging

Security-relevant events go to `log.security_event` — see [17_LOG_STANDARD.md](17_LOG_STANDARD.md).

---

## Related Documents

- [15_PERMISSION_STANDARD.md](15_PERMISSION_STANDARD.md)
- [08_API_STANDARD.md](08_API_STANDARD.md)
- [21_DEPLOYMENT_STANDARD.md](21_DEPLOYMENT_STANDARD.md)
- [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md)

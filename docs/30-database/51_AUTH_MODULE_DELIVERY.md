# 51 — Auth Module Delivery (Phase 5)

**Product:** Smart-Factory Manufacturing Platform  
**Scope:** Login · Role · Permission · Menu

---

## Status

Applied to Supabase `Factory-Operations` (`ilkzavjrjwjebcyitgaj`) and shipped in app shell.

| Area | Delivery |
|------|----------|
| Login | Next.js `/login` + Supabase Auth password sign-in |
| Role | `master.role` + UI `/settings/roles` |
| Permission | `master.permission` + UI `/settings/permissions` |
| Menu | `master.menu` + `master.role_menu` + UI `/settings/menus` |
| Session | `public.rpc_auth_session_context()` |
| Signup | trigger `on_auth_user_created` → `master.user_profile` |

---

## Migrations

```text
supabase/migrations/
  20260723025154_auth_01_menu_tables.sql
  20260723025155_auth_02_session_functions.sql
  20260723025156_auth_03_views_rls.sql
  20260723025157_auth_04_seed.sql
  20260723025158_auth_05_grants.sql
```

---

## App routes

| Route | Purpose |
|-------|---------|
| `/login` | Authentication |
| `/dashboard` | Home (session summary) |
| `/settings/users` | Master User |
| `/settings/roles` | Master Role |
| `/settings/permissions` | Master Permission |
| `/settings/menus` | Master Menu |

Sidebar menus are DB-driven (`authz.my_menus`).

---

## Demo admin (local / non-prod)

Only **`admin@factory.local`** is documented as a pre-created demo user (via Auth Admin API).  
**Other emails (e.g. your Gmail) are not registered until you create them.**

### Option A — Supabase Dashboard

1. **Authentication → Users → Add user**
2. Email + password, enable **Auto confirm user**
3. SQL Editor:

```sql
select master.assign_role_by_email('your@email.com', 'admin');
```

### Option B — CLI script (uses service role from `.env.local`)

```bash
node scripts/provision-auth-user.mjs surasane.tho@gmail.com "YourPassword123!" admin
```

Then sign in at `/login`.

Rotate passwords before shared/production use.

---

## Related

- [14_SECURITY_STANDARD.md](../00-governance/14_SECURITY_STANDARD.md)
- [15_PERMISSION_STANDARD.md](../00-governance/15_PERMISSION_STANDARD.md)
- [50_SQL_MODULE_DELIVERY.md](50_SQL_MODULE_DELIVERY.md)

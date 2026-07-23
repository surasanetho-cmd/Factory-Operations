# Factory Operations

Manufacturing platform (Production Planning first) — docs + Supabase SQL + Auth shell.

## Docs

[`/docs`](docs/README.md) — standards and database design.

## Database

Supabase project **Factory-Operations** (`ilkzavjrjwjebcyitgaj`)

Migrations: [`supabase/migrations/`](supabase/migrations/)  
Tracker: [50_SQL_MODULE_DELIVERY.md](docs/30-database/50_SQL_MODULE_DELIVERY.md)  
Auth: [51_AUTH_MODULE_DELIVERY.md](docs/30-database/51_AUTH_MODULE_DELIVERY.md)

| Module | Status |
|--------|--------|
| PLATFORM | Applied |
| CALENDAR & RESOURCES | Applied |
| PRODUCT | Applied |
| AUTH / MENU (Phase 5) | Applied + app |

## App (Phase 5 Authentication)

```bash
cp .env.example .env.local   # fill Supabase URL + anon key
npm install
npm run dev
```

| Feature | Route |
|---------|-------|
| Login | `/login` |
| Roles | `/settings/roles` |
| Permissions | `/settings/permissions` |
| Menus | `/settings/menus` |
| Users | `/settings/users` |

Sidebar is driven by `master.menu` + RBAC.

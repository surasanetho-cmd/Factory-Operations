# Factory Operations

Manufacturing platform (Production Planning first).

## Layout

```text
.
├── .cursor/
├── .docs/           # pointers for agents
├── knowledge/       # SOURCE OF TRUTH (docs)
├── docs/            # legacy archive
├── src/             # Next.js app
└── supabase/        # migrations
```

## Status

Living board: [`STATUS.md`](STATUS.md)

## Knowledge

**Start:** [`knowledge/README.md`](knowledge/README.md)  
**Agent prompts:** [`prompts/README.md`](prompts/README.md)  
**Templates:** [`templates/README.md`](templates/README.md)

| Area | Path |
|------|------|
| Governance | `knowledge/00_Governance/` |
| Business | `knowledge/10_Business/` |
| Database | `knowledge/20_Database/` |
| UI/UX | `knowledge/30_UI_UX/` |
| Backend | `knowledge/40_Backend/` |
| Integration | `knowledge/50_Integration/` |
| Modules | `knowledge/60_Module/` |
| ADR | `knowledge/99_ADR/` |

## App stack

- **Next.js** (App Router) + **TypeScript**
- **Tailwind CSS** v4
- **ESLint** + **Prettier**
- **shadcn/ui** (Radix)
- **Supabase** JS client (`@supabase/supabase-js` + `@supabase/ssr`)
- **Supabase Auth** (browser + server clients, middleware session refresh)

```bash
cp .env.example .env.local   # set NEXT_PUBLIC_SUPABASE_URL + ANON_KEY
npm install
npm run dev
```

**Vercel Auto Deploy (login test):** [`knowledge/50_Integration/VERCEL.md`](knowledge/50_Integration/VERCEL.md)

| Script | Purpose |
|--------|---------|
| `npm run dev` | Local development |
| `npm run build` | Production build |
| `npm run lint` | ESLint |
| `npm run format` | Prettier write |

Auth entry: `/login` · protected shell under `src/app/(shell)/`  
Clients: `src/lib/supabase/{client,server,middleware}.ts`

## Database

Supabase project **Factory-Operations** · migrations in `supabase/migrations/`  
Plan: [`knowledge/20_Database/MIGRATION_PLAN.md`](knowledge/20_Database/MIGRATION_PLAN.md)

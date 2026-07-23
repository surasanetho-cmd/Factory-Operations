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

## App

```bash
cp .env.example .env.local
npm install
npm run dev
```

## Database

Supabase project **Factory-Operations** · migrations in `supabase/migrations/`  
Plan: [`knowledge/20_Database/MIGRATION_PLAN.md`](knowledge/20_Database/MIGRATION_PLAN.md)

# Prompts

Reusable agent prompts for Factory Operations.  
Canonical product knowledge: [`../knowledge/README.md`](../knowledge/README.md)

| Prompt | Use for |
|--------|---------|
| [planning.md](planning.md) | Plan header/detail, calendar, capacity, drag-drop, approve, release |
| [database.md](database.md) | SQL, migrations, dictionary, indexes, seeds |
| [review.md](review.md) | PR / module review checklist |
| [ui.md](ui.md) | Screens, shell, components, responsive |
| [api.md](api.md) | Server Actions, RPCs, authz, domain APIs |
| [supabase.md](supabase.md) | Project, RLS, Auth, apply migrations |
| [testing.md](testing.md) | Test plans and smoke suites |
| [deployment.md](deployment.md) | Vercel / GitHub / env / release |

## How to use

Paste the chosen file into the agent chat (or `@prompts/<name>.md`) and fill the task checkboxes / goals for the current change.

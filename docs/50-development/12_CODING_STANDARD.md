# 12 — Coding Standard

**Product:** Smart-Factory Manufacturing Platform  
**Languages:** TypeScript, React, Next.js (App Router), SQL

---

## 1. General

1. TypeScript strict mode.
2. Follow [00_PROJECT_CONSTITUTION.md](../00-governance/00_PROJECT_CONSTITUTION.md) and [23_CURSOR_RULES.md](../00-governance/23_CURSOR_RULES.md).
3. Prefer clarity over cleverness.
4. No hardcode of masters; no duplicate APIs/components/tables.
5. Read `/docs` before implementing a feature — especially [04](../30-database/04_DATABASE_STANDARD.md)/[05](../30-database/05_DATABASE_DICTIONARY.md)/[18](../20-architecture/18_CALENDAR_ENGINE.md)/[32](../30-database/32_STATUS_STATE_MACHINE.md)/[33](../30-database/33_PLANT_ORG_STANDARD.md)/[34](../20-architecture/34_DOMAIN_EVENTS.md).

---

## 2. TypeScript / React

- Named exports for components and hooks unless default export is required by framework.
- Colocate types with modules; share cross-cutting types in `types/` or `lib/`.
- Prefer Server Components by default; mark Client Components only when needed (drag-drop, charts, theme toggle).
- Follow repo React guidance when present (Compiler, `useEffectEvent`, etc.); do not add `useMemo`/`useCallback` by default without need.

---

## 3. Next.js

- App Router file conventions.
- Server Actions / Route Handlers follow [08_API_STANDARD.md](08_API_STANDARD.md).
- Environment variables: public only with `NEXT_PUBLIC_`; secrets server-only.
- Do not expose Supabase service role to the client.

---

## 4. Data Access

- Access Postgres through Supabase client or documented server repositories.
- Always filter soft-deleted rows unless explicitly querying archive.
- Send and check `version` on updates.
- Transactions for multi-table writes (plan + history).

---

## 5. Naming

| Kind | Convention |
|------|------------|
| Files (components) | `PascalCase.tsx` |
| Files (utils) | `camelCase.ts` or kebab if repo prefers — stay consistent |
| DB | `snake_case` |
| React components | `PascalCase` |
| Hooks | `useXxx` |
| Constants | `UPPER_SNAKE` only for true invariants; prefer config/DB |

---

## 6. Error Handling

- Map domain errors to API error codes.
- Log unexpected errors per [17_LOG_STANDARD.md](../00-governance/17_LOG_STANDARD.md).
- Never swallow errors silently.

---

## 7. Comments & Docs

- Comment “why”, not “what”.
- Update dictionary/ER when schema changes.
- Public functions that encode business rules get brief JSDoc.

---

## 8. Forbidden

- Hard deletes of business data
- Parallel auth systems
- Copy-paste components with slight renames
- Embedding Telegram/Drive credentials in code
- Feature flags in random constants files when `config.feature_flag` exists

---

## Related Documents

- [00_PROJECT_CONSTITUTION.md](../00-governance/00_PROJECT_CONSTITUTION.md)
- [23_CURSOR_RULES.md](../00-governance/23_CURSOR_RULES.md)
- [22_TESTING_STANDARD.md](22_TESTING_STANDARD.md)

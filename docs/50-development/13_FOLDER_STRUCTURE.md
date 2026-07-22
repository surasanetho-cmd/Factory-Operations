# 13 — Folder Structure

**Product:** Smart-Factory Manufacturing Platform  
**Note:** This document defines the **target** application structure. Do not create application source until instructed. Documentation lives in `/docs` now.

---

## 1. Repository Root (target)

```text
/
├── docs/                      # Platform standards (source of truth)
├── src/                       # Application source (future)
│   ├── app/                   # Next.js App Router
│   ├── components/
│   │   ├── ui/                # shadcn primitives
│   │   ├── shared/            # Product shell & shared widgets
│   │   └── charts/            # Chart.js wrappers
│   ├── modules/
│   │   ├── planning/
│   │   ├── production/        # future
│   │   ├── store/             # future
│   │   ├── oee/               # future
│   │   ├── quality/           # future
│   │   ├── maintenance/       # future
│   │   ├── dashboard/
│   │   └── integrations/
│   ├── lib/
│   │   ├── supabase/
│   │   ├── calendar/          # Calendar Engine client/server
│   │   ├── authz/
│   │   └── utils/
│   ├── types/
│   └── styles/
├── supabase/
│   ├── migrations/
│   ├── seed/
│   └── config.toml
├── tests/
├── public/
├── package.json
├── README.md
└── ...
```

---

## 2. Module Folder Pattern

Each module:

```text
modules/{module}/
├── components/
├── hooks/
├── services/          # domain services / server functions
├── schemas/           # zod / validation
├── types/
└── index.ts           # public exports only
```

Modules import shared shell/components; they do not fork them.

---

## 3. App Router Pattern

```text
app/
├── (auth)/
│   └── login/
├── (shell)/
│   ├── layout.tsx     # sidebar + top nav
│   ├── planning/
│   ├── dashboard/
│   └── settings/
└── api/
    └── v1/
        └── plan/
```

---

## 4. Docs Folder (current)

```text
docs/
├── 00-governance/      ← Constitution, Standards, Decisions
├── 10-business/        ← Business Flow, Requirements
├── 20-architecture/    ← System, Modules, Integrations
├── 30-database/        ← ERD, Data Dictionary, Standards
├── 40-uiux/            ← Design System, Screen Flow
├── 50-development/     ← Coding, API, Folder Structure
├── 60-deployment/      ← MCP, Vercel, GitHub, Environment
└── 99-changelog/       ← Change Log, ADR
```

Catalog index: [../README.md](../README.md).

Keep document filenames stable (`NN_TOPIC.md`). Update in place; do not renumber casually. Relocate only together with link updates across the set.

---

## 5. Rules

1. No cross-module deep imports into another module’s internals — use `index.ts` public API.
2. Supabase migrations are the only schema source of truth in code; docs must stay in sync.
3. Do not place secrets in the repo.

---

## Related Documents

- [02_SYSTEM_ARCHITECTURE.md](../20-architecture/02_SYSTEM_ARCHITECTURE.md)
- [11_COMPONENT_STANDARD.md](../40-uiux/11_COMPONENT_STANDARD.md)
- [12_CODING_STANDARD.md](12_CODING_STANDARD.md)

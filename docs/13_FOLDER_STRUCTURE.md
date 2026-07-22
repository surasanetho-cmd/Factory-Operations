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
├── 00_PROJECT_CONSTITUTION.md
├── 01_PROJECT_VISION.md
├── ...
└── 30_CHANGELOG.md
```

Keep numbering stable. Update in place; do not renumber casually.

---

## 5. Rules

1. No cross-module deep imports into another module’s internals — use `index.ts` public API.
2. Supabase migrations are the only schema source of truth in code; docs must stay in sync.
3. Do not place secrets in the repo.

---

## Related Documents

- [02_SYSTEM_ARCHITECTURE.md](02_SYSTEM_ARCHITECTURE.md)
- [11_COMPONENT_STANDARD.md](11_COMPONENT_STANDARD.md)
- [12_CODING_STANDARD.md](12_CODING_STANDARD.md)

# 03 — Tech Stack

**Product:** Smart-Factory Manufacturing Platform  
**Policy:** Use only approved stack unless Decision Log authorizes a change.

---

## 1. Approved Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Framework | **Next.js** (App Router) | Application framework, SSR/RSC, API routes |
| UI Library | **React** | Component model |
| Language | **TypeScript** | Type-safe application and domain code |
| Styling | **Tailwind CSS** | Utility styling |
| Components | **shadcn/ui** | Accessible primitive components |
| Design | Material Design 3 tokens + Google Workspace patterns | Visual language |
| Database | **PostgreSQL** via **Supabase** | System of record |
| Auth | **Supabase Auth** | Identity, sessions |
| Charts | **Chart.js** | Analytics and OEE charts |
| QR | **html5-qrcode** | Scan for parts / jobs / locations |
| Docs storage | **Google Drive API** | Drawings, attachments |
| Messaging | **Telegram Bot** | Alerts and lightweight workflows |
| AI | **OpenAI API** | Assistant features |
| Hosting | **Vercel** | App deploy |
| Source | **GitHub** | VCS and CI |

---

## 2. Stack Roles (non-overlapping)

| Concern | Owner | Must not |
|---------|-------|----------|
| Business data | Supabase Postgres | Do not store core business data only in Drive or localStorage |
| Auth identity | Supabase Auth | Do not invent a parallel auth store |
| UI primitives | shadcn/ui + design tokens | Do not add a second component library without ADR |
| Charts | Chart.js | Do not mix multiple chart libs for the same KPI types |
| File blobs (enterprise docs) | Google Drive | Prefer Drive for collaboration docs; use Supabase Storage only for app-private blobs if needed |
| Ops alerts | Telegram | Do not hardcode chat IDs in UI |

---

## 3. Versioning Policy

1. Pin major versions in package manifests; upgrade minors deliberately.
2. Document breaking upgrades in [30_CHANGELOG.md](../99-changelog/30_CHANGELOG.md) and [29_DECISION_LOG.md](../99-changelog/29_DECISION_LOG.md) when architecture is affected.
3. Prefer LTS / stable channels for Next.js, Node, and Postgres.

---

## 4. Environment Expectations

| Environment | App | Database |
|-------------|-----|----------|
| Local | Next.js dev | Supabase local or linked project |
| Preview | Vercel Preview | Shared non-prod Supabase (or branch DB if adopted) |
| Production | Vercel Production | Production Supabase project |

Details: [21_DEPLOYMENT_STANDARD.md](../60-deployment/21_DEPLOYMENT_STANDARD.md).

---

## 5. Explicitly Out of Stack (Phase 1)

Unless approved via Decision Log:

- Alternative ORMs that bypass Supabase conventions without need
- Additional CSS frameworks (Bootstrap, MUI full library) as primary system
- Hard-coded client secrets in the browser

---

## Related Documents

- [02_SYSTEM_ARCHITECTURE.md](02_SYSTEM_ARCHITECTURE.md)
- [10_DESIGN_SYSTEM.md](../40-uiux/10_DESIGN_SYSTEM.md)
- [25_MCP_CONFIG.md](../60-deployment/25_MCP_CONFIG.md)

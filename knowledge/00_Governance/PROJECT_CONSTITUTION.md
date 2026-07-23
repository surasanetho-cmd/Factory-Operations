<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 00 — Project Constitution

**Status:** Binding  
**Applies to:** All modules, all contributors, all AI agents  
**Product:** Smart-Factory Manufacturing Platform

This constitution defines non-negotiable laws. No feature, migration, or UI may violate these rules without an approved entry in [29_DECISION_LOG.md](../99-changelog/29_DECISION_LOG.md).

---

## 1. Platform Identity

1. This project is a **Manufacturing Platform**, not a single web app.
2. Current phase is **Production Planning**. Future modules must plug in without rewriting the database architecture.
3. Documentation is the source of truth. Code follows docs; docs are updated before breaking changes.

---

## 2. Architecture Laws

| Law | Statement |
|-----|-----------|
| A1 | **Architecture First** — design boundaries before implementation. |
| A2 | **Database First** — master data and schema before transactions and UI. |
| A3 | **Expand, do not rewrite** — new modules add tables/APIs/components; they do not redefine core patterns. |
| A4 | **One shared Calendar Engine** — Planning, Production, Store, OEE, and Dashboard use the same calendar domain. |
| A5 | **Config over hardcode** — lines, shifts, capacities, permissions, labels, and templates live in the database. |

---

## 3. Data Laws

| Law | Statement |
|-----|-----------|
| D1 | Separate domains via **PostgreSQL schemas**: Master, Transaction, History, Log, Configuration, Integration, Dashboard — mechanics in [04_DATABASE_STANDARD.md](../30-database/04_DATABASE_STANDARD.md). |
| D2 | Mutable business tables MUST include Audit\* columns — defined in [04_DATABASE_STANDARD.md](../30-database/04_DATABASE_STANDARD.md). |
| D3 | Primary keys are **UUID**. |
| D4 | Use **Foreign Keys**. Referential integrity is mandatory. |
| D5 | **Never hard delete** business data. Soft delete only (`deleted_at` / `deleted_by`). |
| D6 | **No duplicate tables** for the same business concept. |
| D7 | Master data exists before any transaction that references it. |
| D8 | **Plant-scoped design** — plant/site dimension exists from day one ([33_PLANT_ORG_STANDARD.md](../30-database/33_PLANT_ORG_STANDARD.md)). |
| D9 | **Statuses and numbers are config-driven** — [32_STATUS_STATE_MACHINE.md](../30-database/32_STATUS_STATE_MACHINE.md), [31_NUMBERING_STANDARD.md](../30-database/31_NUMBERING_STANDARD.md). |

---

## 4. Application Laws

| Law | Statement |
|-----|-----------|
| P1 | **Reuse components** — no duplicate UI components for the same purpose. |
| P2 | **No duplicate APIs** — one endpoint (or RPC) per capability. |
| P3 | **Responsive design** — Desktop, Tablet, Mobile. |
| P4 | **Dark / Light / Auto** themes are required. |
| P5 | UI follows **Google Workspace** patterns and **Material Design 3** tokens. |
| P6 | User preferences (font size, compact mode, dashboard layout) are persisted. |

---

## 5. Integration Laws

| Law | Statement |
|-----|-----------|
| I1 | External systems (SAP, Google Drive, Telegram, OpenAI) go through the **Integration** domain — never direct ad-hoc calls scattered in UI. |
| I2 | Integration credentials stay in secrets / env — never in source or database plaintext. |
| I3 | Notification content uses **Master Notification Templates**, not inline strings. |

---

## 6. Security & Permission Laws

| Law | Statement |
|-----|-----------|
| S1 | Supabase Auth is the identity provider. |
| S2 | Authorization is **RBAC** from Master Roles / Permissions — never from editable user metadata. |
| S3 | Row Level Security (RLS) on all exposed tables. |
| S4 | Least privilege by default. |

---

## 7. Change Control

1. Any exception to this constitution requires a Decision Log entry (ADR).
2. Schema changes update [04_DATABASE_STANDARD.md](../30-database/04_DATABASE_STANDARD.md), [05_DATABASE_DICTIONARY.md](../30-database/05_DATABASE_DICTIONARY.md), and [06_ER_DIAGRAM.md](../30-database/06_ER_DIAGRAM.md) in the same change set.
3. Agents MUST read [23_CURSOR_RULES.md](23_CURSOR_RULES.md) before writing code.

---

## 8. Enforcement Checklist

Before merge, verify:

- [ ] No hard deletes of business rows
- [ ] No hardcoded production lines, shifts, or capacities
- [ ] No new duplicate tables / APIs / components
- [ ] Audit columns present on new tables
- [ ] Soft delete and `is_active` respected in queries
- [ ] Docs updated when behavior or schema changes

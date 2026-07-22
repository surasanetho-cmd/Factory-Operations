# 23 — Cursor Rules

**Product:** Smart-Factory Manufacturing Platform  
**Audience:** Human developers and AI coding agents (Cursor)

---

## 1. Before Writing Code

1. Read [00_PROJECT_CONSTITUTION.md](00_PROJECT_CONSTITUTION.md).
2. Read module docs relevant to the task ([07_MODULES.md](07_MODULES.md), flows, standards).
3. Confirm database impact against [04](04_DATABASE_STANDARD.md)/[05](05_DATABASE_DICTIONARY.md)/[06](06_ER_DIAGRAM.md).
4. If instruction says **documentation only**, do not generate application source.

---

## 2. Hard Rules for Agents

| Rule | Detail |
|------|--------|
| Database First | Design/update dictionary before implementing tables in silence |
| Soft Delete | Never hard delete business rows |
| No Hardcode | Lines, shifts, capacities, templates from DB |
| No Duplicates | Search for existing components/APIs/tables first |
| Calendar | Use Calendar Engine; do not fork date logic |
| Security | No service role in client; no auth from user_metadata |
| Docs sync | Update docs in the same change as behavior/schema |
| Decision Log | Exceptions require [29_DECISION_LOG.md](29_DECISION_LOG.md) entry |

---

## 3. Preferred Workflow

```text
Understand → Update docs if needed → Schema → Domain service → API → UI → Tests
```

---

## 4. UI Guidance for Agents

- Follow [09_UI_STANDARD.md](09_UI_STANDARD.md) and [10_DESIGN_SYSTEM.md](10_DESIGN_SYSTEM.md).
- Reuse shell and shadcn primitives ([11_COMPONENT_STANDARD.md](11_COMPONENT_STANDARD.md)).
- Planning boards: Calendar + Resource metaphors; responsive.

---

## 5. Out of Scope Until Instructed

- Scaffolding the Next.js app (when docs phase is active)
- Inventing alternate stacks
- Creating parallel “temporary” tables that bypass standards

---

## 6. Commit Hygiene

- Descriptive commits
- Do not commit secrets
- Keep PR focused; do not drive-by unrelated refactors

---

## Related Documents

- [12_CODING_STANDARD.md](12_CODING_STANDARD.md)
- [24_ROADMAP.md](24_ROADMAP.md)
- [25_MCP_CONFIG.md](25_MCP_CONFIG.md)

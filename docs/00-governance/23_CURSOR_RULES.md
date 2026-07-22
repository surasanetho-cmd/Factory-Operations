# 23 — Cursor Rules

**Product:** Smart-Factory Manufacturing Platform  
**Audience:** Human developers and AI coding agents (Cursor)

---

## 1. Before Writing Code

1. Read [00_PROJECT_CONSTITUTION.md](00_PROJECT_CONSTITUTION.md).
2. Read module docs relevant to the task ([07_MODULES.md](../20-architecture/07_MODULES.md), flows, standards).
3. Confirm database impact against [04](../30-database/04_DATABASE_STANDARD.md)/[05](../30-database/05_DATABASE_DICTIONARY.md)/[06](../30-database/06_ER_DIAGRAM.md).
4. If instruction says **documentation only**, do not generate application source.

---

## 2. Hard Rules for Agents

| Rule | Detail |
|------|--------|
| Docs first | Constitution → relevant standards → then code |
| Database First | Update dictionary/ER before implementing tables |
| Soft Delete | Never hard delete business rows ([04](../30-database/04_DATABASE_STANDARD.md)) |
| No Hardcode | Masters/config from DB ([26](../10-business/26_MASTER_DATA.md)) |
| No Duplicates | Search existing components/APIs/tables first |
| Calendar | Use [18_CALENDAR_ENGINE.md](../20-architecture/18_CALENDAR_ENGINE.md) only |
| Plant | Include `plant_id` where plant-scoped ([33](../30-database/33_PLANT_ORG_STANDARD.md)) |
| Status / numbers | [32](../30-database/32_STATUS_STATE_MACHINE.md), [31](../30-database/31_NUMBERING_STANDARD.md) |
| Events | Write outbox with mutations ([34](../20-architecture/34_DOMAIN_EVENTS.md)) |
| Security | No service role in client; no auth from user_metadata |
| Docs sync | Same PR as behavior/schema changes |
| Exceptions | [29_DECISION_LOG.md](../99-changelog/29_DECISION_LOG.md) |

Do not restate the full constitution here — follow [00_PROJECT_CONSTITUTION.md](00_PROJECT_CONSTITUTION.md).
---

## 3. Preferred Workflow

```text
Understand → Update docs if needed → Schema → Domain service → API → UI → Tests
```

---

## 4. UI Guidance for Agents

- Follow [09_UI_STANDARD.md](../40-uiux/09_UI_STANDARD.md) and [10_DESIGN_SYSTEM.md](../40-uiux/10_DESIGN_SYSTEM.md).
- Reuse shell and shadcn primitives ([11_COMPONENT_STANDARD.md](../40-uiux/11_COMPONENT_STANDARD.md)).
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

- [12_CODING_STANDARD.md](../50-development/12_CODING_STANDARD.md)
- [24_ROADMAP.md](../10-business/24_ROADMAP.md)
- [25_MCP_CONFIG.md](../60-deployment/25_MCP_CONFIG.md)

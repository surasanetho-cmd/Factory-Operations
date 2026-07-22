# 31 — Numbering Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Purpose

Stable, human-readable document and master codes for UI, print, integrations (SAP), and search. Sequences live in `master.number_sequence` — **not** in application constants.

---

## 2. Master Codes

| Entity | Pattern | Example |
|--------|---------|---------|
| Plant | `PLANT-{CODE}` or short `SF1` | `SF1` |
| Production line | `PL-{TONNAGE}T` | `PL-110T` |
| Machine | `{LINE_CODE}-{NN}` | `PL-110T-01` |
| Part | Customer or internal code | `PRT-000123` |
| Material | Internal code | `MAT-000456` |
| Role / permission | Dot or snake codes | `planner`, `plan.production_plan.approve` |

Master `code` values are immutable after publish when referenced by transactions (change via new code + soft-deprecate old).

---

## 3. Document Numbers

| Document | `doc_type` | Default pattern | Example |
|----------|------------|-----------------|---------|
| Sales order | `sales_order` | `{PLANT}-SO-{YYYY}{#####}` | `SF1-SO-202600001` |
| Production plan | `production_plan` | `{PLANT}-PP-{YYYY}{#####}` | `SF1-PP-202600001` |
| Plan amendment | `plan_amendment` | `{PLAN_NO}-A{##}` | `SF1-PP-202600001-A01` |
| Future production job | `production_job` | `{PLANT}-PJ-{YYYY}{#####}` | — |

Patterns are stored in `master.number_sequence` (`prefix`, `pad_length`, `reset_rule`: `never` | `yearly` | `monthly`).

---

## 4. Allocation Rules

1. Allocate number inside the same DB transaction as insert.
2. Use row lock / `UPDATE … RETURNING` on `number_sequence` to avoid duplicates.
3. Never reuse numbers after soft delete.
4. Plant-scoped sequences: unique `(plant_id, doc_type)`.

---

## 5. Display

- Monospace in UI for `*_no` and master codes ([10_DESIGN_SYSTEM.md](../40-uiux/10_DESIGN_SYSTEM.md)).
- Search must match full and trailing numeric portions.

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [26_MASTER_DATA.md](../10-business/26_MASTER_DATA.md)
- [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md)

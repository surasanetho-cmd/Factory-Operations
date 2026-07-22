# 35 — Units of Measure (UoM) Standard

**Product:** Smart-Factory Manufacturing Platform

---

## 1. Rule

Never store free-text UoM on parts/materials. Use `master.uom` and FKs (`uom_id`).

---

## 2. Tables

| Table | Purpose |
|-------|---------|
| `master.uom` | `code`, `name`, `dimension` (`count`, `mass`, `length`, `time`, …) |
| `master.uom_conversion` | `from_uom_id`, `to_uom_id`, `factor` (multiply from→to) |

Conversions only within the same `dimension`.

---

## 3. Seed Examples

| code | dimension |
|------|-----------|
| `EA` | count |
| `KG` | mass |
| `G` | mass |
| `M` | length |
| `MIN` | time |
| `H` | time |

---

## 4. Usage

| Entity | Field |
|--------|-------|
| Part | `uom_id` (stocking / planning qty unit) |
| Material | `uom_id` |
| BOM `part_material` | `qty_per` + `uom_id` |
| Plan item qty | Interpreted in part UoM unless overridden |

---

## 5. API / UI

- Display `uom.code` beside quantities.
- Convert only via registered conversions; unknown pair → `422`.

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [26_MASTER_DATA.md](../10-business/26_MASTER_DATA.md)

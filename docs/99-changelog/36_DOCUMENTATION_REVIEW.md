# 36 — Documentation Review

**Product:** Smart-Factory Manufacturing Platform  
**Date:** 2026-07-22  
**Scope:** Review of docs `00`–`30`; remediation in this change set (`04`–`06`, `18`, new `31`–`36`, related updates)

---

## 1. Duplicated Ideas Found

| Topic | Was repeated in | Remediation |
|-------|-----------------|-------------|
| Soft delete / Audit\* / UUID | `00`, `04`, `12`, `23`, ADR | Laws in `00`; mechanics in `04`; others link |
| Schema list | `00`, `02`, `04` | Schemas required in `04` + ADR-008; architecture links |
| Module catalog / phases | `01`, `02`, `07`, `24` | Catalog `07`; roadmap `24`; vision shortened |
| E2E Order→Shipping | `01`, `27` | Authority `27`; vision links |
| Line list + 20–30 jobs/day | `01`, `04`, `26`, `22` | Volume KPI `01`; seed codes `26` |
| Calendar mandate | `00`, `02`, `07`, `18` | Spec `18`; law `00` |
| Plan statuses | `05`, `27` | Machine `32` + `27`; dictionary stores codes only |
| RBAC / user_metadata | `00`, `04`, `14`, `15`, `23` | Model `15`; security `14` |
| Prefs storage | `05`, `09` | Single ownership table in `05` §9 |
| Stack topology | `02`, `03`, `21` | Stack `03`; deploy `21` |

---

## 2. Missing Standards (addressed)

| Gap | Doc added / expanded |
|-----|----------------------|
| Document numbering | [31_NUMBERING_STANDARD.md](../30-database/31_NUMBERING_STANDARD.md) |
| Status state machines | [32_STATUS_STATE_MACHINE.md](../30-database/32_STATUS_STATE_MACHINE.md) |
| Plant / org / tenancy | [33_PLANT_ORG_STANDARD.md](../30-database/33_PLANT_ORG_STANDARD.md) |
| Domain events / outbox | [34_DOMAIN_EVENTS.md](../20-architecture/34_DOMAIN_EVENTS.md) |
| UoM | [35_UOM_STANDARD.md](../30-database/35_UOM_STANDARD.md) |
| Schemas vs prefixes | `04` + ADR-008 |
| Idempotency store | `05` + `08` |
| OT / shutdown tables | `05`, `18` |
| BOM / part_material | `05`, `06` |
| Calendar assignment | `05`, `18` |
| RLS helper names | `15` |
| Indexes | `04` |
| Backup/DR + env catalog | `21` |
| Retention / soft-delete ≠ erasure | `14` |
| Amendment after release | `32`, `27`, ADR-009 |

### Still deferred (P2 — track in roadmap)

- Full barcode/QR + label/print standard
- Offline MES operator mode
- Formal GDPR subject-erasure runbook
- Inventory valuation method details
- Crew/people as calendar resources
- Search indexing standard (beyond shell entry point)
- Partitioning job designs for OEE samples

---

## 3. Database Problems Fixed

| Problem | Fix |
|---------|-----|
| Prefix vs schema ambiguity | PostgreSQL schemas required |
| Part ‖-- Material ER wrong | `master.part_material` BOM |
| Capacity both FKs set | XOR CHECK documented |
| No calendar on line/machine | `calendar_id` + plant default resolution |
| OT/shutdown unnamed | `txn.ot_window`, `txn.machine_shutdown` |
| `created_by` → auth vs profile | → `user_profile.id` only; `auth_user_id` UNIQUE |
| Status free strings | `master.status_code` + `status_code` columns |
| Prefs triple-store confusion | Ownership matrix in dictionary |
| `file_link` / outbox / idempotency missing | Added under `integration` |
| No plant dimension | `master.plant` + `plant_id` on scoped tables |
| Shift template only | `master.shift_assignment` |
| Free-text UoM | `master.uom` + FK |
| Missing board indexes | Listed in `04` |
| Audit exceptions unclear | Exception table in `04` |

---

## 4. Scalability Issues Called Out

| Risk | Mitigation in docs |
|------|--------------------|
| Multi-plant rewrite | Plant standard from day one |
| Released plan rigidity | `plan_amendment` + ADR-009 |
| Chatty calendar on drag | Cache + read-model guidance in `18` |
| Month-board row volume | Indexes + projections + events |
| Integration spaghetti | Outbox standard |
| Unbounded history/log/OEE | Partition/archive notes in `04`/`34` |
| Optimistic lock only | Optional plan lease in `04`/`08` |

---

## 5. Suggested Next Doc Actions (after code starts)

1. Keep dictionary and ER in the same PR as every migration.
2. Add barcode/label standard before shop-floor scanning UI.
3. Add search standard when global search is implemented.
4. Expand observability (metrics/SLO) when Vercel/Supabase monitoring is wired.

---

## Related Documents

- [29_DECISION_LOG.md](29_DECISION_LOG.md)
- [30_CHANGELOG.md](30_CHANGELOG.md)
- [24_ROADMAP.md](../10-business/24_ROADMAP.md)

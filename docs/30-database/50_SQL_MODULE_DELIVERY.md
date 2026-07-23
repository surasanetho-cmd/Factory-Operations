# 50 — SQL Module Delivery

**Product:** Smart-Factory Manufacturing Platform  
**Rule:** One module at a time. Wait for review before the next module.

---

## Delivery order

| # | Module | Status | Migrations |
|---|--------|--------|------------|
| 1 | **PLATFORM** | Applied to remote `Factory Operations System` (`mpjenispayfpsozcyird`) | `platform_01` … `platform_09` |
| 2 | **CALENDAR & RESOURCES** | Applied to remote `Factory Operations System` (`mpjenispayfpsozcyird`) | `calendar_01` … `calendar_09` |
| 3 | PRODUCT | Pending | customer, part, material, BOM, process |
| 4 | PLANNING (txn) | Pending | sales_order, production_plan*, approvals, history |
| 5 | INTEGRATION / LOG / DASHBOARD | Pending | outbox, sync, file_link, logs, layouts |
| 6+ | Production / Store / OEE / … | Later | reserved tables |

---

## Module 1 — PLATFORM

### Includes

| Area | Objects |
|------|---------|
| Schemas | `master`, `txn`, `history`, `log`, `config`, `integration`, `dashboard`, `authz` |
| Tables | `plant`, `department`, `user_profile`, `role`, `permission`, `role_permission`, `user_role`, `uom`, `uom_conversion`, `status_code`, `reason_code`, `file_type`, `notification_template`, `number_sequence`, `config.system_setting`, `config.feature_flag`, `config.user_preference` |
| Functions | `master.set_updated_at`, `master.soft_delete_row`, `master.next_document_no`, `authz.*` |
| Triggers | `trg_*_set_updated_at` on mutable tables |
| Views | `master.v_*_active`, `config.v_feature_flag_active` |
| Seed | Plant `SF1`, departments, roles, permissions, matrix, UoM, statuses, reasons, file types, templates, sequences, feature flags, settings |
| RLS | Enabled + baseline policies |

### Migration files

```text
supabase/migrations/
  20260723003927_platform_01_schemas_extensions.sql
  20260723003928_platform_02_audit_helpers.sql
  20260723003929_platform_03_master_org_rbac.sql
  20260723003932_platform_04_master_lookups.sql
  20260723003933_platform_05_config.sql
  20260723003934_platform_06_authz_functions_rls.sql
  20260723003935_platform_07_views.sql
  20260723003936_platform_08_seed.sql
  20260723003937_platform_09_grants.sql
```

---

## Module 2 — CALENDAR & RESOURCES (this delivery)

### Includes

| Area | Objects |
|------|---------|
| Tables (`master`) | `calendar`, `holiday`, `production_line`, `machine`, `shift`, `shift_assignment`, `capacity` |
| Tables (`txn`) | `ot_window`, `machine_shutdown` |
| FK | `plant.default_calendar_id` → `calendar.id` |
| Functions | `master.resolve_calendar_id`, `master.is_holiday`, `master.is_working_day`, `master.weekday_bit`, `master.get_capacity_for_date` |
| RPCs | `public.engine_calendar_resolve_calendar`, `engine_calendar_is_working_day`, `engine_calendar_get_capacity` |
| Triggers | `trg_*_set_updated_at` on all new mutable tables |
| Views | `master.v_calendar_active`, `v_holiday_active`, `v_production_line_active`, `v_machine_active`, `v_shift_active`, `v_capacity_active`, `txn.v_ot_window_active`, `txn.v_machine_shutdown_active` |
| Seed | Calendar `SF1-STD`, holidays 2026–2027, lines `PL-110T`…`PL-3200T`, machines `*-01`, shifts `DAY`/`NIGHT`, assignments Mon–Fri, capacity 25 jobs / 8h, permissions |
| RLS | Plant-scoped select + manage policies |

### Migration files

```text
supabase/migrations/
  20260723020920_calendar_01_master_calendar_holiday.sql
  20260723020921_calendar_02_master_line_machine.sql
  20260723020922_calendar_03_master_shift_capacity.sql
  20260723020923_calendar_04_txn_ot_shutdown.sql
  20260723020924_calendar_05_engine_functions.sql
  20260723020925_calendar_06_views.sql
  20260723020926_calendar_07_rls.sql
  20260723020927_calendar_08_seed.sql
  20260723020928_calendar_09_grants.sql
```

### Not in Module 2

- Customer / part / material / BOM / process  
- Planning transactions (`sales_order`, `production_plan*`)  
- Full Calendar Engine window/timeline service (SQL helpers only)  
- History / outbox / dashboard tables  

---

## Review checklist (Module 2)

- [ ] Calendar resolution order matches [18_CALENDAR_ENGINE.md](../20-architecture/18_CALENDAR_ENGINE.md)  
- [ ] Line XOR machine CHECKs on capacity / OT  
- [ ] Seed lines 110T–3200T and shifts acceptable  
- [ ] Approve to apply to remote Supabase, then proceed with **Module 3: PRODUCT**

---

## Related Documents

- [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)
- [43_MASTER_DATA_LIST.md](43_MASTER_DATA_LIST.md)
- [44_TRANSACTION_LIST.md](44_TRANSACTION_LIST.md)
- [18_CALENDAR_ENGINE.md](../20-architecture/18_CALENDAR_ENGINE.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

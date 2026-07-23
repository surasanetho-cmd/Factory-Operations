# 50 — SQL Module Delivery

**Product:** Smart-Factory Manufacturing Platform  
**Rule:** One module at a time. Wait for review before the next module.

---

## Delivery order

| # | Module | Status | Migrations |
|---|--------|--------|------------|
| 1 | **PLATFORM** | Applied to remote `Factory Operations System` (`mpjenispayfpsozcyird`) | `platform_01` … `platform_09` |
| 2 | CALENDAR & RESOURCES | Pending | calendar, holiday, line, machine, shift, capacity, OT/shutdown |
| 3 | PRODUCT | Pending | customer, part, material, BOM, process |
| 4 | PLANNING (txn) | Pending | sales_order, production_plan*, approvals, history |
| 5 | INTEGRATION / LOG / DASHBOARD | Pending | outbox, sync, file_link, logs, layouts |
| 6+ | Production / Store / OEE / … | Later | reserved tables |

---

## Module 1 — PLATFORM (this delivery)

### Includes

| Area | Objects |
|------|---------|
| Schemas | `master`, `txn`, `history`, `log`, `config`, `integration`, `dashboard`, `authz` |
| Tables | `plant`, `department`, `user_profile`, `role`, `permission`, `role_permission`, `user_role`, `uom`, `uom_conversion`, `status_code`, `reason_code`, `file_type`, `notification_template`, `number_sequence`, `config.system_setting`, `config.feature_flag`, `config.user_preference` |
| Functions | `master.set_updated_at`, `master.soft_delete_row`, `master.next_document_no`, `authz.current_user_profile_id`, `authz.user_plant_ids`, `authz.has_permission`, `authz.has_permission_for_plant` |
| Triggers | `trg_*_set_updated_at` on mutable tables |
| Views | `master.v_*_active`, `config.v_feature_flag_active` |
| Seed | Plant `SF1`, departments, roles, permissions, matrix, UoM, statuses, reasons, file types, templates, sequences, feature flags, settings |
| RLS | Enabled + baseline policies |

### Migration files

```text
supabase/migrations/
  20260723003927_platform_01_schemas_extensions.sql
  20260723003931_platform_02_audit_helpers.sql
  20260723003931_platform_03_master_org_rbac.sql
  20260723003932_platform_04_master_lookups.sql
  20260723003933_platform_05_config.sql
  20260723003934_platform_06_authz_functions_rls.sql
  20260723003935_platform_07_views.sql
  20260723003936_platform_08_seed.sql
  20260723003937_platform_09_grants.sql
```

### Apply locally

```bash
npx supabase start
npx supabase db reset   # applies all migrations + seed migration
```

### Not in Module 1

- Calendar / lines / machines / shifts / capacity  
- Parts / customers / BOM  
- Planning transactions  
- History / outbox / dashboard tables  

---

## Review checklist (Module 1)

- [ ] Schemas and naming match docs  
- [ ] Soft delete + audit columns present  
- [ ] Authz helpers match [15_PERMISSION_STANDARD.md](../00-governance/15_PERMISSION_STANDARD.md)  
- [ ] Seed roles/permissions/status codes acceptable  
- [ ] Approve to proceed with **Module 2: CALENDAR & RESOURCES**

---

## Related Documents

- [40_DATABASE_ARCHITECTURE.md](40_DATABASE_ARCHITECTURE.md)
- [43_MASTER_DATA_LIST.md](43_MASTER_DATA_LIST.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)

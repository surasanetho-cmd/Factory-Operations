<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# SAP Integration

**Product:** Smart-Factory Manufacturing Platform  
**Status:** Future (Roadmap Phase 4)  
**Policy:** No parallel system of record — SAP sync via integration tables.

---

## Intent

| Direction | Examples |
|-----------|----------|
| Inbound | Sales orders, materials, customers |
| Outbound | Released plan / production confirmations (TBD) |

## Design constraints

1. Use `integration.connection`, `integration.id_map`, outbox/idempotency (reserved tables).  
2. Map external IDs — never overwrite local UUIDs.  
3. Plant-scoped sync jobs.  
4. Document field mappings in ADR before build.

## Non-goals (now)

Live SAP GUI replacement; financial posting automation without ADR.

## Related

- [ROADMAP.md](../00_Governance/ROADMAP.md)
- Legacy list: `/docs/30-database/48_INTEGRATION_LIST.md`

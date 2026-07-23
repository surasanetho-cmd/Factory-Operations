<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# Terminology

**Product:** Smart-Factory Manufacturing Platform

| Term | Meaning |
|------|---------|
| Plant | Site root (`master.plant`); owns timezone and default calendar |
| Production line | Press/line resource (`master.production_line`), e.g. `PL-110T` |
| Machine | Resource on a line (`master.machine`) |
| Shift | Time template (`master.shift`) with optional midnight cross |
| Calendar | Named working calendar + holidays |
| Capacity | Nominal jobs/hours for line XOR machine + shift |
| Part | Sellable / planned item (`master.part`) |
| Customer | Order party (`master.customer`) |
| Process | Routing step catalog (`master.process`) |
| BOM | Part → material link (`master.part_material`) |
| Sales order | Demand header (`txn.sales_order`) |
| Production plan | Planning header (`txn.production_plan`) |
| Plan item | Scheduled job / drag-drop unit (`txn.production_plan_item`) |
| Approval | Submit / approve / reject event (`txn.plan_approval`) |
| Release | Hand-off to Production (`txn.plan_release`) |
| OT window | Approved overtime interval |
| Shutdown | Machine unavailability block |
| Permission | Atomic `module.resource.action` |
| Menu | Sidebar item gated by permission / role_menu |
| Soft delete | `deleted_at` set; row retained |
| Calendar Engine | Shared resolver for working days, shifts, OT, shutdown, capacity |

## Related

- [BUSINESS_FLOW.md](BUSINESS_FLOW.md)
- [DATA_DICTIONARY.md](../20_Database/DATA_DICTIONARY.md)

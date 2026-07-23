<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 06 — ER Diagram (Complete)

**Product:** Smart-Factory Manufacturing Platform  
**Audit\* columns omitted** — see [04](04_DATABASE_STANDARD.md) / [05](05_DATABASE_DICTIONARY.md)  
**Relationships matrix:** [37_TABLE_RELATIONSHIPS.md](37_TABLE_RELATIONSHIPS.md)

---

## 1. Platform overview

```mermaid
flowchart TB
  subgraph masterSchema [master]
    Plant[plant]
    Authz[user role permission]
    Product[part material BOM]
    Resources[line machine shift calendar]
  end
  subgraph txnSchema [txn]
    Orders[sales_order]
    Plans[production_plan]
    CalIn[ot_window shutdown]
  end
  subgraph support [support]
    History[history]
    Log[log]
    Config[config]
    Integ[integration]
    Dash[dashboard]
  end
  Plant --> Resources
  Plant --> Orders
  Plant --> Plans
  Product --> Plans
  Resources --> Plans
  Resources --> CalIn
  Plans --> History
  Plans --> Integ
```

---

## 2. Organization & RBAC

```mermaid
erDiagram
  PLANT ||--o{ DEPARTMENT : has
  DEPARTMENT ||--o{ DEPARTMENT : parent_of
  PLANT ||--o{ USER_PROFILE : default_for
  DEPARTMENT ||--o{ USER_PROFILE : employs
  USER_PROFILE ||--o{ USER_ROLE : assigned
  ROLE ||--o{ USER_ROLE : granted_to
  PLANT ||--o{ USER_ROLE : scopes
  ROLE ||--o{ ROLE_PERMISSION : includes
  PERMISSION ||--o{ ROLE_PERMISSION : granted

  PLANT {
    uuid id PK
    text code UK
    text timezone
    uuid default_calendar_id FK
  }
  USER_PROFILE {
    uuid id PK
    uuid auth_user_id UK
    uuid default_plant_id FK
  }
  ROLE {
    uuid id PK
    text code UK
  }
  PERMISSION {
    uuid id PK
    text code UK
  }
```

---

## 3. Product masters (BOM + routing)

```mermaid
erDiagram
  PLANT ||--o{ CUSTOMER : hosts
  PLANT ||--o{ PART : owns
  PLANT ||--o{ MATERIAL : owns
  CUSTOMER ||--o{ PART : specifies
  UOM ||--o{ PART : measures
  UOM ||--o{ MATERIAL : measures
  UOM ||--o{ UOM_CONVERSION : from
  UOM ||--o{ UOM_CONVERSION : to
  PART ||--o{ PART_MATERIAL : bom_parent
  MATERIAL ||--o{ PART_MATERIAL : bom_child
  UOM ||--o{ PART_MATERIAL : bom_uom
  PART ||--o{ PART_PROCESS : routed
  PROCESS ||--o{ PART_PROCESS : step

  PART_MATERIAL {
    uuid id PK
    uuid part_id FK
    uuid material_id FK
    numeric qty_per
  }
  PART_PROCESS {
    uuid id PK
    uuid part_id FK
    uuid process_id FK
    int sequence
  }
```

---

## 4. Calendar, resources, capacity

```mermaid
erDiagram
  PLANT ||--o{ CALENDAR : owns
  PLANT ||--o{ PRODUCTION_LINE : owns
  PLANT ||--o{ MACHINE : owns
  PLANT ||--o{ SHIFT : templates
  PLANT ||--o{ CAPACITY : rates
  PLANT ||--o{ SHIFT_ASSIGNMENT : assigns

  CALENDAR ||--o{ HOLIDAY : contains
  CALENDAR ||--o{ PRODUCTION_LINE : overrides
  CALENDAR ||--o{ MACHINE : overrides
  PRODUCTION_LINE ||--o{ MACHINE : contains

  SHIFT ||--o{ SHIFT_ASSIGNMENT : applied_as
  PRODUCTION_LINE ||--o{ SHIFT_ASSIGNMENT : scoped_line
  MACHINE ||--o{ SHIFT_ASSIGNMENT : scoped_machine

  SHIFT ||--o{ CAPACITY : for_shift
  PRODUCTION_LINE ||--o{ CAPACITY : line_cap
  MACHINE ||--o{ CAPACITY : machine_cap

  PRODUCTION_LINE ||--o{ OT_WINDOW : ot
  MACHINE ||--o{ OT_WINDOW : ot
  MACHINE ||--o{ MACHINE_SHUTDOWN : blocked

  CAPACITY {
    uuid id PK
    uuid production_line_id FK
    uuid machine_id FK
    uuid shift_id FK
  }
  HOLIDAY {
    uuid id PK
    uuid calendar_id FK
    date holiday_date
  }
```

**Rules**

- Capacity: XOR `production_line_id` / `machine_id`
- Calendar resolve: machine → line → `plant.default_calendar_id`

---

## 5. Planning transactions

```mermaid
erDiagram
  PLANT ||--o{ SALES_ORDER : receives
  CUSTOMER ||--o{ SALES_ORDER : places
  SALES_ORDER ||--o{ SALES_ORDER_LINE : lines
  PART ||--o{ SALES_ORDER_LINE : ordered

  PLANT ||--o{ PRODUCTION_PLAN : plans
  PRODUCTION_PLAN ||--o{ PRODUCTION_PLAN_ITEM : items
  PRODUCTION_PLAN ||--o{ PLAN_APPROVAL : approvals
  PRODUCTION_PLAN ||--o{ PLAN_RELEASE : releases
  PRODUCTION_PLAN ||--o{ PLAN_AMENDMENT : amendments

  SALES_ORDER_LINE ||--o{ PRODUCTION_PLAN_ITEM : allocates
  PART ||--o{ PRODUCTION_PLAN_ITEM : makes
  PRODUCTION_LINE ||--o{ PRODUCTION_PLAN_ITEM : runs
  MACHINE ||--o{ PRODUCTION_PLAN_ITEM : runs
  SHIFT ||--o{ PRODUCTION_PLAN_ITEM : on_shift

  PRODUCTION_PLAN ||--o{ PRODUCTION_PLAN_HISTORY : audited
  PRODUCTION_PLAN_ITEM ||--o{ PRODUCTION_PLAN_ITEM_HISTORY : audited

  PRODUCTION_PLAN {
    uuid id PK
    text plan_no UK
    text horizon_type
    text status_code
    int version
  }
  PRODUCTION_PLAN_ITEM {
    uuid id PK
    uuid production_plan_id FK
    timestamptz planned_start_at
    timestamptz planned_end_at
    numeric qty
    text status_code
  }
```

---

## 6. Integration, config, dashboard

```mermaid
erDiagram
  CONNECTION ||--o{ SYNC_JOB : runs
  SYNC_JOB ||--o{ SYNC_JOB_ITEM : items
  CONNECTION ||--o{ ID_MAP : maps
  FILE_TYPE ||--o{ FILE_LINK : types
  USER_PROFILE ||--o{ USER_PREFERENCE : prefs
  USER_PROFILE ||--o{ DASHBOARD_LAYOUT : layouts
  ROLE ||--o{ DASHBOARD_LAYOUT : role_layouts
  PLANT ||--o{ DASHBOARD_LAYOUT : plant_layouts
  DASHBOARD_LAYOUT ||--o{ DASHBOARD_WIDGET : widgets

  OUTBOX {
    uuid id PK
    text event_type
    text status_code
    timestamptz available_at
  }
  IDEMPOTENCY_KEY {
    uuid id PK
    text key
    text route
  }
```

---

## 7. Cardinality notes

| Relationship | Cardinality |
|--------------|-------------|
| Plant → Lines | 1:N |
| Line → Machines | 1:N |
| Plan → Items | 1:N |
| Order → Lines | 1:N |
| Part → BOM rows | 1:N |
| Part ↔ Material | N:M via `part_material` |
| Role ↔ Permission | N:M via `role_permission` |
| User ↔ Role | N:M via `user_role` |
| Layout → Widgets | 1:N (CASCADE) |

---

## Related Documents

- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [37_TABLE_RELATIONSHIPS.md](37_TABLE_RELATIONSHIPS.md)
- [38_FOREIGN_KEYS.md](38_FOREIGN_KEYS.md)

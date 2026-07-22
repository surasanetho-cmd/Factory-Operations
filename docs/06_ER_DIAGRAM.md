# 06 — ER Diagram

**Product:** Smart-Factory Manufacturing Platform  
**Scope:** Plant, masters, calendar, authz, BOM, planning  
**Columns:** Audit\* omitted for clarity — see [04](04_DATABASE_STANDARD.md) / [05](05_DATABASE_DICTIONARY.md)

---

## 1. Organization, Authz, Product

```mermaid
erDiagram
  PLANT ||--o{ DEPARTMENT : organizes
  PLANT ||--o{ PRODUCTION_LINE : owns
  PLANT ||--o{ USER_PROFILE : defaultPlant
  DEPARTMENT ||--o{ DEPARTMENT : parent
  DEPARTMENT ||--o{ USER_PROFILE : employs

  USER_PROFILE ||--o{ USER_ROLE : has
  ROLE ||--o{ USER_ROLE : grants
  ROLE ||--o{ ROLE_PERMISSION : includes
  PERMISSION ||--o{ ROLE_PERMISSION : assigned

  UOM ||--o{ PART : measures
  UOM ||--o{ MATERIAL : measures
  CUSTOMER ||--o{ PART : orders
  PART ||--o{ PART_PROCESS : routed
  PROCESS ||--o{ PART_PROCESS : step
  PART ||--o{ PART_MATERIAL : bom
  MATERIAL ||--o{ PART_MATERIAL : component

  PLANT {
    uuid id PK
    string code
    string timezone
  }
  USER_PROFILE {
    uuid id PK
    uuid auth_user_id UK
    uuid default_plant_id FK
  }
  PART_MATERIAL {
    uuid id PK
    uuid part_id FK
    uuid material_id FK
    numeric qty_per
  }
```

---

## 2. Calendar, Line, Capacity

```mermaid
erDiagram
  PLANT ||--o{ CALENDAR : has
  PLANT ||--o{ SHIFT : templates
  CALENDAR ||--o{ HOLIDAY : defines
  PRODUCTION_LINE }o--|| CALENDAR : optionalOverride
  MACHINE }o--|| CALENDAR : optionalOverride
  PRODUCTION_LINE ||--o{ MACHINE : contains

  SHIFT ||--o{ SHIFT_ASSIGNMENT : applied
  PRODUCTION_LINE ||--o{ SHIFT_ASSIGNMENT : scoped
  MACHINE ||--o{ SHIFT_ASSIGNMENT : scoped

  PRODUCTION_LINE ||--o{ CAPACITY : lineCapacity
  MACHINE ||--o{ CAPACITY : machineCapacity
  SHIFT ||--o{ CAPACITY : window

  PRODUCTION_LINE ||--o{ OT_WINDOW : overtime
  MACHINE ||--o{ MACHINE_SHUTDOWN : blocked

  CAPACITY {
    uuid id PK
    uuid production_line_id FK
    uuid machine_id FK
    uuid shift_id FK
    int jobs_per_day
  }
```

**Capacity rule:** exactly one of `production_line_id` or `machine_id` is set (XOR).

**Calendar resolution:** machine.calendar_id → line.calendar_id → plant.default_calendar_id.

---

## 3. Planning Transactions

```mermaid
erDiagram
  PLANT ||--o{ SALES_ORDER : receives
  CUSTOMER ||--o{ SALES_ORDER : places
  SALES_ORDER ||--o{ SALES_ORDER_LINE : contains
  PART ||--o{ SALES_ORDER_LINE : requested

  PLANT ||--o{ PRODUCTION_PLAN : plans
  PRODUCTION_PLAN ||--o{ PRODUCTION_PLAN_ITEM : schedules
  PRODUCTION_PLAN ||--o{ PLAN_APPROVAL : reviewed
  PRODUCTION_PLAN ||--o{ PLAN_RELEASE : released
  PRODUCTION_PLAN ||--o{ PLAN_AMENDMENT : amends

  SALES_ORDER_LINE ||--o{ PRODUCTION_PLAN_ITEM : fulfills
  PART ||--o{ PRODUCTION_PLAN_ITEM : makes
  PRODUCTION_LINE ||--o{ PRODUCTION_PLAN_ITEM : runs_on
  MACHINE ||--o{ PRODUCTION_PLAN_ITEM : assigned
  SHIFT ||--o{ PRODUCTION_PLAN_ITEM : timed
  STATUS_CODE ||--o{ PRODUCTION_PLAN : headerStatus
  STATUS_CODE ||--o{ PRODUCTION_PLAN_ITEM : itemStatus

  PRODUCTION_PLAN {
    uuid id PK
    string plan_no
    string horizon_type
    string status_code
    int version
  }
  PRODUCTION_PLAN_ITEM {
    uuid id PK
    uuid production_plan_id FK
    numeric qty
    string status_code
    int version
  }
```

---

## 4. History / Prefs / Dashboard

```mermaid
erDiagram
  PRODUCTION_PLAN ||--o{ PRODUCTION_PLAN_HISTORY : audited
  PRODUCTION_PLAN_ITEM ||--o{ PRODUCTION_PLAN_ITEM_HISTORY : audited
  USER_PROFILE ||--o{ USER_PREFERENCE : extensiblePrefs
  USER_PROFILE ||--o{ DASHBOARD_LAYOUT : owns
  DASHBOARD_LAYOUT ||--o{ DASHBOARD_WIDGET : contains
```

---

## 5. Notes

1. Soft delete: FKs remain; queries filter `deleted_at IS NULL`.
2. BOM is `part_material` — **not** a direct Part→Material one-to-many ownership edge.
3. Calendar Engine inputs: holiday, shift_assignment, capacity, `ot_window`, `machine_shutdown`, maintenance (future).
4. Column authority: [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md).

---

## Related Documents

- [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md)
- [33_PLANT_ORG_STANDARD.md](33_PLANT_ORG_STANDARD.md)

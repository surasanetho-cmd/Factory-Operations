# 06 — ER Diagram

**Product:** Smart-Factory Manufacturing Platform  
**Scope:** Masters, Calendar, Authz, Planning transactions

---

## 1. Core Master & Authz

```mermaid
erDiagram
  USER_PROFILE ||--o{ USER_ROLE : has
  ROLE ||--o{ USER_ROLE : grants
  ROLE ||--o{ ROLE_PERMISSION : includes
  PERMISSION ||--o{ ROLE_PERMISSION : assigned
  DEPARTMENT ||--o{ USER_PROFILE : employs
  DEPARTMENT ||--o{ DEPARTMENT : parent

  CUSTOMER ||--o{ PART : orders
  PART ||--o{ PART_PROCESS : routed
  PROCESS ||--o{ PART_PROCESS : step
  PART ||--o{ MATERIAL : uses

  PRODUCTION_LINE ||--o{ MACHINE : contains
  PRODUCTION_LINE ||--o{ CAPACITY : rated
  MACHINE ||--o{ CAPACITY : rated
  SHIFT ||--o{ CAPACITY : window

  CALENDAR ||--o{ HOLIDAY : defines

  USER_PROFILE {
    uuid id PK
    uuid auth_user_id
    string employee_code
    string display_name
  }
  ROLE {
    uuid id PK
    string code
  }
  PERMISSION {
    uuid id PK
    string code
    string module
  }
  PRODUCTION_LINE {
    uuid id PK
    string code
    int tonnage
  }
  MACHINE {
    uuid id PK
    uuid production_line_id FK
    string code
  }
  SHIFT {
    uuid id PK
    string code
    time start_time
    time end_time
  }
  CALENDAR {
    uuid id PK
    string code
  }
  HOLIDAY {
    uuid id PK
    uuid calendar_id FK
    date holiday_date
  }
  CAPACITY {
    uuid id PK
    uuid production_line_id FK
    uuid machine_id FK
    uuid shift_id FK
    int jobs_per_day
  }
```

---

## 2. Planning Transactions

```mermaid
erDiagram
  CUSTOMER ||--o{ SALES_ORDER : places
  SALES_ORDER ||--o{ SALES_ORDER_LINE : contains
  PART ||--o{ SALES_ORDER_LINE : requested

  PRODUCTION_PLAN ||--o{ PRODUCTION_PLAN_ITEM : schedules
  PRODUCTION_PLAN ||--o{ PLAN_APPROVAL : reviewed
  PRODUCTION_PLAN ||--o{ PLAN_RELEASE : released

  SALES_ORDER_LINE ||--o{ PRODUCTION_PLAN_ITEM : fulfills
  PART ||--o{ PRODUCTION_PLAN_ITEM : makes
  PRODUCTION_LINE ||--o{ PRODUCTION_PLAN_ITEM : runs_on
  MACHINE ||--o{ PRODUCTION_PLAN_ITEM : assigned
  SHIFT ||--o{ PRODUCTION_PLAN_ITEM : timed

  PRODUCTION_PLAN {
    uuid id PK
    string plan_no
    string horizon_type
    date period_start
    date period_end
    string status
    int version
  }
  PRODUCTION_PLAN_ITEM {
    uuid id PK
    uuid production_plan_id FK
    uuid part_id FK
    uuid production_line_id FK
    uuid machine_id FK
    uuid shift_id FK
    timestamptz planned_start_at
    timestamptz planned_end_at
    numeric qty
    string status
    int version
  }
```

---

## 3. History / Config / Dashboard (logical)

```mermaid
erDiagram
  PRODUCTION_PLAN ||--o{ PRODUCTION_PLAN_HISTORY : audited
  PRODUCTION_PLAN_ITEM ||--o{ PRODUCTION_PLAN_ITEM_HISTORY : audited
  USER_PROFILE ||--o{ USER_PREFERENCE : stores
  USER_PROFILE ||--o{ DASHBOARD_LAYOUT : owns
  DASHBOARD_LAYOUT ||--o{ DASHBOARD_WIDGET : contains
```

---

## 4. Notes

1. All business entities include Audit\* columns (omitted in diagrams for clarity).
2. Soft delete: relationships remain; queries filter `deleted_at IS NULL`.
3. Calendar Engine reads `calendar`, `holiday`, `shift`, `capacity`, plus future shutdown/maintenance transactions — see [18_CALENDAR_ENGINE.md](18_CALENDAR_ENGINE.md).
4. Full column lists: [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md).

---

## Related Documents

- [04_DATABASE_STANDARD.md](04_DATABASE_STANDARD.md)
- [05_DATABASE_DICTIONARY.md](05_DATABASE_DICTIONARY.md)
- [26_MASTER_DATA.md](26_MASTER_DATA.md)

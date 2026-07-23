# Template — New Table

**Update first:** `knowledge/20_Database/DATA_DICTIONARY.md`, `TABLE_RELATIONSHIP.md`, `INDEX_STANDARD.md`  
**Then:** `supabase/migrations/<timestamp>_<name>.sql`  
**Related prompt:** `prompts/database.md`

---

## Identity

| Field | Value |
|-------|-------|
| Schema | `master` / `txn` / `history` / `log` / `config` / `integration` / `dashboard` |
| Table | `<!-- snake_case singular -->` |
| Pattern | `A` Audit\* / `J` junction / `H` history / `E` event / `L` log |
| Plant-scoped | Yes / No / via parent |
| Soft delete | Yes / No |

---

## Purpose

<!-- One sentence -->

## Columns

| Column | Type | Null | Default | Notes |
|--------|------|------|---------|-------|
| `id` | `uuid` | N | `gen_random_uuid()` | PK |
| `plant_id` | `uuid` | | | FK → `master.plant` if scoped |
| | | | | |
| `created_at` | `timestamptz` | N | `now()` | A |
| `updated_at` | `timestamptz` | N | `now()` | A (+ trigger) |
| `created_by` | `uuid` | Y | | FK → `user_profile` |
| `updated_by` | `uuid` | Y | | |
| `deleted_at` | `timestamptz` | Y | | |
| `deleted_by` | `uuid` | Y | | |
| `is_active` | `boolean` | N | `true` | |
| `version` | `integer` | N | `1` | A |

## Primary key

- `id` uuid

## Foreign keys

| Name | Column | References | On delete |
|------|--------|------------|-----------|
| `fk_<table>_<col>` | | | `RESTRICT` |

## CHECKs

| Name | Expression |
|------|------------|
| `ck_<table>_version_positive` | `version >= 1` |
| | |

## Indexes

| Name | Columns | Predicate |
|------|---------|-----------|
| `uq_<table>_…_active` | | `deleted_at IS NULL` |
| `ix_<table>_…` | | |

## Triggers

- [ ] `trg_<table>_set_updated_at` → `master.set_updated_at()`

## RLS

| Policy | Command | Using / check |
|--------|---------|---------------|
| `<table>_select_…` | SELECT | plant + permission |
| `<table>_…` | ALL/INSERT/UPDATE | permission |

## Seed (optional)

```sql
-- idempotent insert …
```

## SQL sketch

```sql
create table <schema>.<table> (
  id uuid primary key default gen_random_uuid()
  -- …
);
```

## Checklist

- [ ] Dictionary entry added
- [ ] Relationships / FKs catalog updated
- [ ] Index strategy updated
- [ ] Migration file added (forward-only)
- [ ] Grants + RLS
- [ ] No Postgres ENUM for status

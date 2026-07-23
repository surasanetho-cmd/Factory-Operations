-- Module: AUTH (Phase 5)
-- master.menu + master.role_menu

-- ---------------------------------------------------------------------------
-- master.menu
-- ---------------------------------------------------------------------------
create table master.menu (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid null references master.menu (id) on delete restrict,
  code text not null,
  label text not null,
  path text null,
  icon text null,
  sort_order integer not null default 0,
  module text null,
  permission_code text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_menu_version_positive check (version >= 1)
);

create unique index uq_menu_code_active
  on master.menu (code)
  where deleted_at is null;

create index ix_menu_parent_sort
  on master.menu (parent_id, sort_order)
  where deleted_at is null;

create index ix_menu_permission_code
  on master.menu (permission_code)
  where deleted_at is null and permission_code is not null;

create trigger trg_menu_set_updated_at
  before update on master.menu
  for each row execute function master.set_updated_at();

comment on table master.menu is 'Sidebar / navigation menu items (permission-gated)';
comment on column master.menu.permission_code is 'If set, user needs this permission to see the item';

-- ---------------------------------------------------------------------------
-- master.role_menu — explicit role → menu grants (pattern J)
-- When rows exist for a role, they AND with permission_code checks.
-- If a menu has permission_code only (no role_menu rows required), permission gates visibility.
-- role_menu is used for optional extra pinning; visibility still requires permission when set.
-- ---------------------------------------------------------------------------
create table master.role_menu (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references master.role (id) on delete restrict,
  menu_id uuid not null references master.menu (id) on delete restrict,
  created_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true
);

create unique index uq_role_menu_active
  on master.role_menu (role_id, menu_id)
  where deleted_at is null;

create index ix_role_menu_role_id
  on master.role_menu (role_id)
  where deleted_at is null;

create index ix_role_menu_menu_id
  on master.role_menu (menu_id)
  where deleted_at is null;

comment on table master.role_menu is 'Optional explicit role → menu assignments';

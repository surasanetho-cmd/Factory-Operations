-- Module: CALENDAR & RESOURCES
-- master.calendar, master.holiday + plant.default_calendar_id FK

-- ---------------------------------------------------------------------------
-- master.calendar
-- ---------------------------------------------------------------------------
create table master.calendar (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid null references master.plant (id) on delete restrict,
  code text not null,
  name text not null,
  timezone text not null default 'Asia/Bangkok',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_calendar_version_positive check (version >= 1)
);

create unique index uq_calendar_plant_code_active
  on master.calendar (plant_id, code)
  where deleted_at is null;

create index ix_calendar_plant_id
  on master.calendar (plant_id)
  where deleted_at is null;

create trigger trg_calendar_set_updated_at
  before update on master.calendar
  for each row execute function master.set_updated_at();

comment on table master.calendar is 'Named working calendar (IANA timezone) for Calendar Engine';

-- ---------------------------------------------------------------------------
-- master.holiday
-- ---------------------------------------------------------------------------
create table master.holiday (
  id uuid primary key default gen_random_uuid(),
  calendar_id uuid not null references master.calendar (id) on delete restrict,
  holiday_date date not null,
  name text not null,
  is_paid boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid null references master.user_profile (id) on delete restrict,
  updated_by uuid null references master.user_profile (id) on delete restrict,
  deleted_at timestamptz null,
  deleted_by uuid null references master.user_profile (id) on delete restrict,
  is_active boolean not null default true,
  version integer not null default 1,
  constraint ck_holiday_version_positive check (version >= 1)
);

create unique index uq_holiday_calendar_date_active
  on master.holiday (calendar_id, holiday_date)
  where deleted_at is null;

create index ix_holiday_calendar_date
  on master.holiday (calendar_id, holiday_date)
  where deleted_at is null;

create trigger trg_holiday_set_updated_at
  before update on master.holiday
  for each row execute function master.set_updated_at();

comment on table master.holiday is 'Non-working holiday dates for a calendar';

-- ---------------------------------------------------------------------------
-- Close circular FK: plant.default_calendar_id → calendar
-- ---------------------------------------------------------------------------
alter table master.plant
  add constraint fk_plant_default_calendar_id
  foreign key (default_calendar_id) references master.calendar (id)
  on delete restrict;

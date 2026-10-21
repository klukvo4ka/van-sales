alter table customers
  add column if not exists driver_id uuid references driver_profiles(id);

alter table customers
  add column if not exists route_order integer not null default 0;

create index if not exists customers_driver_id_idx on customers (driver_id);

alter table truck_load_items
  add column if not exists requested_qty numeric(12,3) not null default 0;

alter table truck_loads
  drop constraint if exists truck_loads_status_check;

alter table truck_loads
  add constraint truck_loads_status_check
  check (status in ('pending', 'approved', 'loaded'));

alter table truck_loads
  alter column status set default 'pending';

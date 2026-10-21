alter table truck_load_items
  alter column requested_qty type numeric(12,3)
  using requested_qty::numeric;

alter table truck_load_items
  alter column quantity_loaded type numeric(12,3)
  using quantity_loaded::numeric;

alter table truck_load_items
  alter column quantity_returned type numeric(12,3)
  using quantity_returned::numeric;

alter table trucks
  alter column capacity type numeric(12,3)
  using capacity::numeric;

alter table truck_loads drop constraint if exists truck_loads_status_check;
alter table truck_loads
  add constraint truck_loads_status_check
  check (status in ('pending', 'approved', 'loaded'));
alter table truck_loads alter column status set default 'pending';

alter table truck_loads drop column if exists requested_qty;
alter table truck_load_items
  add column if not exists requested_qty numeric(12,3) not null default 0;

alter table customers drop constraint if exists customers_driver_id_fkey;
alter table customers
  add constraint customers_driver_id_fkey
  foreign key (driver_id) references driver_profiles(id) on delete set null;

update storage.buckets set public = false where name = 'load-receipts';

drop policy if exists "public read load receipts" on storage.objects;
drop policy if exists "auth upload load receipts" on storage.objects;
drop policy if exists "auth update load receipts" on storage.objects;

drop policy if exists "receipts_select" on storage.objects;
create policy "receipts_select" on storage.objects
  for select to authenticated
  using (bucket_id = 'load-receipts');

drop policy if exists "receipts_insert" on storage.objects;
create policy "receipts_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'load-receipts');

drop policy if exists "receipts_update" on storage.objects;
create policy "receipts_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'load-receipts')
  with check (bucket_id = 'load-receipts');

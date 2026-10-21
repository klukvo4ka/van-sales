alter table customers add column if not exists photo_outside_url text;
alter table customers add column if not exists photo_inside_url text;

insert into storage.buckets (id, name, public)
values ('customer-photos', 'customer-photos', false)
on conflict (id) do update set public = false;

drop policy if exists "customer_photos_select" on storage.objects;
create policy "customer_photos_select" on storage.objects
  for select to authenticated
  using (bucket_id = 'customer-photos');

drop policy if exists "customer_photos_insert" on storage.objects;
create policy "customer_photos_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'customer-photos');

drop policy if exists "customer_photos_update" on storage.objects;
create policy "customer_photos_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'customer-photos')
  with check (bucket_id = 'customer-photos');

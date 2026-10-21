alter table invoices add column if not exists photo_url text;

insert into storage.buckets (id, name, public)
values ('invoice-photos', 'invoice-photos', false)
on conflict (id) do update set public = false;

drop policy if exists "invoice_photos_select" on storage.objects;
create policy "invoice_photos_select" on storage.objects
  for select to authenticated
  using (bucket_id = 'invoice-photos');

drop policy if exists "invoice_photos_insert" on storage.objects;
create policy "invoice_photos_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'invoice-photos');

drop policy if exists "invoice_photos_update" on storage.objects;
create policy "invoice_photos_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'invoice-photos')
  with check (bucket_id = 'invoice-photos');

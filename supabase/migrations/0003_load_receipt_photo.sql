alter table truck_loads
  add column if not exists bill_photo_url text;

insert into storage.buckets (id, name, public)
values ('load-receipts', 'load-receipts', true)
on conflict (id) do nothing;

create policy "auth upload load receipts" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'load-receipts');

create policy "auth update load receipts" on storage.objects
  for update to authenticated
  using (bucket_id = 'load-receipts');

create policy "public read load receipts" on storage.objects
  for select to public
  using (bucket_id = 'load-receipts');

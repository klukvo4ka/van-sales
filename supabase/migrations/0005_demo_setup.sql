alter table truck_loads add column if not exists requested_qty int4 not null default 0;
alter table truck_loads add column if not exists bill_photo_url text;

alter table truck_load_items add column if not exists requested_qty int4 not null default 0;

alter table customers add column if not exists driver_id uuid references auth.users(id);
alter table customers add column if not exists route_order int4 not null default 0;

alter table trucks add column if not exists capacity int4 not null default 0;

alter table truck_loads drop constraint if exists truck_loads_status_check;
alter table truck_loads
  add constraint truck_loads_status_check
  check (status in ('pending', 'approved', 'loaded', 'open', 'closed'));

insert into storage.buckets (id, name, public)
values ('load-receipts', 'load-receipts', false)
on conflict (id) do nothing;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.driver_profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'Driver'),
    coalesce(new.raw_user_meta_data->>'role', 'driver')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_office_or_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from driver_profiles p
    where p.id = auth.uid() and p.role in ('office', 'admin')
  );
$$;

alter table driver_profiles   enable row level security;
alter table products          enable row level security;
alter table customers         enable row level security;
alter table trucks            enable row level security;
alter table truck_loads       enable row level security;
alter table truck_load_items  enable row level security;
alter table invoices          enable row level security;
alter table invoice_items     enable row level security;
alter table payments          enable row level security;

drop policy if exists "auth read trucks"            on trucks;
drop policy if exists "auth read products"          on products;
drop policy if exists "auth read customers"         on customers;
drop policy if exists "driver read own profile"     on driver_profiles;
drop policy if exists "driver read own loads"       on truck_loads;
drop policy if exists "driver insert own loads"     on truck_loads;
drop policy if exists "driver read own invoices"    on invoices;
drop policy if exists "driver insert own invoices"  on invoices;
drop policy if exists "driver update own invoices"  on invoices;
drop policy if exists "driver insert payments"      on payments;
drop policy if exists "driver read own payments"    on payments;
drop policy if exists "driver read own load items"  on truck_load_items;
drop policy if exists "driver write own load items" on truck_load_items;
drop policy if exists "driver read own invoice items"  on invoice_items;
drop policy if exists "driver write own invoice items" on invoice_items;

drop policy if exists "profiles_select" on driver_profiles;
create policy "profiles_select" on driver_profiles
  for select to authenticated
  using (id = auth.uid() or public.is_office_or_admin());

drop policy if exists "profiles_insert" on driver_profiles;
create policy "profiles_insert" on driver_profiles
  for insert to authenticated
  with check (id = auth.uid());

drop policy if exists "profiles_update" on driver_profiles;
create policy "profiles_update" on driver_profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists "products_select" on products;
create policy "products_select" on products
  for select to authenticated
  using (true);

drop policy if exists "products_insert" on products;
create policy "products_insert" on products
  for insert to authenticated
  with check (public.is_office_or_admin());

drop policy if exists "products_update" on products;
create policy "products_update" on products
  for update to authenticated
  using (public.is_office_or_admin())
  with check (public.is_office_or_admin());

drop policy if exists "products_delete" on products;
create policy "products_delete" on products
  for delete to authenticated
  using (public.is_office_or_admin());

drop policy if exists "customers_select" on customers;
create policy "customers_select" on customers
  for select to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "customers_insert" on customers;
create policy "customers_insert" on customers
  for insert to authenticated
  with check (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "customers_update" on customers;
create policy "customers_update" on customers
  for update to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin())
  with check (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "customers_delete" on customers;
create policy "customers_delete" on customers
  for delete to authenticated
  using (public.is_office_or_admin());

drop policy if exists "trucks_select" on trucks;
create policy "trucks_select" on trucks
  for select to authenticated
  using (true);

drop policy if exists "trucks_insert" on trucks;
create policy "trucks_insert" on trucks
  for insert to authenticated
  with check (public.is_office_or_admin());

drop policy if exists "trucks_update" on trucks;
create policy "trucks_update" on trucks
  for update to authenticated
  using (public.is_office_or_admin())
  with check (public.is_office_or_admin());

drop policy if exists "trucks_delete" on trucks;
create policy "trucks_delete" on trucks
  for delete to authenticated
  using (public.is_office_or_admin());

drop policy if exists "loads_select" on truck_loads;
create policy "loads_select" on truck_loads
  for select to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "loads_insert" on truck_loads;
create policy "loads_insert" on truck_loads
  for insert to authenticated
  with check (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "loads_update" on truck_loads;
create policy "loads_update" on truck_loads
  for update to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin())
  with check (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "load_items_select" on truck_load_items;
create policy "load_items_select" on truck_load_items
  for select to authenticated
  using (
    public.is_office_or_admin()
    or exists (select 1 from truck_loads l
               where l.id = truck_load_items.load_id and l.driver_id = auth.uid())
  );

drop policy if exists "load_items_insert" on truck_load_items;
create policy "load_items_insert" on truck_load_items
  for insert to authenticated
  with check (
    public.is_office_or_admin()
    or exists (select 1 from truck_loads l
               where l.id = truck_load_items.load_id and l.driver_id = auth.uid())
  );

drop policy if exists "load_items_update" on truck_load_items;
create policy "load_items_update" on truck_load_items
  for update to authenticated
  using (
    public.is_office_or_admin()
    or exists (select 1 from truck_loads l
               where l.id = truck_load_items.load_id and l.driver_id = auth.uid())
  );

drop policy if exists "invoices_select" on invoices;
create policy "invoices_select" on invoices
  for select to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "invoices_insert" on invoices;
create policy "invoices_insert" on invoices
  for insert to authenticated
  with check (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "invoices_update" on invoices;
create policy "invoices_update" on invoices
  for update to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin())
  with check (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "invoice_items_select" on invoice_items;
create policy "invoice_items_select" on invoice_items
  for select to authenticated
  using (
    public.is_office_or_admin()
    or exists (select 1 from invoices i
               where i.id = invoice_items.invoice_id and i.driver_id = auth.uid())
  );

drop policy if exists "invoice_items_insert" on invoice_items;
create policy "invoice_items_insert" on invoice_items
  for insert to authenticated
  with check (
    public.is_office_or_admin()
    or exists (select 1 from invoices i
               where i.id = invoice_items.invoice_id and i.driver_id = auth.uid())
  );

drop policy if exists "invoice_items_update" on invoice_items;
create policy "invoice_items_update" on invoice_items
  for update to authenticated
  using (
    public.is_office_or_admin()
    or exists (select 1 from invoices i
               where i.id = invoice_items.invoice_id and i.driver_id = auth.uid())
  );

drop policy if exists "payments_select" on payments;
create policy "payments_select" on payments
  for select to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "payments_insert" on payments;
create policy "payments_insert" on payments
  for insert to authenticated
  with check (driver_id = auth.uid() or public.is_office_or_admin());

drop policy if exists "payments_update" on payments;
create policy "payments_update" on payments
  for update to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin())
  with check (driver_id = auth.uid() or public.is_office_or_admin());

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

insert into products (name, name_fa, sku, unit, price, is_active) values
  ('Ariel Washing Powder 1kg', 'اریل پودر لباسشویی ۱ کیلو', 'ARI-1KG', 'pcs', 350, true),
  ('Omo 500g',                 'اومو ۵۰۰ گرم',              'OMO-500', 'pcs', 180, true),
  ('Pepsi 1L',                 'پیپسی ۱ لیتر',              'PEP-1L',  'pcs', 60,  true),
  ('Coca-Cola 1L',             'کوکاکولا ۱ لیتر',           'COL-1L',  'pcs', 60,  true),
  ('Lipton Tea 100g',          'چای لیپتون ۱۰۰ گرم',        'LIP-100', 'pcs', 120, true),
  ('Nescafe 50g',              'نسکافه ۵۰ گرم',             'NES-50',  'pcs', 220, true),
  ('Sunflower Oil 1L',         'روغن آفتابگردان ۱ لیتر',    'OIL-1L',  'pcs', 140, true),
  ('Sugar 1kg',                'بوره ۱ کیلو',               'SUG-1KG', 'kg',  75,  true),
  ('Rice 5kg',                 'برنج ۵ کیلو',               'RICE-5KG','pcs', 650, true),
  ('Biscuits 200g',            'بسکویت ۲۰۰ گرم',            'BIS-200', 'pcs', 45,  true)
on conflict (sku) do nothing;

insert into trucks (name, plate_number, capacity, is_active) values
  ('Truck 01', 'KBL-1234', 1000, true),
  ('Truck 02', 'KBL-5678', 1000, true)
on conflict (plate_number) do nothing;

insert into driver_profiles (id, full_name, role)
select u.id, 'Office Admin', 'office'
from auth.users u
where u.email = 'office@demo.local'
on conflict (id) do update
  set full_name = excluded.full_name, role = excluded.role;

insert into driver_profiles (id, full_name, role, truck_id)
select u.id, 'Ahmad Driver', 'driver',
       (select id from trucks where plate_number = 'KBL-1234')
from auth.users u
where u.email = 'driver@demo.local'
on conflict (id) do update
  set full_name = excluded.full_name,
      role      = excluded.role,
      truck_id  = excluded.truck_id;

insert into customers (id, name, phone, address, driver_id, route_order)
select '11111111-1111-1111-1111-111111111111', 'Noor General Store', '0700111222',
       'Shar-e-Naw, Kabul', u.id, 1
from auth.users u where u.email = 'driver@demo.local'
on conflict (id) do nothing;

insert into customers (id, name, phone, address, driver_id, route_order)
select '22222222-2222-2222-2222-222222222222', 'Zahra Market', '0700333444',
       'Karte-Char, Kabul', u.id, 2
from auth.users u where u.email = 'driver@demo.local'
on conflict (id) do nothing;

insert into customers (id, name, phone, address, driver_id, route_order)
select '33333333-3333-3333-3333-333333333333', 'Karim Grocery', '0700555666',
       'Dasht-e-Barchi, Kabul', u.id, 3
from auth.users u where u.email = 'driver@demo.local'
on conflict (id) do nothing;

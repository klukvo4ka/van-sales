create table trucks (
  id uuid primary key default gen_random_uuid(),
  plate_number text not null unique,
  name text not null,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_fa text,
  sku text unique,
  unit text not null default 'pcs',
  price numeric(12,2) not null default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  address text,
  credit_limit numeric(12,2) default 0,
  balance numeric(12,2) default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table driver_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  truck_id uuid references trucks(id),
  role text not null default 'driver' check (role in ('driver', 'office', 'admin')),
  is_active boolean default true,
  created_at timestamptz default now()
);

create table truck_loads (
  id uuid primary key default gen_random_uuid(),
  truck_id uuid not null references trucks(id),
  driver_id uuid not null references driver_profiles(id),
  load_date date not null default current_date,
  status text default 'open' check (status in ('open', 'closed')),
  created_at timestamptz default now(),
  unique(truck_id, load_date)
);

create table truck_load_items (
  id uuid primary key default gen_random_uuid(),
  load_id uuid not null references truck_loads(id) on delete cascade,
  product_id uuid not null references products(id),
  quantity_loaded numeric(12,3) not null default 0,
  quantity_returned numeric(12,3) default 0,
  created_at timestamptz default now()
);

create table invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_number text unique,
  truck_load_id uuid references truck_loads(id),
  customer_id uuid not null references customers(id),
  driver_id uuid not null references driver_profiles(id),
  invoice_date date not null default current_date,
  total_amount numeric(12,2) not null default 0,
  paid_amount numeric(12,2) default 0,
  status text default 'unpaid' check (status in ('unpaid', 'partial', 'paid')),
  notes text,
  synced boolean default false,
  created_at timestamptz default now()
);

create table invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references invoices(id) on delete cascade,
  product_id uuid not null references products(id),
  quantity numeric(12,3) not null,
  unit_price numeric(12,2) not null,
  total numeric(12,2) generated always as (quantity * unit_price) stored,
  created_at timestamptz default now()
);

create table payments (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references invoices(id),
  customer_id uuid not null references customers(id),
  driver_id uuid not null references driver_profiles(id),
  amount numeric(12,2) not null,
  payment_method text default 'cash' check (payment_method in ('cash', 'transfer')),
  payment_date date default current_date,
  notes text,
  synced boolean default false,
  created_at timestamptz default now()
);

alter table trucks enable row level security;
alter table products enable row level security;
alter table customers enable row level security;
alter table driver_profiles enable row level security;
alter table truck_loads enable row level security;
alter table truck_load_items enable row level security;
alter table invoices enable row level security;
alter table invoice_items enable row level security;
alter table payments enable row level security;

create policy "auth read trucks" on trucks for select to authenticated using (true);
create policy "auth read products" on products for select to authenticated using (true);
create policy "auth read customers" on customers for select to authenticated using (true);

create policy "driver read own profile" on driver_profiles for select to authenticated using (auth.uid() = id);
create policy "driver read own loads" on truck_loads for select to authenticated using (driver_id = auth.uid());
create policy "driver insert own loads" on truck_loads for insert to authenticated with check (driver_id = auth.uid());
create policy "driver read own invoices" on invoices for select to authenticated using (driver_id = auth.uid());
create policy "driver insert own invoices" on invoices for insert to authenticated with check (driver_id = auth.uid());
create policy "driver update own invoices" on invoices for update to authenticated using (driver_id = auth.uid());
create policy "driver insert payments" on payments for insert to authenticated with check (driver_id = auth.uid());
create policy "driver read own payments" on payments for select to authenticated using (driver_id = auth.uid());

create policy "driver read own load items" on truck_load_items
  for select to authenticated
  using (exists (
    select 1 from truck_loads tl
    where tl.id = truck_load_items.load_id and tl.driver_id = auth.uid()
  ));

create policy "driver write own load items" on truck_load_items
  for insert to authenticated
  with check (exists (
    select 1 from truck_loads tl
    where tl.id = truck_load_items.load_id and tl.driver_id = auth.uid()
  ));

create policy "driver read own invoice items" on invoice_items
  for select to authenticated
  using (exists (
    select 1 from invoices i
    where i.id = invoice_items.invoice_id and i.driver_id = auth.uid()
  ));

create policy "driver write own invoice items" on invoice_items
  for insert to authenticated
  with check (exists (
    select 1 from invoices i
    where i.id = invoice_items.invoice_id and i.driver_id = auth.uid()
  ));

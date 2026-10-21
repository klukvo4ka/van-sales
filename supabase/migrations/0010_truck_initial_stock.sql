create table if not exists truck_initial_stock (
  id uuid primary key default gen_random_uuid(),
  truck_id uuid not null references trucks(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  quantity numeric(12,3) not null default 0 check (quantity >= 0),
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (truck_id, product_id)
);

create index if not exists truck_initial_stock_truck_id_idx
  on truck_initial_stock (truck_id);

create index if not exists truck_initial_stock_product_id_idx
  on truck_initial_stock (product_id);

alter table truck_initial_stock enable row level security;

drop policy if exists "truck_initial_stock_select" on truck_initial_stock;
create policy "truck_initial_stock_select" on truck_initial_stock
  for select to authenticated
  using (
    public.is_office_or_admin()
    or exists (
      select 1
      from driver_profiles p
      where p.id = auth.uid()
        and p.truck_id = truck_initial_stock.truck_id
    )
  );

drop policy if exists "truck_initial_stock_insert" on truck_initial_stock;
create policy "truck_initial_stock_insert" on truck_initial_stock
  for insert to authenticated
  with check (public.is_office_or_admin());

drop policy if exists "truck_initial_stock_update" on truck_initial_stock;
create policy "truck_initial_stock_update" on truck_initial_stock
  for update to authenticated
  using (public.is_office_or_admin())
  with check (public.is_office_or_admin());

drop policy if exists "truck_initial_stock_delete" on truck_initial_stock;
create policy "truck_initial_stock_delete" on truck_initial_stock
  for delete to authenticated
  using (public.is_office_or_admin());

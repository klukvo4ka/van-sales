create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

alter table customers  add column if not exists updated_at timestamptz not null default now();
alter table products   add column if not exists updated_at timestamptz not null default now();
alter table categories add column if not exists updated_at timestamptz not null default now();
alter table invoices   add column if not exists updated_at timestamptz not null default now();
alter table truck_initial_stock alter column updated_at set default now();

drop trigger if exists touch_customers_updated_at on customers;
create trigger touch_customers_updated_at
  before update on customers
  for each row execute function public.touch_updated_at();

drop trigger if exists touch_products_updated_at on products;
create trigger touch_products_updated_at
  before update on products
  for each row execute function public.touch_updated_at();

drop trigger if exists touch_categories_updated_at on categories;
create trigger touch_categories_updated_at
  before update on categories
  for each row execute function public.touch_updated_at();

drop trigger if exists touch_invoices_updated_at on invoices;
create trigger touch_invoices_updated_at
  before update on invoices
  for each row execute function public.touch_updated_at();

drop trigger if exists touch_truck_initial_stock_updated_at on truck_initial_stock;
create trigger touch_truck_initial_stock_updated_at
  before update on truck_initial_stock
  for each row execute function public.touch_updated_at();

create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_fa text,
  sort_order int not null default 0
);

create unique index if not exists categories_name_key
  on categories (name);

alter table products
  add column if not exists category_id uuid
  references categories(id) on delete set null;

insert into categories (name, name_fa, sort_order) values
  ('Beverages', 'نوشیدنی‌ها', 1),
  ('Cleaning',  'مواد شوینده', 2),
  ('Food',      'مواد غذایی', 3),
  ('Other',     'سایر',       4)
on conflict (name) do update
  set name_fa = excluded.name_fa,
      sort_order = excluded.sort_order;

alter table categories enable row level security;

drop policy if exists "categories_select" on categories;
create policy "categories_select" on categories
  for select to authenticated
  using (true);

drop policy if exists "categories_write" on categories;
create policy "categories_write" on categories
  for all to authenticated
  using (public.is_office_or_admin())
  with check (public.is_office_or_admin());

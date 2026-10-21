create extension if not exists pgcrypto with schema extensions;

insert into trucks (id, plate_number, name, is_active)
select
  md5('seed-truck-' || n)::uuid,
  'KBL-' || (100 + n),
  'Truck ' || lpad(n::text, 2, '0'),
  true
from generate_series(1, 12) n
on conflict do nothing;

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select
  md5('seed-driver-' || n)::uuid,
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'driver' || lpad(n::text, 2, '0') || '@demo.local',
  extensions.crypt(current_setting('seed.driver_password'), extensions.gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object(
    'full_name', 'Driver ' || lpad(n::text, 2, '0'),
    'role', 'driver'
  ),
  now(), now(), '', '', '', ''
from generate_series(1, 12) n
on conflict do nothing;

insert into auth.identities (
  id, user_id, provider_id, identity_data, provider,
  last_sign_in_at, created_at, updated_at
)
select
  gen_random_uuid(),
  u.id,
  u.id::text,
  jsonb_build_object('sub', u.id::text, 'email', u.email,
                     'email_verified', true),
  'email',
  now(), now(), now()
from auth.users u
where u.email ~ '^driver[0-9]{2}@demo\.local$'
  and not exists (
    select 1 from auth.identities i
    where i.user_id = u.id and i.provider = 'email'
  );

insert into driver_profiles (id, full_name, role, is_active)
select
  md5('seed-driver-' || n)::uuid,
  'Driver ' || lpad(n::text, 2, '0'),
  'driver',
  true
from generate_series(1, 12) n
on conflict (id) do nothing;

update driver_profiles p
set truck_id = md5('seed-truck-' || n)::uuid, is_active = true
from generate_series(1, 12) n
where p.id = md5('seed-driver-' || n)::uuid;

insert into categories (id, name, name_fa, sort_order)
values
  (md5('seed-cat-1')::uuid, 'Beverages', 'نوشیدنی', 1),
  (md5('seed-cat-2')::uuid, 'Snacks', 'خوراکه', 2),
  (md5('seed-cat-3')::uuid, 'Dairy', 'لبنیات', 3),
  (md5('seed-cat-4')::uuid, 'Household', 'خانگی', 4)
on conflict do nothing;

insert into products (id, name, name_fa, sku, unit, price, category_id, is_active)
select
  md5('seed-prod-' || t.sku)::uuid,
  t.name, t.name_fa, t.sku, t.unit, t.price,
  (select c.id from categories c where c.name = (array['Beverages','Snacks','Dairy','Household'])[t.cat]),
  true
from (values
  ('Cola 1.5L',        'کولا ۱.۵ لیتر',      'BEV-001', 'carton', 480, 1),
  ('Orange Juice 1L',  'آب پرتقال ۱ لیتر',   'BEV-002', 'carton', 620, 1),
  ('Mineral Water',    'آب معدنی',           'BEV-003', 'carton', 240, 1),
  ('Energy Drink',     'انرژی درنک',          'BEV-004', 'carton', 900, 1),
  ('Black Tea 500g',   'چای سیاه ۵۰۰ گرم',   'BEV-005', 'bag',    350, 1),
  ('Potato Chips',     'چپس کچالو',           'SNK-001', 'carton', 400, 2),
  ('Salted Biscuits',  'بسکویت نمکی',         'SNK-002', 'carton', 320, 2),
  ('Chocolate Wafers', 'ویفر چاکلیتی',        'SNK-003', 'carton', 450, 2),
  ('Chewing Gum',      'ساجق',                'SNK-004', 'box',    280, 2),
  ('Dried Fruit Mix',  'میوه خشک',            'SNK-005', 'bag',    750, 2),
  ('UHT Milk 1L',      'شیر ۱ لیتر',          'DRY-001', 'carton', 540, 3),
  ('Yogurt Cups',      'ماست پیاله‌ای',       'DRY-002', 'carton', 380, 3),
  ('Cheese Spread',    'پنیر',                'DRY-003', 'box',    610, 3),
  ('Butter 500g',      'مسکه ۵۰۰ گرم',       'DRY-004', 'box',    720, 3),
  ('Cream 200ml',      'قیماق ۲۰۰ میلی',     'DRY-005', 'carton', 300, 3),
  ('Laundry Soap',     'صابون کالاشویی',      'HHD-001', 'carton', 260, 4),
  ('Dish Liquid',      'مایع ظرفشویی',        'HHD-002', 'carton', 340, 4),
  ('Shampoo 400ml',    'شامپو ۴۰۰ میلی',     'HHD-003', 'carton', 560, 4),
  ('Toothpaste',       'کریم دندان',          'HHD-004', 'box',    290, 4),
  ('Matches Pack',     'گوگرد',               'HHD-005', 'box',    120, 4)
) as t(name, name_fa, sku, unit, price, cat)
on conflict do nothing;

insert into customers (
  id, name, phone, address, driver_id, route_order, route_name,
  credit_limit, balance, is_active, is_deleted
)
select
  md5('seed-cust-' || n || '-' || i)::uuid,
  'Shop ' || lpad(n::text, 2, '0') || '-' || lpad(i::text, 2, '0'),
  '+93 70 ' || lpad((10000 + n * 100 + i)::text, 5, '0'),
  'Street ' || i || ', District ' || ((i % 4) + 1) || ', Kabul',
  md5('seed-driver-' || n)::uuid,
  ((i - 1) % 5) + 1,
  'Route ' || chr(65 + ((i - 1) / 5)::int),
  case when i % 3 = 0 then 50000 else 0 end,
  0, true, false
from generate_series(1, 12) n, generate_series(1, 15) i
on conflict (id) do nothing;

insert into truck_initial_stock (id, truck_id, product_id, quantity)
select
  md5('seed-stock-' || n || '-' || p.sku)::uuid,
  md5('seed-truck-' || n)::uuid,
  md5('seed-prod-' || p.sku)::uuid,
  50
from generate_series(1, 12) n,
     (select distinct sku from products where sku like 'BEV-%'
        or sku like 'SNK-%' or sku like 'DRY-%' or sku like 'HHD-%') p
on conflict (truck_id, product_id) do update set quantity = excluded.quantity;

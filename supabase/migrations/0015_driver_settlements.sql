create table if not exists driver_settlements (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references driver_profiles(id),
  amount numeric(12,2) not null constraint driver_settlements_amount_positive check (amount > 0),
  settled_date date not null default current_date,
  notes text,
  created_at timestamptz not null default now()
);

do $$
begin
  alter table driver_settlements
    add constraint driver_settlements_amount_positive check (amount > 0) not valid;
exception
  when duplicate_object then null;
end $$;

alter table driver_settlements enable row level security;

drop policy if exists "settlements_office_all" on driver_settlements;
create policy "settlements_office_all" on driver_settlements
  for all to authenticated
  using (public.is_office_or_admin())
  with check (public.is_office_or_admin());

drop policy if exists "settlements_driver_read_own" on driver_settlements;
create policy "settlements_driver_read_own" on driver_settlements
  for select to authenticated
  using (driver_id = auth.uid());

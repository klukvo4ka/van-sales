create table if not exists driver_locations (
  driver_id uuid primary key references driver_profiles(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  accuracy double precision,
  speed double precision,
  heading double precision,
  updated_at timestamptz not null default now()
);

alter table driver_locations enable row level security;

drop policy if exists "locations_driver_upsert_own" on driver_locations;
create policy "locations_driver_upsert_own" on driver_locations
  for insert to authenticated
  with check (driver_id = auth.uid());

drop policy if exists "locations_driver_update_own" on driver_locations;
create policy "locations_driver_update_own" on driver_locations
  for update to authenticated
  using (driver_id = auth.uid())
  with check (driver_id = auth.uid());

drop policy if exists "locations_driver_delete_own" on driver_locations;
create policy "locations_driver_delete_own" on driver_locations
  for delete to authenticated
  using (driver_id = auth.uid());

drop policy if exists "locations_read" on driver_locations;
create policy "locations_read" on driver_locations
  for select to authenticated
  using (driver_id = auth.uid() or public.is_office_or_admin());

do $$
begin
  alter publication supabase_realtime add table driver_locations;
exception
  when duplicate_object then null;
end $$;

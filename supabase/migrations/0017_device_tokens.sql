create table if not exists device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null default 'android',
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists device_tokens_user_id_idx
  on device_tokens(user_id);

alter table device_tokens enable row level security;

drop policy if exists "device_tokens_own" on device_tokens;
create policy "device_tokens_own" on device_tokens
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

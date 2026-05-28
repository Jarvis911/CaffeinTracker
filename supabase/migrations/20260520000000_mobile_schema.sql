-- Caffein Tracker — mobile backend (separate from web localStorage)
-- Run via: supabase db push  OR paste in Supabase SQL Editor

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.sugar_sensitivity as enum ('low', 'medium', 'high');
create type public.stress_level as enum ('low', 'medium', 'high');
create type public.fitness_provider as enum (
  'apple_health',
  'health_connect',
  'google_fit',
  'fitbit',
  'garmin',
  'samsung_health',
  'manual'
);
create type public.drink_category as enum ('coffee', 'tea', 'energy', 'soda', 'other');

-- ---------------------------------------------------------------------------
-- Profiles (1:1 with auth.users)
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default 'Friend',
  daily_caffeine_limit_mg int not null default 400 check (daily_caffeine_limit_mg between 50 and 800),
  sugar_sensitivity public.sugar_sensitivity not null default 'medium',
  preferred_drink_ids text[] not null default '{latte,matcha}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Drink catalog (shared reference data)
-- ---------------------------------------------------------------------------
create table public.drink_catalog (
  id text primary key,
  name text not null,
  emoji text not null,
  caffeine_mg int not null,
  sugar_g numeric(6, 1) not null,
  calories int not null,
  category public.drink_category not null
);

-- ---------------------------------------------------------------------------
-- Fitness connections per user
-- ---------------------------------------------------------------------------
create table public.fitness_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  provider public.fitness_provider not null,
  connected_at timestamptz not null default now(),
  last_synced_at timestamptz,
  metadata jsonb not null default '{}',
  unique (user_id, provider)
);

-- ---------------------------------------------------------------------------
-- Health snapshots (from device or manual)
-- ---------------------------------------------------------------------------
create table public.health_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  resting_heart_rate int not null check (resting_heart_rate between 30 and 220),
  sleep_hours numeric(4, 2) not null check (sleep_hours between 0 and 24),
  steps int not null default 0 check (steps >= 0),
  active_minutes int not null default 0 check (active_minutes >= 0),
  stress_level public.stress_level not null default 'medium',
  hydration_ml int not null default 0 check (hydration_ml >= 0),
  source public.fitness_provider not null,
  recorded_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index health_snapshots_user_recorded_idx
  on public.health_snapshots (user_id, recorded_at desc);

-- ---------------------------------------------------------------------------
-- Drink logs
-- ---------------------------------------------------------------------------
create table public.drink_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  drink_id text not null references public.drink_catalog (id),
  amount numeric(4, 2) not null default 1 check (amount > 0),
  logged_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index drink_logs_user_logged_idx
  on public.drink_logs (user_id, logged_at desc);

-- ---------------------------------------------------------------------------
-- Auto-create profile on signup
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', 'Friend')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- updated_at trigger
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Latest health snapshot helper (for mobile)
-- ---------------------------------------------------------------------------
create or replace function public.get_latest_health(p_user_id uuid)
returns public.health_snapshots
language sql
stable
security definer
set search_path = public
as $$
  select *
  from public.health_snapshots
  where user_id = p_user_id
  order by recorded_at desc
  limit 1;
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.drink_catalog enable row level security;
alter table public.fitness_connections enable row level security;
alter table public.health_snapshots enable row level security;
alter table public.drink_logs enable row level security;

-- profiles
create policy "Users read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- drink catalog (read-only for authenticated users)
create policy "Authenticated read drink catalog"
  on public.drink_catalog for select
  to authenticated
  using (true);

-- fitness_connections
create policy "Users manage own fitness connections"
  on public.fitness_connections for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- health_snapshots
create policy "Users manage own health snapshots"
  on public.health_snapshots for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- drink_logs
create policy "Users manage own drink logs"
  on public.drink_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Seed drink catalog
-- ---------------------------------------------------------------------------
insert into public.drink_catalog (id, name, emoji, caffeine_mg, sugar_g, calories, category) values
  ('espresso', 'Espresso', '☕', 63, 0, 3, 'coffee'),
  ('latte', 'Caffè Latte', '🥛', 75, 12, 190, 'coffee'),
  ('cold-brew', 'Cold Brew', '🧊', 155, 0, 5, 'coffee'),
  ('matcha', 'Matcha Latte', '🍵', 70, 14, 180, 'tea'),
  ('green-tea', 'Green Tea', '🫖', 28, 0, 2, 'tea'),
  ('energy', 'Energy Drink', '⚡', 160, 27, 110, 'energy'),
  ('cola', 'Cola', '🥤', 34, 39, 140, 'soda'),
  ('decaf', 'Decaf Coffee', '🌙', 4, 0, 2, 'coffee'),
  ('chai', 'Chai Latte', '🫚', 50, 42, 240, 'tea'),
  ('bubble-tea', 'Brown Sugar Boba', '🧋', 45, 50, 320, 'other')
on conflict (id) do nothing;

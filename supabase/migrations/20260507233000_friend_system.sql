create extension if not exists pgcrypto;

create schema if not exists private;

revoke all on schema private from public;
revoke all on schema private from anon;
revoke all on schema private from authenticated;

create or replace function public.normalize_username(value text)
returns text
language sql
immutable
as $$
  select trim(both '_' from regexp_replace(lower(coalesce(value, '')), '[^a-z0-9_.]+', '_', 'g'));
$$;

create or replace function public.build_unique_username(base_value text, user_id uuid)
returns text
language plpgsql
as $$
declare
  candidate text;
begin
  candidate := public.normalize_username(base_value);

  if candidate = '' then
    candidate := 'user_' || substr(replace(user_id::text, '-', ''), 1, 8);
  end if;

  if exists (
    select 1
    from public.profiles
    where username = candidate
      and id <> user_id
  ) then
    candidate := candidate || '_' || substr(replace(user_id::text, '-', ''), 1, 4);
  end if;

  return candidate;
end;
$$;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'full_name'
  ) then
    alter table public.profiles rename column full_name to display_name;
  end if;
end
$$;

alter table public.profiles
  add column if not exists display_name text,
  add column if not exists avatar_url text,
  add column if not exists is_private boolean not null default true,
  add column if not exists created_at timestamptz not null default now();

alter table public.profiles
  drop column if exists website,
  drop column if exists updated_at;

insert into public.profiles (id, username, display_name, avatar_url, is_private, created_at)
select
  users.id,
  public.build_unique_username(
    coalesce(
      users.raw_user_meta_data ->> 'username',
      split_part(users.email, '@', 1),
      users.id::text
    ),
    users.id
  ),
  coalesce(
    users.raw_user_meta_data ->> 'display_name',
    users.raw_user_meta_data ->> 'full_name'
  ),
  users.raw_user_meta_data ->> 'avatar_url',
  true,
  coalesce(users.created_at, now())
from auth.users as users
left join public.profiles as profiles on profiles.id = users.id
where profiles.id is null;

with normalized_profiles as (
  select
    profiles.id,
    case
      when coalesce(trim(profiles.username), '') = '' then public.build_unique_username(
        coalesce(
          profiles.display_name,
          users.raw_user_meta_data ->> 'username',
          split_part(users.email, '@', 1),
          profiles.id::text
        ),
        profiles.id
      )
      else public.normalize_username(profiles.username)
    end as candidate
  from public.profiles as profiles
  left join auth.users as users on users.id = profiles.id
),
deduplicated_profiles as (
  select
    id,
    candidate,
    row_number() over (partition by candidate order by id) as duplicate_rank
  from normalized_profiles
)
update public.profiles as profiles
set username = case
  when deduplicated_profiles.duplicate_rank = 1 then deduplicated_profiles.candidate
  else public.build_unique_username(deduplicated_profiles.candidate, profiles.id)
end
from deduplicated_profiles
where profiles.id = deduplicated_profiles.id;

alter table public.profiles
  alter column username set not null,
  alter column is_private set not null,
  alter column created_at set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'profiles_username_key'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles add constraint profiles_username_key unique (username);
  end if;
end
$$;

create or replace function private.handle_new_profile()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  insert into public.profiles (id, username, display_name, avatar_url, is_private, created_at)
  values (
    new.id,
    public.build_unique_username(
      coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1), new.id::text),
      new.id
    ),
    coalesce(new.raw_user_meta_data ->> 'display_name', new.raw_user_meta_data ->> 'full_name'),
    new.raw_user_meta_data ->> 'avatar_url',
    true,
    coalesce(new.created_at, now())
  )
  on conflict (id) do update
  set
    username = excluded.username,
    display_name = coalesce(public.profiles.display_name, excluded.display_name),
    avatar_url = coalesce(public.profiles.avatar_url, excluded.avatar_url);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure private.handle_new_profile();

alter table public.profiles enable row level security;

drop policy if exists "Public profiles are viewable by everyone." on public.profiles;
drop policy if exists "Users can insert their own profile." on public.profiles;
drop policy if exists "Users can update own profile." on public.profiles;
drop policy if exists profiles_select_own_or_accepted_friend on public.profiles;
drop policy if exists profiles_insert_own on public.profiles;
drop policy if exists profiles_update_own on public.profiles;

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null check (status in ('pending', 'accepted', 'declined')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

create unique index if not exists friendships_unique_pair_idx
on public.friendships (
  least(requester_id, addressee_id),
  greatest(requester_id, addressee_id)
);

create or replace function private.set_friendships_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists friendships_set_updated_at on public.friendships;

create trigger friendships_set_updated_at
  before update on public.friendships
  for each row execute procedure private.set_friendships_updated_at();

alter table public.friendships enable row level security;

drop policy if exists friendships_select_participants on public.friendships;
drop policy if exists friendships_insert_requester on public.friendships;
drop policy if exists friendships_update_addressee_pending on public.friendships;

create policy friendships_select_participants
on public.friendships
for select
to authenticated
using (auth.uid() in (requester_id, addressee_id));

create policy friendships_insert_requester
on public.friendships
for insert
to authenticated
with check (
  requester_id = auth.uid()
  and requester_id <> addressee_id
);

create policy friendships_update_addressee_pending
on public.friendships
for update
to authenticated
using (
  addressee_id = auth.uid()
  and status = 'pending'
)
with check (
  addressee_id = auth.uid()
  and status in ('accepted', 'declined')
);

create policy profiles_select_own_or_accepted_friend
on public.profiles
for select
to authenticated
using (
  auth.uid() = id
  or exists (
    select 1
    from public.friendships
    where status = 'accepted'
      and (
        (requester_id = auth.uid() and addressee_id = public.profiles.id)
        or (addressee_id = auth.uid() and requester_id = public.profiles.id)
      )
  )
);

create policy profiles_insert_own
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

create policy profiles_update_own
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop view if exists public.profile_search;

create view public.profile_search as
select
  id,
  username,
  display_name
from public.profiles;

grant usage on schema public to authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update on public.friendships to authenticated;
grant select on public.profile_search to authenticated;

revoke all on public.profile_search from anon;
revoke delete on public.friendships from authenticated;

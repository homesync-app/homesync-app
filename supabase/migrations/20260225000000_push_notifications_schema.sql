-- Migration: user_fcm_tokens
-- Description: Table to store FCM tokens for push notifications

create table if not exists public.user_fcm_tokens (
    id uuid default gen_random_uuid() primary key,
    user_id uuid references auth.users(id) on delete cascade not null,
    token text not null,
    platform text,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    unique(user_id, token)
);

-- Enable RLS
alter table public.user_fcm_tokens enable row level security;

-- Policies
do $$ 
begin
    if not exists (
        select 1 from pg_policies 
        where tablename = 'user_fcm_tokens' and policyname = 'Users can manage their own tokens'
    ) then
        create policy "Users can manage their own tokens"
            on public.user_fcm_tokens
            for all
            using (auth.uid() = user_id);
    end if;
end $$;

-- Migration: savings_goals
-- Description: Table to store savings goals for households

create table if not exists public.savings_goals (
    id uuid default gen_random_uuid() primary key,
    household_id uuid references public.households(id) on delete cascade not null,
    title text not null,
    target_amount decimal(12,2) not null,
    current_amount decimal(12,2) default 0.00,
    color text default '#FF7E67', -- Default primary color
    icon text default '💰',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Table for tracking individual contributions
create table if not exists public.savings_contributions (
    id uuid default gen_random_uuid() primary key,
    goal_id uuid references public.savings_goals(id) on delete cascade not null,
    user_id uuid references auth.users(id) on delete cascade not null,
    amount decimal(12,2) not null,
    note text,
    created_at timestamptz default now()
);

-- Enable RLS
alter table public.savings_goals enable row level security;
alter table public.savings_contributions enable row level security;

-- Policies for savings_goals
do $$ 
begin
    if not exists (
        select 1 from pg_policies 
        where tablename = 'savings_goals' and policyname = 'Members can view household goals'
    ) then
        create policy "Members can view household goals"
            on public.savings_goals
            for select
            using (
                exists (
                    select 1 from public.household_members
                    where household_id = savings_goals.household_id
                    and user_id = auth.uid()
                )
            );
    end if;

    if not exists (
        select 1 from pg_policies 
        where tablename = 'savings_goals' and policyname = 'Owners/Members can manage household goals'
    ) then
        create policy "Owners/Members can manage household goals"
            on public.savings_goals
            for all
            using (
                exists (
                    select 1 from public.household_members
                    where household_id = savings_goals.household_id
                    and user_id = auth.uid()
                )
            );
    end if;
end $$;

-- Policies for savings_contributions
do $$ 
begin
    if not exists (
        select 1 from pg_policies 
        where tablename = 'savings_contributions' and policyname = 'Members can view household contributions'
    ) then
        create policy "Members can view household contributions"
            on public.savings_contributions
            for select
            using (
                exists (
                    select 1 from public.savings_goals g
                    join public.household_members m on m.household_id = g.household_id
                    where g.id = goal_id and m.user_id = auth.uid()
                )
            );
    end if;

    if not exists (
        select 1 from pg_policies 
        where tablename = 'savings_contributions' and policyname = 'Users can add their own contributions'
    ) then
        create policy "Users can add their own contributions"
            on public.savings_contributions
            for insert
            with check (auth.uid() = user_id);
    end if;
end $$;

-- Trigger to update current_amount in goals
create or replace function public.update_goal_current_amount()
returns trigger as $$
begin
    if (TG_OP = 'INSERT') then
        update public.savings_goals
        set current_amount = current_amount + NEW.amount,
            updated_at = now()
        where id = NEW.goal_id;
    elsif (TG_OP = 'DELETE') then
        update public.savings_goals
        set current_amount = current_amount - OLD.amount,
            updated_at = now()
        where id = OLD.goal_id;
    end if;
    return null;
end;
$$ language plpgsql;

create trigger tr_update_goal_amount
after insert or delete on public.savings_contributions
for each row execute function public.update_goal_current_amount();

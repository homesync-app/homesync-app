-- Store attribution metadata for savings contributions.
--
-- `user_id` remains the member who registered the contribution. For shared
-- contributions, the client also stores the visible participants snapshot so
-- the savings history can say "A y B sumaron..." with both avatars instead of
-- looking like one person paid alone.
alter table public.savings_contributions
  add column if not exists split_type text not null default 'personal',
  add column if not exists participants jsonb not null default '[]'::jsonb;

comment on column public.savings_contributions.split_type is
  'Contribution attribution mode: personal, equal, fixed, or gift.';

comment on column public.savings_contributions.participants is
  'Snapshot array of participants for displaying shared savings contributions.';

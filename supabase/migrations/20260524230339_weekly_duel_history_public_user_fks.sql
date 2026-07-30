-- Reconstructed from remote migration history (version 20260524230339).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Firebase Third-Party Auth stores app identities in public.users.
-- Weekly duel history was still constrained against auth.users, which rejects
-- valid HomeSync user ids when saving the weekly result.

alter table public.weekly_duel_history
  drop constraint if exists weekly_duel_history_winner_user_id_fkey,
  drop constraint if exists weekly_duel_history_loser_user_id_fkey;

alter table public.weekly_duel_history
  add constraint weekly_duel_history_winner_user_id_fkey
    foreign key (winner_user_id)
    references public.users(id)
    on delete set null,
  add constraint weekly_duel_history_loser_user_id_fkey
    foreign key (loser_user_id)
    references public.users(id)
    on delete set null;

comment on constraint weekly_duel_history_winner_user_id_fkey
  on public.weekly_duel_history is
  'References public.users because HomeSync uses Firebase Auth bridged to app users.';

comment on constraint weekly_duel_history_loser_user_id_fkey
  on public.weekly_duel_history is
  'References public.users because HomeSync uses Firebase Auth bridged to app users.';

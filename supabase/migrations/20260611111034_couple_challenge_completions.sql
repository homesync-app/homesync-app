-- Registro de desafíos semanales de pareja completados.
-- Clave (household_id, week_index): week_index es el mismo
-- floor(días desde creación del hogar / 7) que usa el cliente para rotar
-- el desafío de la semana (sin módulo, así no se repite entre años).
create table public.couple_challenge_completions (
  household_id uuid not null references public.households(id) on delete cascade,
  week_index integer not null,
  challenge_id text not null,
  completed_by uuid not null,
  completed_at timestamptz not null default now(),
  primary key (household_id, week_index)
);

alter table public.couple_challenge_completions enable row level security;

create policy restrict_to_valid_jwt_couple_challenge_completions
  on public.couple_challenge_completions
  as restrictive for all
  using ((select is_supabase_or_firebase_project_jwt()) is true);

create policy "Members can view challenge completions"
  on public.couple_challenge_completions for select
  using (is_current_household_member(household_id));

create policy "Members can record challenge completions"
  on public.couple_challenge_completions for insert
  with check (is_current_household_member(household_id));

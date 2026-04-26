-- tabla para reportes de bugs y sugerencias de mejoras enviados desde la app
create table if not exists public.user_feedback (
  id          uuid primary key default gen_random_uuid(),
  user_id     text,                                          -- firebase uid (nullable para anonimos)
  email       text,
  type        text not null check (type in ('bug', 'suggestion')),
  title       text not null,
  description text,
  app_version text,
  platform    text,
  created_at  timestamptz not null default now()
);

alter table public.user_feedback enable row level security;

-- cualquier usuario autenticado puede insertar su propio feedback
create policy "authenticated users can insert feedback"
  on public.user_feedback
  for insert
  to authenticated
  with check (true);

-- solo el service role puede leer (admin dashboard via Supabase Studio o admin_workspace)
create policy "service role can read all feedback"
  on public.user_feedback
  for select
  using ( (select current_setting('role')) = 'service_role' );

-- índice para ordenar por fecha en el admin panel
create index user_feedback_created_at_idx on public.user_feedback (created_at desc);

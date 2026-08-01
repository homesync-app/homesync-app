-- Reconstructed from remote migration history (version 20260521121302).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

create table if not exists public.app_runtime_config (
  platform text primary key,
  min_build integer not null default 0,
  latest_build integer not null default 0,
  min_supported_sdk integer not null default 0,
  update_url text,
  update_title_es text not null default 'Actualizâ”œÃ­ HomeSync',
  update_message_es text not null default 'Para seguir usando la app necesitâ”œÃ­s instalar la versiâ”œâ”‚n mâ”œÃ­s reciente.',
  unsupported_title_es text not null default 'Dispositivo no compatible',
  unsupported_message_es text not null default 'Esta versiâ”œâ”‚n de Android ya no puede ejecutar HomeSync de forma segura.',
  update_title_en text not null default 'Update HomeSync',
  update_message_en text not null default 'To keep using the app, install the latest version.',
  unsupported_title_en text not null default 'Device not supported',
  unsupported_message_en text not null default 'This Android version can no longer run HomeSync safely.',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint app_runtime_config_platform_check
    check (platform in ('android', 'ios', 'web')),
  constraint app_runtime_config_builds_check
    check (min_build >= 0 and latest_build >= 0 and min_supported_sdk >= 0)
);

alter table public.app_runtime_config enable row level security;

drop policy if exists "App runtime config is publicly readable"
on public.app_runtime_config;

create policy "App runtime config is publicly readable"
on public.app_runtime_config
for select
to anon, authenticated
using (true);

grant select on public.app_runtime_config to anon, authenticated;
grant all on public.app_runtime_config to service_role;

insert into public.app_runtime_config (
  platform,
  min_build,
  latest_build,
  min_supported_sdk,
  update_url
)
values (
  'android',
  0,
  68,
  0,
  'https://play.google.com/store/apps/details?id=com.homesync.app'
)
on conflict (platform) do update set
  latest_build = greatest(public.app_runtime_config.latest_build, excluded.latest_build),
  update_url = coalesce(public.app_runtime_config.update_url, excluded.update_url),
  updated_at = now();

-- Install attribution: which channel or campaign brought each user.
--
-- The Android client reads the Play Install Referrer (utm_* params) and saves
-- it once per install through record_install_attribution_v1. It links ad
-- campaigns (Instagram, Meta Ads, WhatsApp invites) to what users do in the
-- app: household created, partner joined, retention, premium.
--
-- Access: no RLS policies, so clients cannot read or write the table
-- directly. The only write path is the SECURITY DEFINER RPC below, scoped to
-- current_app_user_id(). Reads are for service_role (growth reporting).

create table if not exists public.install_attributions (
  user_id uuid primary key references public.users(id) on delete cascade,
  utm_source text,
  utm_medium text,
  utm_campaign text,
  utm_content text,
  utm_term text,
  -- Kept whole: Meta app install ads send an encrypted JSON in utm_content
  -- that can be decrypted server-side later with the app's referrer key.
  raw_referrer text,
  platform text not null default 'android',
  app_version text,
  created_at timestamptz not null default now()
);

comment on table public.install_attributions is
  'First known install source per user (Play Install Referrer utm_*). Written only via record_install_attribution_v1.';

create index if not exists install_attributions_source_campaign_idx
  on public.install_attributions (utm_source, utm_campaign);

alter table public.install_attributions enable row level security;

revoke all on table public.install_attributions from public, anon, authenticated;

-- Record the caller's install attribution. First write wins: a second device
-- or a reinstall never overwrites where the user originally came from.
-- Returns true when a row was inserted.
create or replace function public.record_install_attribution_v1(
  p_source text default null,
  p_medium text default null,
  p_campaign text default null,
  p_content text default null,
  p_term text default null,
  p_raw_referrer text default null,
  p_platform text default 'android',
  p_app_version text default null
)
returns boolean
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_user_id uuid := public.current_app_user_id();
  v_inserted integer;
begin
  if v_user_id is null then
    raise exception 'Not authenticated' using errcode = '42501';
  end if;

  insert into public.install_attributions (
    user_id,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    raw_referrer,
    platform,
    app_version
  )
  values (
    v_user_id,
    nullif(left(btrim(p_source), 200), ''),
    nullif(left(btrim(p_medium), 200), ''),
    nullif(left(btrim(p_campaign), 200), ''),
    nullif(left(btrim(p_content), 2000), ''),
    nullif(left(btrim(p_term), 200), ''),
    nullif(left(btrim(p_raw_referrer), 4096), ''),
    coalesce(nullif(left(btrim(p_platform), 20), ''), 'android'),
    nullif(left(btrim(p_app_version), 40), '')
  )
  on conflict (user_id) do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted > 0;
end;
$function$;

revoke execute on function public.record_install_attribution_v1(
  text, text, text, text, text, text, text, text
) from public, anon;
grant execute on function public.record_install_attribution_v1(
  text, text, text, text, text, text, text, text
) to authenticated;

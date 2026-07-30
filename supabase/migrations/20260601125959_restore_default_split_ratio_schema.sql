-- Reconstruct an untracked remote column required by the following split-ratio
-- anchor migration. Existing hosted projects must mark this shim as applied.

alter table public.households
  add column if not exists default_split_ratio double precision
  not null default 0.5;

alter table public.households
  drop constraint if exists households_default_split_ratio_chk;
alter table public.households
  add constraint households_default_split_ratio_chk
  check (default_split_ratio >= 0 and default_split_ratio <= 1);

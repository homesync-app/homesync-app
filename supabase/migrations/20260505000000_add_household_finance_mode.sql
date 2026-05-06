-- Household finance mode: family defaults to shared finances; couple/friends can stay divided.

alter table public.households
  add column if not exists finance_mode text not null default 'divided';

alter table public.households
  drop constraint if exists households_finance_mode_chk;

alter table public.households
  add constraint households_finance_mode_chk
  check (finance_mode in ('shared', 'divided'));

alter table public.households
  alter column finance_mode set default 'shared';

alter table public.households disable trigger user;

update public.households
set finance_mode = 'shared'
where household_type = 'family';

alter table public.households enable trigger user;

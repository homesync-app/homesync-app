-- Isolated QA exercise, never persist test completions.
begin;
delete from public.couple_plan_progress where household_id='22222222-2222-2222-2222-222222222222';
select set_config('request.jwt.claims','{"iss":"https://securetoken.google.com/homesync-prod-r7-123","aud":"homesync-prod-r7-123","sub":"22220000-0000-0000-0000-000000000001","role":"authenticated"}',true);
set local role authenticated;
do $$
declare r jsonb; first_completed text;
begin
 r:=public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','movies','save');
 if r->>'saved'<>'true' or r->>'completed_at' is not null then raise exception 'Save changed completion'; end if;
 r:=public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','movies','complete');
 first_completed:=r->>'completed_at';
 if first_completed is null or r->>'saved'<>'true' then raise exception 'Complete lost saved state'; end if;
 r:=public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','movies','complete');
 if r->>'completed_at' is distinct from first_completed then raise exception 'Completion not idempotent'; end if;
 if (select count(*) from public.couple_plan_progress)<>1 then raise exception 'Duplicate stamp'; end if;
 r:=public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','movies','unsave');
 if r->>'completed_at' is distinct from first_completed or r->>'saved'<>'false' then raise exception 'Unsave lost completion'; end if;
 begin
   perform public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','unknown','complete');
   raise exception 'Unknown plan accepted';
 exception when invalid_parameter_value then null; end;
 begin
   perform public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','movies','approve');
   raise exception 'Approval accepted';
 exception when invalid_parameter_value then null; end;
 begin
   insert into public.couple_plan_progress(household_id,plan_id) values ('22222222-2222-2222-2222-222222222222','coffee');
   raise exception 'Direct write allowed';
 exception when insufficient_privilege then null; end;
end;
$$;
reset role;
select set_config('request.jwt.claims','{"iss":"https://securetoken.google.com/homesync-prod-r7-123","aud":"homesync-prod-r7-123","sub":"22220000-0000-0000-0000-000000000002","role":"authenticated"}',true);
set local role authenticated;
do $$
declare r jsonb;
begin
 if (select count(*) from public.couple_plan_progress where completed_at is not null)<>1 then raise exception 'Partner cannot see album'; end if;
 r:=public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','movies','undo');
 if r->>'completed_at' is not null then raise exception 'Partner cannot undo'; end if;
 r:=public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','coffee','save');
 if r->>'saved'<>'true' then raise exception 'Partner cannot save'; end if;
end;
$$;
reset role;
select set_config('request.jwt.claims','{"iss":"https://securetoken.google.com/homesync-prod-r7-123","aud":"homesync-prod-r7-123","sub":"11110000-0000-0000-0000-000000000001","role":"authenticated"}',true);
set local role authenticated;
do $$
begin
 if exists(select 1 from public.couple_plan_progress where household_id='22222222-2222-2222-2222-222222222222') then raise exception 'Cross-household read'; end if;
 begin
   perform public.couple_plan_action_v1('22222222-2222-2222-2222-222222222222','movies','complete');
   raise exception 'Cross-household write';
 exception when insufficient_privilege then null; end;
 begin
   perform public.couple_plan_action_v1('11111111-1111-1111-1111-111111111111','movies','complete');
   raise exception 'Solo household accepted';
 exception when insufficient_privilege then null; end;
end;
$$;
reset role;
do $$
begin
 if has_function_privilege('anon','public.couple_plan_action_v1(uuid,text,text)','execute')
   or has_table_privilege('anon','public.couple_plan_progress','select') then raise exception 'Anonymous access'; end if;
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='couple_plan_progress') then raise exception 'Realtime missing'; end if;
end;
$$;
select 'PASS: save, complete, idempotence, unsave, undo, partner, invalid actions, household isolation, anonymous denial, realtime' as result;
rollback;

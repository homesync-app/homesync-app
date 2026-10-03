-- Run in a transaction that is ALWAYS rolled back. QA fixtures only.
-- Covers the AGENTS.md six-flow checklist before/after the isolated migration.
begin;
create temporary table couple_smoke_tasks(kind text primary key, id uuid not null);
insert into couple_smoke_tasks values ('normal',gen_random_uuid()),('recurring',gen_random_uuid()),('approval',gen_random_uuid());
grant select on couple_smoke_tasks to authenticated;
-- Exercise the approval branch regardless of the QA household's saved setting.
update public.households set plan_tier='group_premium', premium_until=now()+interval '1 day', task_approval_mode='children_only'
where id='44444444-4444-4444-4444-444444444444';

insert into public.tasks(id,household_id,created_by_id,assigned_to,title,type,status,due_at,recurrence_type)
select id, '22222222-2222-2222-2222-222222222222',
 '22220000-0000-0000-0000-000000000001','22220000-0000-0000-0000-000000000001',
 'QA couple plans '||kind||' '||id::text,case when kind='recurring' then 'recurring' else 'one_time' end,
 'active',now(),case when kind='recurring' then 'daily' end
from couple_smoke_tasks where kind<>'approval';
insert into public.tasks(id,household_id,created_by_id,assigned_to,title,type,status,due_at)
select id,'44444444-4444-4444-4444-444444444444',
 '44440000-0000-0000-0000-000000000001','44440000-0000-0000-0000-000000000003',
 'QA couple plans approval regression','one_time','active',now()
from couple_smoke_tasks where kind='approval';

select set_config('request.jwt.claims',jsonb_build_object(
 'sub',coalesce(firebase_uid,id::text),'role','authenticated',
 'iss','https://securetoken.google.com/homesync-prod-r7-123','aud','homesync-prod-r7-123')::text,true)
from public.users where id='22220000-0000-0000-0000-000000000001';
set local role authenticated;
do $$
declare r jsonb; task record;
begin
 for task in select * from couple_smoke_tasks where kind<>'approval' loop
   r := public.complete_task_v1(gen_random_uuid()::text,
     array['22220000-0000-0000-0000-000000000001'::uuid],task.id,
     '22222222-2222-2222-2222-222222222222',0,0,'QA',now());
   if r->>'success' is distinct from 'true' then raise exception 'Completion % failed: %',task.kind,r; end if;
 end loop;
 perform public.get_combined_feed('22222222-2222-2222-2222-222222222222',20,0);
 perform public.upsert_catalog_request('QA couple plans rollback '||gen_random_uuid()::text,'test');
 insert into public.user_feedback(user_id,type,title,description,platform,wants_email_response)
 values ('22220000-0000-0000-0000-000000000001','suggestion','QA rollback only','Couple plans smoke','unknown',false);
end;
$$;
reset role;

select set_config('request.jwt.claims',jsonb_build_object(
 'sub',coalesce(firebase_uid,id::text),'role','authenticated',
 'iss','https://securetoken.google.com/homesync-prod-r7-123','aud','homesync-prod-r7-123')::text,true)
from public.users where id='44440000-0000-0000-0000-000000000003';
set local role authenticated;
do $$
declare r jsonb;
begin
 r := public.complete_task_v1(gen_random_uuid()::text,
   array['44440000-0000-0000-0000-000000000003'::uuid],
   (select id from couple_smoke_tasks where kind='approval'),
   '44444444-4444-4444-4444-444444444444',0,0,'QA',now());
 if r->>'success' is distinct from 'true' then raise exception 'Pending completion failed: %',r; end if;
end;
$$;
reset role;
select set_config('request.jwt.claims',jsonb_build_object(
 'sub',coalesce(firebase_uid,id::text),'role','authenticated',
 'iss','https://securetoken.google.com/homesync-prod-r7-123','aud','homesync-prod-r7-123')::text,true)
from public.users where id='44440000-0000-0000-0000-000000000001';
set local role authenticated;
do $$
declare r jsonb;
begin
 r := public.approve_task_v1(gen_random_uuid()::text,'44440000-0000-0000-0000-000000000001',
   (select id from couple_smoke_tasks where kind='approval'),
   '44440000-0000-0000-0000-000000000001',null);
 if r->>'success' is distinct from 'true' then raise exception 'Approval failed: %',r; end if;
end;
$$;
reset role;
select 'PASS: normal task, recurring task, pending approval, feedback, shopping request, finance feed' as result;
rollback;

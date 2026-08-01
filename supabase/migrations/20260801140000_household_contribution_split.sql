-- The honest split view, and the rhythm that replaces the duel.
--
-- Phases 4 and 6 of docs/couple-shared-fund-plan.md. Taking the per-person
-- breakdown out of the fund was only defensible if the imbalance shows up
-- somewhere else, so this is its counterpart: who did what, how many, of what
-- kind, and which categories keep landing on the same person.
--
-- Framing rules this function is built to respect:
--   * The reading is "the kitchen ones landed on the same side this week",
--     which is actionable, rather than a score, which is a judgement.
--   * No winner, no ranking, no crown. Members come back in join order, not
--     sorted by who did more.
--   * Rhythm is active weeks inside a window, never a consecutive streak. A
--     streak punishes exactly the weeks a couple needs slack -- illness, a
--     trip, a move -- so a quiet week lowers the rhythm without breaking it.
--
-- On "tasks and time": there is no duration anywhere on public.tasks, so this
-- deliberately does not report minutes. Inventing them would be fabricating
-- data. It reports how many of the demanding tasks (difficulty big/heavy) each
-- person took instead, which is the load proxy the app already shows users as
-- "how demanding it is".

create or replace function public.get_household_contribution_v1(
  p_household_id uuid
) returns jsonb
language plpgsql
stable
security definer
set search_path to 'public'
as $function$
declare
  v_week_start timestamptz := date_trunc('week', now());
  v_week_end timestamptz := date_trunc('week', now()) + interval '7 days';
  v_total integer := 0;
  v_members jsonb := '[]'::jsonb;
  v_categories jsonb := '[]'::jsonb;
  v_rhythm integer := 0;
begin
  if not public.is_current_household_member(p_household_id) then
    raise exception 'Household access denied' using errcode = '42501';
  end if;

  select count(*)
    into v_total
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.event_type = 'task_completed'
    and coalesce((ha.metadata ->> 'is_couple_challenge')::boolean, false) is false
    and ha.created_at >= v_week_start
    and ha.created_at < v_week_end;

  -- Join order, never "who did more": this view is a photo to talk about, not
  -- a leaderboard.
  select coalesce(
    jsonb_agg(to_jsonb(row_data) order by row_data.joined_at),
    '[]'::jsonb
  )
    into v_members
  from (
    select
      hm.user_id,
      coalesce(u.full_name, split_part(u.email, '@', 1), 'Miembro') as name,
      u.avatar_url,
      hm.joined_at,
      count(ha.id)::integer as tasks_done,
      count(ha.id) filter (
        where lower(coalesce(t.difficulty, '')) in ('big', 'heavy')
      )::integer as demanding_done
    from public.household_members hm
    join public.users u on u.id = hm.user_id
    left join public.household_activities ha
      on ha.household_id = hm.household_id
     and ha.user_id = hm.user_id
     and ha.event_type = 'task_completed'
     and coalesce((ha.metadata ->> 'is_couple_challenge')::boolean, false)
           is false
     and ha.created_at >= v_week_start
     and ha.created_at < v_week_end
    left join public.tasks t
      on t.id = nullif(ha.metadata ->> 'task_id', '')::uuid
    where hm.household_id = p_household_id
    group by hm.user_id, u.full_name, u.email, u.avatar_url, hm.joined_at
  ) row_data;

  -- A category counts as skewed when one person took at least three quarters
  -- of it and there were enough of them for the pattern to mean anything.
  -- Below that it is noise, and flagging noise would turn a conversation
  -- starter into nagging.
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'category', c.category,
        'total', c.total,
        'dominant_user_id', c.dominant_user_id,
        'dominant_name', c.dominant_name,
        'dominant_count', c.dominant_count,
        'skewed', c.total >= 3 and c.dominant_count::numeric / c.total >= 0.75
      )
      order by c.total desc, c.category
    ),
    '[]'::jsonb
  )
    into v_categories
  from (
    select
      per_cat.category,
      sum(per_cat.count)::integer as total,
      (array_agg(
        per_cat.user_id order by per_cat.count desc, per_cat.user_id
      ))[1] as dominant_user_id,
      (array_agg(
        per_cat.name order by per_cat.count desc, per_cat.user_id
      ))[1] as dominant_name,
      max(per_cat.count)::integer as dominant_count
    from (
      select
        coalesce(nullif(ha.metadata ->> 'category', ''), 'otros') as category,
        ha.user_id,
        coalesce(u.full_name, split_part(u.email, '@', 1), 'Miembro') as name,
        count(*)::integer as count
      from public.household_activities ha
      join public.users u on u.id = ha.user_id
      where ha.household_id = p_household_id
        and ha.event_type = 'task_completed'
        and coalesce((ha.metadata ->> 'is_couple_challenge')::boolean, false)
              is false
        and ha.created_at >= v_week_start
        and ha.created_at < v_week_end
      group by 1, 2, 3
    ) per_cat
    group by per_cat.category
  ) c;

  select count(distinct date_trunc('week', ha.created_at))
    into v_rhythm
  from public.household_activities ha
  where ha.household_id = p_household_id
    and ha.event_type = 'task_completed'
    and ha.created_at >= v_week_start - interval '3 weeks'
    and ha.created_at < v_week_end;

  return jsonb_build_object(
    'household_id', p_household_id,
    'week_start', v_week_start,
    'week_end', v_week_end,
    'total_tasks', v_total,
    'rhythm_weeks', coalesce(v_rhythm, 0),
    'rhythm_window', 4,
    'members', v_members,
    'categories', v_categories
  );
end;
$function$;

revoke execute on function public.get_household_contribution_v1(uuid)
  from public, anon;
grant execute on function public.get_household_contribution_v1(uuid)
  to authenticated;

notify pgrst, 'reload schema';

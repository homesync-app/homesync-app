import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the invariants of the shared fund that live in SQL, so a later edit
/// to the migration cannot quietly undo them.
void main() {
  late String fund;
  late String xp;
  late String split;

  setUpAll(() {
    fund = File(
      '../supabase/migrations/20260801130000_couple_shared_fund.sql',
    ).readAsStringSync();
    xp = File(
      '../supabase/migrations/20260801120000_restore_couple_personal_xp.sql',
    ).readAsStringSync();
    split = File(
      '../supabase/migrations/20260801140000_household_contribution_split.sql',
    ).readAsStringSync();
  });

  test('one task feeds the household once, whoever completed it', () {
    expect(
      fund,
      contains('unique (household_id, source_type, source_id)'),
    );
    expect(
      fund,
      contains('on conflict (household_id, source_type, source_id) do nothing'),
    );
  });

  test('there is no publicly callable way to add to the fund', () {
    // Section 6 of the plan: a free-standing add_to_household_fund RPC would be
    // the same hole as trusting client-sent rewards. The name appears in the
    // rationale comment, so this matches a definition rather than the prose.
    final definesFundRpc = RegExp(
      r'create\s+(or\s+replace\s+)?function\s+public\.add_to_household_fund',
    );
    expect(fund, isNot(matches(definesFundRpc)));
    // Newline-agnostic: the checkout may carry CRLF.
    expect(
      fund.replaceAll(RegExp(r'\s+'), ' '),
      contains(
        'revoke execute on function '
        'public.accrue_couple_fund_on_activity() '
        'from public, anon, authenticated;',
      ),
    );
    // The amount comes from the task row, never from the caller.
    expect(fund, contains('from public.tasks t'));
    expect(
      fund,
      contains('least(greatest(coalesce(t.xp_reward, 0), 0), 50)'),
    );
  });

  test('only one goal can be open at a time, ready included', () {
    expect(
      fund,
      contains("where status in ('active', 'ready')"),
    );
  });

  test('the unlock needs every member and cannot double spend', () {
    expect(fund, contains('if v_confirmations >= greatest(v_members, 1) then'));
    expect(fund, contains("'goal_unlock'"));
    expect(fund, contains('The fund no longer covers this goal'));
  });

  test('reaching a goal opens a proposal instead of buying the plan', () {
    expect(fund, contains('insert into public.couple_proposals'));
    expect(fund, contains("'fund_goal'"));
  });

  test('changing the goal never spends the fund', () {
    expect(fund, contains("set status = 'cancelled'"));
  });

  test('the split view names a pattern instead of scoring anyone', () {
    // Skew needs a big enough sample; flagging noise turns a conversation
    // starter into nagging.
    expect(
      split,
      contains('c.total >= 3 and c.dominant_count::numeric / c.total >= 0.75'),
    );
    // Join order, never "who did more".
    expect(split, contains('order by row_data.joined_at'));
    expect(split, isNot(contains('weekly_winners')));
  });

  test('rhythm is a window of active weeks, never a consecutive streak', () {
    expect(split, contains("count(distinct date_trunc('week', ha.created_at))"));
    expect(split, contains("interval '3 weeks'"));
    expect(split, contains("'rhythm_window', 4"));
  });

  test('couple keeps personal XP and loses only the coin economy', () {
    expect(xp, contains("if new.currency = 'COIN'"));
    expect(xp, isNot(contains("new.currency in ('XP', 'COIN')")));
    expect(
      xp,
      contains(
        'new.xp_reward := least(greatest(coalesce(new.xp_reward, 0), 0), 50);',
      ),
    );
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String migration;

  setUpAll(() {
    migration = File(
      '../supabase/migrations/20260726120000_couple_connection_space.sql',
    ).readAsStringSync();
  });

  test('task completion ignores caller-provided rewards', () {
    expect(
      migration,
      contains('Rewards are server-authoritative in every household mode.'),
    );
    expect(migration, contains("'xp_earned', v_xp_reward"));
    expect(migration, contains("'coins_earned', v_coin_reward"));
    expect(migration, isNot(contains("'xp_earned', p_xp_reward")));
    expect(migration, isNot(contains("'coins_earned', p_coin_reward")));
  });

  test('task rewards are bounded and couple rewards stay at zero', () {
    expect(migration, contains('new.xp_reward := 0;'));
    expect(migration, contains('new.coin_reward := 0;'));
    expect(
      migration,
      contains(
        'new.xp_reward := least(greatest(coalesce(new.xp_reward, 0), 0), 50);',
      ),
    );
    expect(
      migration,
      contains(
        'new.coin_reward := least(greatest(coalesce(new.coin_reward, 0), 0), 5);',
      ),
    );
  });

  test('proposal deferral and adult family reward management are persisted',
      () {
    expect(migration, contains("'pending', 'accepted', 'deferred'"));
    expect(migration, contains('private.can_manage_family_rewards'));
    expect(
      migration,
      contains('create policy "Adult family admins can insert rewards"'),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/rewards/presentation/screens/couple_rewards_screen.dart';

class CoupleSpaceScreen extends ConsumerWidget {
  const CoupleSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdId = ref.watch(householdIdProvider).value;
    if (householdId == null || householdId.isEmpty) {
      return const SizedBox.shrink();
    }

    return CoupleRewardsScreen(
      key: ValueKey<String>('couple_rewards_$householdId'),
      householdId: householdId,
    );
  }
}

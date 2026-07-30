import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/screens/couple_connection_screen.dart';

class CoupleSpaceScreen extends ConsumerWidget {
  const CoupleSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdId = ref.watch(householdIdProvider).value;
    if (householdId == null || householdId.isEmpty) {
      return const SizedBox.shrink();
    }

    return CoupleConnectionScreen(
      key: ValueKey<String>('couple_connection_$householdId'),
      householdId: householdId,
    );
  }
}

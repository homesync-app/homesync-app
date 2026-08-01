import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/screens/couple_connection_screen.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

class CoupleSpaceScreen extends ConsumerWidget {
  const CoupleSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdIdAsync = ref.watch(householdIdProvider);
    final t = AppLocalizations.of(context);

    return householdIdAsync.when(
      skipLoadingOnReload: true,
      loading: () => const AppLoadingState(),
      error: (_, __) => AppErrorState(
        message: t.coupleSpaceLoadError,
        onRetry: () => ref.invalidate(householdIdProvider),
      ),
      data: (householdId) {
        if (householdId == null || householdId.isEmpty) {
          return AppErrorState(
            message: t.coupleSpaceLoadError,
            onRetry: () => ref.invalidate(householdIdProvider),
          );
        }

        return CoupleConnectionScreen(
          key: ValueKey<String>('couple_connection_$householdId'),
          householdId: householdId,
        );
      },
    );
  }
}

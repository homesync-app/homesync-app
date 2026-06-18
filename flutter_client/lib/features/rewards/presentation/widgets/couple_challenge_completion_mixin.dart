import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/domain/models/couple_challenge.dart';
import 'package:homesync_client/features/rewards/presentation/providers/couple_challenge_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';

/// Flujo compartido para completar el desafío semanal de pareja.
///
/// Antes estaba copiado y pegado en `couple_rewards_screen` y `rewards_screen`
/// — por eso el bug del FK de categoría existía (y había que arreglarlo) dos
/// veces. Vive una sola vez acá: confirmación → RPC atómico
/// (`complete_couple_challenge_v1`) → celebración → manejo de error/duplicado.
mixin CoupleChallengeCompletionMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<void> handleCoupleChallengeCompletion(
    CoupleChallenge challenge,
    String householdId,
    int weekIndex,
  ) async {
    final t = AppLocalizations.of(context);

    // Guardia contra carreras (doble tap / el otro miembro lo completó y la
    // card todavía no se refrescó). El servidor también es idempotente, pero
    // así evitamos abrir el diálogo de confirmación para nada.
    final alreadyDone = ref
            .read(
              coupleChallengeCompletedProvider(
                (householdId: householdId, weekIndex: weekIndex),
              ),
            )
            .value ??
        false;
    if (alreadyDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.coupleChallengeAlreadyDone)),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(t.rewardsChallengeCompletePrompt),
        content: Text(t.rewardsChallengeCompleteBody(challenge.coinReward)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              t.rewardsNotYet,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: Text(t.rewardsYesWeDid),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    await _execute(challenge, householdId, weekIndex);
  }

  Future<void> _execute(
    CoupleChallenge challenge,
    String householdId,
    int weekIndex,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: AppLoader()),
    );

    final t = AppLocalizations.of(context);
    try {
      final members = ref.read(householdMembersProvider).value ?? const [];
      final userIds = members.map((m) => m.userId).toList();
      final currentUserId = ref.read(currentUserIdProvider);
      if (userIds.isEmpty && currentUserId != null) {
        userIds.add(currentUserId);
      }

      final title = t.rewardsChallengeTitle(challenge.localizedTitle(t));

      final outcome = await completeCoupleChallenge(
        ref,
        householdId: householdId,
        weekIndex: weekIndex,
        challengeId: challenge.id,
        userIds: userIds,
        completedBy: currentUserId ?? userIds.first,
        coinReward: challenge.coinReward,
        xpReward: 10,
        title: title,
        description: challenge.localizedDescription(t),
      );

      if (!mounted) return;
      Navigator.pop(context); // cerrar loader

      switch (outcome) {
        case CoupleChallengeOutcome.completed:
          SuccessCelebration.show(
            context,
            title: t.rewardsChallengeCompleted,
            message: t.rewardsChallengeCompletedBody(challenge.coinReward),
            icon: '✨',
          );
          ref.invalidate(userBalanceProvider);
          ref.invalidate(tasksProvider);
        case CoupleChallengeOutcome.alreadyCompleted:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.coupleChallengeAlreadyDone)),
          );
        case CoupleChallengeOutcome.failed:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.rewardsChallengeError('')),
              backgroundColor: AppColors.error,
            ),
          );
      }
    } catch (e, stack) {
      log.e('Couple challenge completion failed', error: e, stackTrace: stack);
      if (!mounted) return;
      Navigator.pop(context); // cerrar loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.rewardsChallengeError(friendlyErrorMessage(e))),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

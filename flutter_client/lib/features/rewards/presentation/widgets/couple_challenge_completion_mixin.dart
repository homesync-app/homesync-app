import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/rewards/domain/models/couple_challenge.dart';
import 'package:homesync_client/features/rewards/presentation/providers/couple_challenge_provider.dart';
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
  Future<CoupleChallengeOutcome?> handleCoupleChallengeCompletion(
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
      return CoupleChallengeOutcome.alreadyCompleted;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(t.rewardsChallengeCompletePrompt),
        content: Text(t.coupleSpaceSpecialConfirmBody),
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

    if (confirm != true) return null;
    if (!mounted) return null;

    return _execute(challenge, householdId, weekIndex);
  }

  Future<CoupleChallengeOutcome?> _execute(
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
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) {
        throw StateError('Missing current app user');
      }

      final title = t.rewardsChallengeTitle(challenge.localizedTitle(t));

      final outcome = await completeCoupleChallenge(
        ref,
        householdId: householdId,
        weekIndex: weekIndex,
        challengeId: challenge.id,
        completedBy: currentUserId,
        title: title,
        description: challenge.localizedDescription(t),
      );

      if (!mounted) return null;
      Navigator.pop(context); // cerrar loader

      switch (outcome) {
        case CoupleChallengeOutcome.completed:
          SuccessCelebration.show(
            context,
            title: t.coupleSpaceSpecialCompletedTitle,
            message: t.coupleSpaceSpecialCompletedBody,
            icon: '💚',
          );
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
      return outcome;
    } catch (e, stack) {
      log.e('Couple challenge completion failed', error: e, stackTrace: stack);
      if (!mounted) return null;
      Navigator.pop(context); // cerrar loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.rewardsChallengeError(friendlyErrorMessage(e, t: t))),
          backgroundColor: AppColors.error,
        ),
      );
      return null;
    }
  }
}

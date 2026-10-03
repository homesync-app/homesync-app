import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/domain/couple_week_reading.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_art.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Una persona del reparto, con lo que hizo en la semana.
class CoupleSplitPerson extends CouplePerson {
  final int tasksDone;
  final int demandingDone;

  const CoupleSplitPerson({
    required super.userId,
    required super.label,
    required super.avatarName,
    required super.avatarUrl,
    required this.tasksDone,
    required this.demandingDone,
  });
}

/// El bloque principal de la pestaña: los dos, uno al lado del otro, con lo
/// que hizo cada uno en la semana y una sola lectura accionable.
///
/// Nunca hay ganador: las dos mascotas tienen el mismo tamaño, entre ellas va
/// un corazón; las fichas muestran tareas sin convertirlas en un marcador. La
/// lectura queda debajo de ambos, sin atribuirle palabras a una persona.
class CoupleSplitCard extends StatelessWidget {
  final HouseholdContribution contribution;
  final CoupleSplitPerson me;
  final CoupleSplitPerson partner;
  final CoupleWeekReading reading;

  /// "Semana del 21 de septiembre", ya localizado.
  final String weekLabel;

  /// Nombre de la categoría ya localizado (solo para lecturas por categoría).
  final String? categoryLabel;

  /// Null mientras el resumen de la semana no llegó: mejor no mostrar nada
  /// que un "no queda nada" falso.
  final int? tasksRemaining;
  final int overdue;
  final VoidCallback onSeeTasks;

  const CoupleSplitCard({
    super.key,
    required this.contribution,
    required this.me,
    required this.partner,
    required this.reading,
    required this.weekLabel,
    required this.categoryLabel,
    required this.tasksRemaining,
    required this.overdue,
    required this.onSeeTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final total = me.tasksDone + partner.tasksDone;
    final showDemanding = me.demandingDone > 0 || partner.demandingDone > 0;

    return CoupleSurface(
      radius: AppRadii.xxl,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Color.alphaBlend(
        AppColors.accentPeach.withValues(alpha: theme.isDarkMode ? 0.12 : 0.13),
        theme.surface,
      ),
      borderColor: AppColors.accentPeach.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.coupleWeekDuoTitle,
            textAlign: TextAlign.center,
            style:
                AppTypography.sectionTitle.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            weekLabel,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DuoScene(me: me, partner: partner, showDemanding: showDemanding),
          const SizedBox(height: AppSpacing.sm),
          _ReadingBubble(
            reading: reading,
            totalTasks: total,
            partnerLabel: partner.label,
            categoryLabel: categoryLabel,
            onSeeTasks: onSeeTasks,
          ),
          if (tasksRemaining != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              overdue > 0
                  ? '${t.coupleWeekRemaining(tasksRemaining!)} · '
                      '${t.coupleWeekOverdue(overdue)}'
                  : t.coupleWeekRemaining(tasksRemaining!),
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: theme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Both avatars share one heart-shaped backdrop. Stats move below the scene
/// on small screens or with enlarged text; neither person is visually ranked.
class _DuoScene extends StatelessWidget {
  final CoupleSplitPerson me;
  final CoupleSplitPerson partner;
  final bool showDemanding;

  const _DuoScene({
    required this.me,
    required this.partner,
    required this.showDemanding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final scene = ExcludeSemantics(
      child: SizedBox(
        width: 172,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 166,
              color: AppColors.accentRed
                  .withValues(alpha: theme.isDarkMode ? 0.13 : 0.09),
            ),
            const Positioned(
              top: 2,
              child: Icon(
                Icons.favorite_rounded,
                size: 22,
                color: AppColors.accentOrange,
              ),
            ),
            Positioned(left: 0, bottom: 0, child: _avatar(me)),
            Positioned(right: 0, bottom: 0, child: _avatar(partner)),
          ],
        ),
      ),
    );
    return Column(
      children: [
        scene,
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DuoMember(
                person: me,
                showDemanding: showDemanding,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _DuoMember(
                person: partner,
                showDemanding: showDemanding,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _avatar(CouplePerson person) => CustomUserAvatar(
        name: person.avatarName,
        userId: person.userId,
        avatarUrl: person.avatarUrl,
        radius: 27,
        showBorder: true,
      );
}

class _DuoMember extends StatelessWidget {
  final CoupleSplitPerson person;
  final bool showDemanding;

  const _DuoMember({
    required this.person,
    required this.showDemanding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          person.label,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          t.contributionTasksLabel(person.tasksDone),
          textAlign: TextAlign.center,
          style: AppTypography.cardTitle.copyWith(
            color: theme.textPrimary,
            fontFeatures: kTabularFigures,
          ),
        ),
        if (showDemanding) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            t.contributionDemandingLabel(person.demandingDone),
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: theme.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// La lectura de la semana como un globito de diálogo, con su acción.
class _ReadingBubble extends StatelessWidget {
  final CoupleWeekReading reading;
  final int totalTasks;
  final String partnerLabel;
  final String? categoryLabel;
  final VoidCallback onSeeTasks;

  const _ReadingBubble({
    required this.reading,
    required this.totalTasks,
    required this.partnerLabel,
    required this.categoryLabel,
    required this.onSeeTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final category = categoryLabel ?? '';
    final text = switch (reading.kind) {
      CoupleWeekReadingKind.empty => t.contributionEmpty,
      CoupleWeekReadingKind.early => t.coupleWeekReadingEarly(totalTasks),
      CoupleWeekReadingKind.balanced => t.coupleWeekReadingBalanced,
      CoupleWeekReadingKind.categorySkew => reading.leaderIsMe
          ? t.coupleWeekReadingCategoryMe(category)
          : t.coupleWeekReadingCategoryPartner(category, partnerLabel),
      CoupleWeekReadingKind.overallSkew => reading.leaderIsMe
          ? t.coupleWeekReadingOverallMe
          : t.coupleWeekReadingOverallPartner(partnerLabel),
    };

    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: theme.textSecondary),
        ),
        TextButton.icon(
          onPressed: onSeeTasks,
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: Text(t.coupleWeekSeeTasks),
        ),
      ],
    );
  }
}

/// Esqueleto del bloque principal mientras llega el reparto.
class CoupleSplitCardSkeleton extends StatelessWidget {
  const CoupleSplitCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      variant: AppCardVariant.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 120, height: 11, borderRadius: AppRadii.xs),
          SizedBox(height: AppSpacing.xs),
          ShimmerLoading(width: 190, height: 20, borderRadius: AppRadii.xs),
          SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ShimmerLoading(width: 72, height: 72, borderRadius: 36),
              ShimmerLoading(width: 72, height: 72, borderRadius: 36),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ShimmerLoading(height: 12, borderRadius: AppRadii.pill),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(height: 56, borderRadius: AppRadii.lg),
        ],
      ),
    );
  }
}

/// Tarjeta para escribirle una nota a la pareja: un sobrecito, como el que
/// le aparece en el inicio.
class CoupleNoteRow extends StatelessWidget {
  final String partnerLabel;
  final VoidCallback onTap;

  const CoupleNoteRow({
    super.key,
    required this.partnerLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return CoupleSurface(
      color: Color.alphaBlend(
        AppColors.accentRed.withValues(alpha: 0.07),
        theme.surface,
      ),
      borderColor: AppColors.accentRed.withValues(alpha: 0.16),
      padding: AppInsets.compactCard,
      onTap: onTap,
      child: Row(
        children: [
          const CoupleArt(kind: CoupleArtKind.letter, size: 56),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.coupleWeekNoteTitle(partnerLabel),
                  style: AppTypography.cardTitle.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.coupleWeekNoteBody,
                  style: AppTypography.caption.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.textSecondary),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// El reparto de la semana, en el lugar donde antes estaba el duelo.
///
/// Reemplaza el marco competitivo por dos cosas: el ritmo del hogar contra su
/// propio pasado, y una foto honesta de quién hizo qué. Sin corona, sin
/// ganador, sin posiciones — los miembros salen en orden de ingreso y la única
/// lectura que se destaca es la que se puede accionar.
class ContributionSplitCard extends StatelessWidget {
  final HouseholdContribution contribution;

  const ContributionSplitCard({super.key, required this.contribution});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.contributionEyebrow,
            style: AppTypography.eyebrow.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            t.contributionTitle,
            style: AppTypography.cardTitle.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _Rhythm(contribution: contribution),
          const SizedBox(height: AppSpacing.lg),
          if (contribution.isEmpty)
            Text(
              t.contributionEmpty,
              style: AppTypography.body.copyWith(color: theme.textSecondary),
            )
          else ...[
            for (final member in contribution.members) ...[
              _MemberRow(
                member: member,
                share: contribution.shareOf(member),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _Reading(contribution: contribution),
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.contributionNoDurationNote,
              style: AppTypography.caption.copyWith(
                color: theme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Rhythm extends StatelessWidget {
  final HouseholdContribution contribution;

  const _Rhythm({required this.contribution});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.contributionRhythmLabel,
                style: AppTypography.caption.copyWith(
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                t.contributionRhythmValue(
                  contribution.rhythmWeeks,
                  contribution.rhythmWindow,
                ),
                style: AppTypography.cardTitle.copyWith(
                  color: theme.textPrimary,
                  fontFeatures: kTabularFigures,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                t.contributionRhythmHint,
                style: AppTypography.caption.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Una semana sin actividad se muestra en neutro, nunca en alarma.
        Row(
          children: [
            for (var week = 0; week < contribution.rhythmWindow; week++) ...[
              if (week > 0) const SizedBox(width: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: week < contribution.rhythmWeeks
                      ? AppColors.sage
                      : theme.surfaceContainer,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  final ContributionMember member;
  final double share;

  const _MemberRow({required this.member, required this.share});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Row(
      children: [
        CustomUserAvatar(
          name: member.name,
          userId: member.userId,
          avatarUrl: member.avatarUrl,
          radius: 17,
          forceCircular: true,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(color: theme.textPrimary),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: share,
                    backgroundColor: theme.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation(AppColors.sage),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              t.contributionTasksLabel(member.tasksDone),
              style: AppTypography.caption.copyWith(
                color: theme.textPrimary,
                fontFeatures: kTabularFigures,
              ),
            ),
            Text(
              t.contributionDemandingLabel(member.demandingDone),
              style: AppTypography.caption.copyWith(
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// La única frase que se destaca. Se nombra un patrón accionable, o se dice que
/// estuvo parejo — nunca se puntúa a nadie.
class _Reading extends StatelessWidget {
  final HouseholdContribution contribution;

  const _Reading({required this.contribution});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final skewed = contribution.skewedCategories;

    if (skewed.isEmpty) {
      return _ReadingBox(
        color: AppColors.sage,
        text: t.contributionBalanced,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final category in skewed) ...[
          _ReadingBox(
            color: CategoryMapping.getCategoryColor(category.category),
            text: t.contributionSkewed(
              CategoryMapping.displayName(category.category),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _ReadingBox extends StatelessWidget {
  final Color color;
  final String text;

  const _ReadingBox({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(
          AppRadii.md,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.body.copyWith(color: context.theme.textPrimary),
      ),
    );
  }
}

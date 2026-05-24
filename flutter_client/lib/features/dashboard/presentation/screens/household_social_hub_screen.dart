import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_ranking_section.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/presentation/screens/family_rewards_screen.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_parent_mode_card.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class HouseholdSocialHubScreen extends ConsumerStatefulWidget {
  const HouseholdSocialHubScreen({super.key});

  @override
  ConsumerState<HouseholdSocialHubScreen> createState() =>
      _HouseholdSocialHubScreenState();
}

class _HouseholdSocialHubScreenState
    extends ConsumerState<HouseholdSocialHubScreen> {
  Future<void> _refreshData() async {
    ref.invalidate(currentHouseholdProvider);
    await ref.read(householdMembersProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final theme = context.theme;

    final members = membersAsync.value ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refreshData,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              8,
              AppSpacing.lg,
              132,
            ),
            children: [
              _HeaderCard(
                caps: caps,
                currentMember: currentMember,
                onRewards: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FamilyRewardsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              FamilyRankingSection(currentMember: currentMember),
              // Configuracion del Modo Padres (toggle de aprobacion de tareas,
              // bandeja de pendientes). El widget se auto-oculta si el usuario
              // no es admin adulto de una familia, asi que es seguro siempre.
              const SizedBox(height: 18),
              const SettingsParentModeCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.caps,
    required this.currentMember,
    required this.onRewards,
  });

  final HouseholdCapabilities caps;
  final MemberModel? currentMember;
  final VoidCallback onRewards;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    final title = caps.socialHubTitle(t);
    final subtitle = caps.socialHubSubtitle(t);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.isDarkMode
              ? [
                  const Color(0xFF312A27),
                  const Color(0xFF251F1D),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFF7F0),
                ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.border.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color:
                theme.shadow.withValues(alpha: theme.isDarkMode ? 0.24 : 0.07),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.16),
                      AppColors.sage.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                child: Icon(caps.partnerIcon, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  currentMember == null
                      ? t.householdSocialHubRoleFallback
                      : t.householdSocialHubYourRole(
                          // Si el usuario es admin/owner del hogar, lo agregamos
                          // como sufijo para que sepa que tiene permisos
                          // adicionales (aprobar tareas, configurar, etc.).
                          currentMember!.isAdmin
                              ? '${currentMember!.localizedRoleLabel(t)} · Admin'
                              : currentMember!.localizedRoleLabel(t),
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _QuickActionButton(
                icon: Icons.storefront_rounded,
                label: t.householdSocialHubStoreButton,
                onPressed: onRewards,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

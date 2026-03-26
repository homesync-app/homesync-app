import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class HouseholdSocialHubScreen extends ConsumerWidget {
  const HouseholdSocialHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(currentHouseholdProvider);
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(currentHouseholdProvider);
            await ref.read(householdMembersNotifierProvider.notifier).refresh();
          },
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              8,
              AppSpacing.lg,
              132,
            ),
            children: [
              _HeroCard(caps: caps, householdAsync: householdAsync),
              const SizedBox(height: 18),
              membersAsync.when(
                data: (members) => _MembersSection(
                  caps: caps,
                  currentUserId: currentUserId,
                  members: members,
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: AppLoadingState(message: 'Cargando miembros...'),
                ),
                error: (error, _) => AppErrorState(
                  message: 'No pudimos cargar los miembros.\n$error',
                  onRetry: () => ref.invalidate(householdMembersNotifierProvider),
                ),
              ),
              const SizedBox(height: 18),
              _CoordinationCard(caps: caps),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.caps,
    required this.householdAsync,
  });

  final HouseholdCapabilities caps;
  final AsyncValue<dynamic> householdAsync;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final household = householdAsync.valueOrNull;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color:
                theme.shadow.withValues(alpha: theme.isDarkMode ? 0.24 : 0.08),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(caps.partnerIcon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caps.socialHubTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caps.socialHubSubtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.home_work_rounded,
                label: household?.name ?? 'Mi hogar',
              ),
              _InfoChip(
                icon: Icons.category_rounded,
                label: caps.socialTabLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.caps,
    required this.currentUserId,
    required this.members,
  });

  final HouseholdCapabilities caps;
  final String? currentUserId;
  final List<MemberModel> members;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (members.isEmpty) {
      return const AppEmptyState(
        title: 'Todavía no hay miembros cargados',
        subtitle:
            'Invitá a tu equipo para empezar a compartir tareas y gastos.',
        icon: Icons.group_off_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caps.type == HouseholdType.friends
              ? 'Miembros del grupo'
              : 'Miembros del hogar',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Una vista clara de quién forma parte del hogar y cómo están organizados.',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        ...members.map((member) {
          final isCurrentUser = member.userId == currentUserId;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.border.withValues(alpha: 0.72)),
            ),
            child: Row(
              children: [
                CustomUserAvatar(
                  avatarUrl: member.avatarUrl,
                  name: member.fullDisplayName,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.fullDisplayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Vos',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.email ?? member.roleLabel,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: member.isOwner
                        ? const Color(0xFFFFF1E8)
                        : theme.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    member.isOwner ? 'Admin' : 'Miembro',
                    style: TextStyle(
                      color: member.isOwner
                          ? AppColors.primary
                          : theme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _CoordinationCard extends StatelessWidget {
  const _CoordinationCard({required this.caps});

  final HouseholdCapabilities caps;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final title = switch (caps.type) {
      HouseholdType.family => 'Coordinación familiar',
      HouseholdType.friends => 'Convivencia del grupo',
      _ => 'Organización compartida',
    };

    final bullets = switch (caps.type) {
      HouseholdType.family => const [
          'Tareas y finanzas siguen compartidas para todos los miembros.',
          'Este espacio evita mezclar desafíos de pareja con dinámicas familiares.',
          'Podemos sumar más herramientas sociales acá sin romper el resto del producto.',
        ],
      HouseholdType.friends => const [
          'Mantiene claro quién participa del hogar y cómo se organiza el grupo.',
          'Evita que la app muestre copy o recompensas pensadas para pareja.',
          'Deja una base limpia para futuras funciones de convivencia entre amigos.',
        ],
      _ => const [
          'Este espacio centraliza la coordinación del hogar.',
        ],
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

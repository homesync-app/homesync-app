import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminPanel(),
    );
  }

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final theme = Theme.of(context);

    // Listen for transitions to show SnackBars
    ref.listen<AdminState>(adminProvider, (previous, next) {
      if (previous?.selectedHouseholdId != next.selectedHouseholdId &&
          next.selectedHouseholdId != null) {
        final from = previous?.selectedHouseholdName ?? 'Ninguno';
        final to = next.selectedHouseholdName ?? 'Desconocido';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🏘️ Cambio de Escenario: $from ➔ $to'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (previous?.impersonatedUserId != next.impersonatedUserId) {
        final isReset = next.impersonatedUserId == null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isReset ? '👤 Identidad Restaurada' : '🎭 Impersonando Usuario',
            ),
            backgroundColor:
                isReset ? AppColors.textSecondary : AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHandle(theme),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                _buildSectionTitle('ESCENARIOS DE TESTING'),
                const Text(
                  'Selecciona un modo de hogar para testear el comportamiento de la app.',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Scenario Grid
                ...AdminTestingConfig.scenarios.map(
                  (scenario) => _buildScenarioCard(
                    context,
                    scenario: scenario,
                    currentId: admin.selectedHouseholdId,
                  ),
                ),

                const Divider(height: 48),

                _buildSectionTitle('VISTA DE MIEMBRO'),
                const Text(
                  'Una vez en un escenario, puedes cambiar de "ojos" para ver qué ve cada miembro.',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                membersAsync.when(
                  data: (members) => Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.shield)),
                        title: const Text('Admin (Tú)'),
                        selected: admin.impersonatedUserId == null,
                        trailing: admin.impersonatedUserId == null
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                              )
                            : null,
                        onTap: () =>
                            ref.read(adminProvider.notifier).impersonate(null),
                      ),
                      ...members.map(
                        (m) => ListTile(
                          leading: CustomUserAvatar(
                            avatarUrl: m.avatarUrl,
                            radius: 16,
                          ),
                          title: Text(m.displayName),
                          subtitle: Text(
                            m.role == 'owner' ? 'Propietario' : 'Miembro',
                          ),
                          selected: admin.impersonatedUserId == m.userId,
                          trailing: admin.impersonatedUserId == m.userId
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => ref
                              .read(adminProvider.notifier)
                              .impersonate(m.userId),
                        ),
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Selecciona un escenario primero: $e'),
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.textSecondary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                  ),
                  child: const Text('Cerrar Panel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(
    BuildContext context, {
    required AdminTestingScenario scenario,
    required String? currentId,
  }) {
    final isSelected = currentId == scenario.householdId;
    final (icon, color) = switch (scenario.householdType) {
      HouseholdType.solo => (Icons.person_rounded, Colors.blue),
      HouseholdType.couple => (Icons.favorite_rounded, Colors.pink),
      HouseholdType.friends => (Icons.group_rounded, Colors.orange),
      HouseholdType.family => (Icons.family_restroom_rounded, Colors.green),
    };

    return Card(
      elevation: isSelected ? 4 : 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: () {
          ref.read(adminProvider.notifier).setAdminScenario(scenario);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          scenario.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(scenario.description),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

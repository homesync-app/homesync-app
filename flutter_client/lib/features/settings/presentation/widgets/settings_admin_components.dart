import 'package:flutter/material.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

class SettingsAdminTestingCard extends StatelessWidget {
  final AdminState admin;
  final AdminTestingScenario? selectedScenario;
  final VoidCallback onOpenPanel;
  final VoidCallback onOpenOnboarding;
  final VoidCallback onResetScenario;
  final VoidCallback onAddDummyMember;
  final Future<void> Function(AdminTestingScenario scenario) onSelectScenario;

  const SettingsAdminTestingCard({
    super.key,
    required this.admin,
    required this.selectedScenario,
    required this.onOpenPanel,
    required this.onOpenOnboarding,
    required this.onResetScenario,
    required this.onAddDummyMember,
    required this.onSelectScenario,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.isAdminUser
                            ? 'QA Admin Dashboard'
                            : 'Modo QA disponible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                      Text(
                        admin.isAdminUser
                            ? 'Admin QA separado de tu cuenta real. Elige un hogar de prueba y luego cambia la vista por avatar.'
                            : 'Ingresa con la cuenta de testing para habilitar los 4 hogares QA.',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (admin.isAdminUser)
                  IconButton(
                    onPressed: onOpenPanel,
                    tooltip: 'Panel avanzado',
                    icon: Icon(
                      Icons.open_in_full_rounded,
                      color: theme.textMuted,
                    ),
                  ),
              ],
            ),
            if (admin.isAdminUser) ...[
              const SizedBox(height: 18),
              ...AdminTestingConfig.scenarios.map(
                (scenario) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SettingsAdminScenarioTile(
                    scenario: scenario,
                    selectedHouseholdId: admin.selectedHouseholdId,
                    onTap: () => onSelectScenario(scenario),
                  ),
                ),
              ),
              if (selectedScenario != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onOpenOnboarding,
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: const Text('Onboarding'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onAddDummyMember,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Agregar miembro'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onResetScenario,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Resetear seed'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Tip: eliminÃ¡ miembros desde la secciÃ³n "Miembros" de este mismo hogar QA.',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsAdminScenarioTile extends StatelessWidget {
  final AdminTestingScenario scenario;
  final String? selectedHouseholdId;
  final VoidCallback onTap;

  const SettingsAdminScenarioTile({
    super.key,
    required this.scenario,
    required this.selectedHouseholdId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isSelected = selectedHouseholdId == scenario.householdId;

    final (icon, color) = switch (scenario.householdType) {
      HouseholdType.solo => (Icons.person_rounded, Colors.blue),
      HouseholdType.couple => (Icons.favorite_rounded, Colors.pink),
      HouseholdType.friends => (Icons.group_rounded, Colors.orange),
      HouseholdType.family => (Icons.family_restroom_rounded, Colors.green),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.10)
                : theme.scaffoldBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.65)
                  : theme.border.withValues(alpha: 0.45),
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.title,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scenario.description,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: color)
              else
                Icon(Icons.chevron_right_rounded, color: theme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, String?>?> showSettingsAdminAddDummyMemberDialog(
  BuildContext context,
) {
  final nameCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final avatarCtrl = TextEditingController();
  String selectedRole = 'member';

  return showDialog<Map<String, String?>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        backgroundColor: context.theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Agregar miembro dummy',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre visible',
                  hintText: 'Ej: Clara',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Rol / apodo',
                  hintText: 'Ej: Invitado, TÃ­a, Roomie',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: avatarCtrl,
                decoration: const InputDecoration(
                  labelText: 'Avatar emoji opcional',
                  hintText: 'Ej: ðŸ˜„',
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'member',
                    icon: Icon(Icons.person_outline_rounded),
                    label: Text('Miembro'),
                  ),
                  ButtonSegment(
                    value: 'owner',
                    icon: Icon(Icons.star_rounded),
                    label: Text('Owner'),
                  ),
                ],
                selected: {selectedRole},
                onSelectionChanged: (value) {
                  setDialogState(() => selectedRole = value.first);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, {
              'full_name': nameCtrl.text.trim(),
              'display_role': roleCtrl.text.trim(),
              'avatar_url': avatarCtrl.text.trim(),
              'role': selectedRole,
            }),
            child: const Text('Agregar'),
          ),
        ],
      ),
    ),
  );
}

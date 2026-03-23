import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class AdminPanel extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                _buildSectionTitle('DEBUG OPTS (Solo Tú)'),
                SwitchListTile(
                  title: const Text('Modo Desarrollador'),
                  subtitle: const Text('Habilita impersonación y cambios de modo locales'),
                  value: admin.isDeveloperMode,
                  onChanged: (val) => ref.read(adminProvider.notifier).toggleDeveloperMode(),
                ),
                const Divider(),
                if (admin.isDeveloperMode) ...[
                  _buildSectionTitle('CAMBIAR VISTA (Modo)'),
                  Wrap(
                    spacing: 8,
                    children: HouseholdType.values.map((type) {
                      final isSelected = admin.forcedHouseholdType == type;
                      return ChoiceChip(
                        label: Text(type.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) {
                          ref.read(adminProvider.notifier).forceType(val ? type : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('IMPERSONAR USUARIO'),
                  membersAsync.when(
                    data: (members) => Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person_off)),
                          title: const Text('Usuario Real'),
                          selected: admin.impersonatedUserId == null,
                          onTap: () => ref.read(adminProvider.notifier).impersonate(null),
                        ),
                        ...members.map((m) => ListTile(
                          leading: CustomUserAvatar(avatarUrl: m.avatarUrl, radius: 16),
                          title: Text(m.displayName),
                          subtitle: Text('ID: ${m.userId.substring(0, 8)}...'),
                          selected: admin.impersonatedUserId == m.userId,
                          onTap: () => ref.read(adminProvider.notifier).impersonate(m.userId),
                        )),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error al cargar miembros: $e'),
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar Panel'),
                ),
              ],
            ),
          ),
        ],
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

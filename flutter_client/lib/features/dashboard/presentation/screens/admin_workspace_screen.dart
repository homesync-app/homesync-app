import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/admin_testing_provider.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/admin_panel.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';

class AdminWorkspaceScreen extends ConsumerStatefulWidget {
  const AdminWorkspaceScreen({super.key});

  @override
  ConsumerState<AdminWorkspaceScreen> createState() =>
      _AdminWorkspaceScreenState();
}

class _AdminWorkspaceScreenState extends ConsumerState<AdminWorkspaceScreen> {
  bool _isBusy = false;

  Future<void> _refreshScenarioProviders() async {
    ref.invalidate(householdIdProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(currentHouseholdProvider);
    ref.invalidate(householdMembersProvider);
    ref.invalidate(householdMembersNotifierProvider);
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(tasksProvider);
    ref.invalidate(recentActivityProvider);
    await ref.read(householdMembersNotifierProvider.notifier).refresh();
  }

  Future<void> _selectScenario(AdminTestingScenario scenario) async {
    ref.read(adminProvider.notifier).setAdminScenario(scenario);
    await _refreshScenarioProviders();
  }

  Future<void> _enterAsQaUser(
    AdminTestingScenario scenario,
    QaTestUser qaUser,
  ) async {
    setState(() => _isBusy = true);
    try {
      await ref.read(qaSessionServiceProvider).signInAsQaUser(scenario, qaUser);
      await _refreshScenarioProviders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${qaUser.label} activo con sesión real'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos entrar como ${qaUser.label}: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _exitRealQaSession() async {
    setState(() => _isBusy = true);
    try {
      await ref.read(qaSessionServiceProvider).exitRealQaSession();
      await _refreshScenarioProviders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Volviste al panel admin QA'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos salir de la sesión QA: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _resetScenario(AdminTestingScenario scenario) async {
    setState(() => _isBusy = true);
    try {
      final result = await ref
          .read(householdRepositoryProvider)
          .qaResetScenario(scenario.householdId);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) {},
      );

      await _selectScenario(scenario);
      ref.invalidate(qaAdminRecentEventsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${scenario.title} volvió a su seed QA'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos resetear el escenario: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _showAddDummyMemberDialog(AdminTestingScenario scenario) async {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final avatarCtrl = TextEditingController();
    String selectedRole = 'member';

    final payload = await showDialog<Map<String, String?>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: context.theme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                      hintText: 'Ej: Invitado, Tía, Roomie',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: avatarCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Avatar emoji opcional',
                      hintText: 'Ej: 😄',
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
          );
        },
      ),
    );

    if (payload == null || (payload['full_name'] ?? '').trim().isEmpty) return;

    setState(() => _isBusy = true);
    try {
      final result =
          await ref.read(householdRepositoryProvider).qaAddDummyMember(
                householdId: scenario.householdId,
                fullName: payload['full_name']!,
                displayRole: payload['display_role'],
                avatarUrl: payload['avatar_url'],
                role: payload['role'] ?? 'member',
              );

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) {},
      );

      await _selectScenario(scenario);
      ref.invalidate(qaAdminRecentEventsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Miembro dummy agregado al escenario'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos agregar el miembro: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final admin = ref.watch(adminProvider);
    final selectedScenario =
        AdminTestingConfig.scenarioByHouseholdId(admin.selectedHouseholdId);
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final eventsAsync = ref.watch(qaAdminRecentEventsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin QA',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este espacio es separado de tu cuenta real. Elegí un hogar QA, configurá miembros, probá el onboarding y después cambiá la vista por avatar para inspeccionar cada miembro.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: theme.border.withValues(alpha: 0.5)),
                  boxShadow: theme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hogares QA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cada escenario tiene su propio seed y se puede resetear sin tocar tus datos reales.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...AdminTestingConfig.scenarios.map(
                      (scenario) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ScenarioCard(
                          scenario: scenario,
                          isSelected:
                              admin.selectedHouseholdId == scenario.householdId,
                          onTap: () => _selectScenario(scenario),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: theme.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acciones QA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedScenario == null
                          ? 'Elegí un escenario para habilitar reset, onboarding preview y alta de miembros dummy.'
                          : 'Escenario activo: ${selectedScenario.title}. Podés volverlo al seed inicial, sumar miembros o abrir el flujo de configuración desde cero.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 220,
                          child: ElevatedButton.icon(
                            onPressed: selectedScenario == null || _isBusy
                                ? null
                                : () => ref
                                    .read(adminProvider.notifier)
                                    .openOnboardingPreview(),
                            icon: const Icon(Icons.play_circle_outline_rounded),
                            label: const Text('Abrir onboarding'),
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: OutlinedButton.icon(
                            onPressed: selectedScenario == null || _isBusy
                                ? null
                                : () => _showAddDummyMemberDialog(
                                      selectedScenario,
                                    ),
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text('Agregar miembro dummy'),
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: OutlinedButton.icon(
                            onPressed: selectedScenario == null || _isBusy
                                ? null
                                : () => _resetScenario(selectedScenario),
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: Text(_isBusy
                                ? 'Trabajando...'
                                : 'Resetear escenario'),
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: OutlinedButton.icon(
                            onPressed: () => AdminPanel.show(context),
                            icon: const Icon(Icons.visibility_rounded),
                            label: const Text('Abrir panel avanzado'),
                          ),
                        ),
                      ],
                    ),
                    if (selectedScenario != null &&
                        selectedScenario.qaUsers.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.border.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Cuentas QA reales',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                ),
                                if (admin.useRealQaSession)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      admin.realQaUserLabel ??
                                          admin.realQaUserEmail ??
                                          'Sesión QA',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...selectedScenario.qaUsers.map(
                              (qaUser) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            qaUser.label,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: theme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            qaUser.email,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: theme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: _isBusy
                                          ? null
                                          : () => _enterAsQaUser(
                                                selectedScenario,
                                                qaUser,
                                              ),
                                      icon: const Icon(Icons.login_rounded),
                                      label: const Text('Entrar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (admin.useRealQaSession)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed:
                                      _isBusy ? null : _exitRealQaSession,
                                  icon: const Icon(Icons.logout_rounded),
                                  label: const Text('Salir de sesión QA'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (selectedScenario != null) ...[
                      const SizedBox(height: 18),
                      membersAsync.when(
                        data: (members) => Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackground,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.border.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Miembros del escenario',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...members.map(
                                (member) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        member.avatarUrl ?? '🙂',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${member.displayName} · ${member.displayRole ?? member.role}',
                                          style: TextStyle(
                                            color: theme.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(minHeight: 3),
                        ),
                        error: (error, _) => Text(
                          'No pudimos leer los miembros: $error',
                          style: TextStyle(color: theme.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: theme.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Bitácora QA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              ref.invalidate(qaAdminRecentEventsProvider),
                          tooltip: 'Actualizar bitácora',
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Últimas acciones de testing sobre los escenarios QA.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    eventsAsync.when(
                      data: (events) {
                        if (events.isEmpty) {
                          return Text(
                            'Todavía no hay acciones QA registradas.',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }

                        return Column(
                          children: events
                              .map(
                                (event) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackground,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.border
                                            .withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.history_rounded,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: theme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                event.subtitle,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1.35,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          _formatAuditTime(event.occurredAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: theme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () =>
                          const LinearProgressIndicator(minHeight: 3),
                      error: (error, _) => Text(
                        'No pudimos cargar la bitácora: $error',
                        style: TextStyle(color: theme.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAuditTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    final mon = value.month.toString().padLeft(2, '0');
    return '$dd/$mon $hh:$mm';
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.isSelected,
    required this.onTap,
  });

  final AdminTestingScenario scenario;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.10)
                : theme.scaffoldBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.7)
                  : theme.border.withValues(alpha: 0.5),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scenario.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: theme.textSecondary,
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

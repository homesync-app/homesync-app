import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/admin_testing_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/shared/widgets/admin_panel.dart';

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
        (failure) => throw failure,
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
        (failure) => throw failure,
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
                            label: Text(
                              _isBusy ? 'Trabajando...' : 'Resetear escenario',
                            ),
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
              _CatalogRequestsSection(theme: theme),
              const SizedBox(height: 20),
              _UserFeedbackSection(theme: theme),
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
              const SizedBox(height: 20),
              _ErrorLogsSection(theme: theme),
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

// ─── Catálogo Pendiente ──────────────────────────────────────────────────────

class _CatalogRequestsSection extends ConsumerWidget {
  final dynamic theme;
  const _CatalogRequestsSection({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(_catalogRequestsProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📦', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catálogo Pendiente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      'Productos que los usuarios agregan y no están en el catálogo',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () => ref.invalidate(_catalogRequestsProvider),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: 14),
          requestsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  'Sin productos pendientes aún 🎉',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                );
              }
              return Column(
                children: items.map((item) {
                  final name = item['name'] as String;
                  final emoji = item['emoji'] as String? ?? '🛒';
                  final count = item['total_count'] as int? ?? 1;
                  final lastSeen = item['last_seen_at'] != null
                      ? DateTime.tryParse(item['last_seen_at'] as String)
                      : null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: theme.textPrimary,
                                ),
                              ),
                              if (lastSeen != null)
                                Text(
                                  'Última vez: ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: count >= 5
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.divider.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$count veces',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: count >= 5
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (e, _) => Text(
              'Error cargando catálogo: $e',
              style: TextStyle(color: theme.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

final _catalogRequestsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final response = await client
      .from('shopping_catalog_requests')
      .select('name, emoji, total_count, last_seen_at')
      .order('total_count', ascending: false)
      .limit(50);
  return List<Map<String, dynamic>>.from(response as List);
});

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

// ─── Feedback de usuarios ────────────────────────────────────────────────────

final _userFeedbackProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final response = await client
      .from('user_feedback')
      .select('id, type, title, description, email, app_version, platform, created_at')
      .order('created_at', ascending: false)
      .limit(100);
  return List<Map<String, dynamic>>.from(response as List);
});

class _UserFeedbackSection extends ConsumerStatefulWidget {
  final dynamic theme;
  const _UserFeedbackSection({required this.theme});

  @override
  ConsumerState<_UserFeedbackSection> createState() =>
      _UserFeedbackSectionState();
}

class _UserFeedbackSectionState extends ConsumerState<_UserFeedbackSection> {
  String _typeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final feedbackAsync = ref.watch(_userFeedbackProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback de usuarios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      'Reportes y sugerencias enviados desde la app',
                      style: TextStyle(fontSize: 12, color: theme.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () => ref.invalidate(_userFeedbackProvider),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip(theme, 'all', 'Todos'),
                _filterChip(theme, 'bug', 'Errores'),
                _filterChip(theme, 'suggestion', 'Sugerencias'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          feedbackAsync.when(
            data: (items) {
              final filtered = _typeFilter == 'all'
                  ? items
                  : items.where((i) => i['type'] == _typeFilter).toList();

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      _typeFilter == 'all'
                          ? 'Sin feedback todavía'
                          : _typeFilter == 'bug'
                              ? 'Sin reportes de errores'
                              : 'Sin sugerencias todavía',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: filtered
                    .map((item) => _FeedbackTile(item: item, theme: theme))
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (e, _) => Text(
              'Error cargando feedback: $e',
              style: TextStyle(color: theme.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(dynamic theme, String value, String label) {
    final selected = _typeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onSelected: (_) => setState(() => _typeFilter = value),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _FeedbackTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic theme;
  const _FeedbackTile({required this.item, required this.theme});

  @override
  State<_FeedbackTile> createState() => _FeedbackTileState();
}

class _FeedbackTileState extends State<_FeedbackTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final item = widget.item;
    final isBug = (item['type'] as String?) == 'bug';
    final color = isBug ? AppColors.error : AppColors.primary;
    final title = item['title'] as String? ?? '';
    final description = item['description'] as String?;
    final email = item['email'] as String?;
    final appVersion = item['app_version'] as String?;
    final platform = item['platform'] as String?;
    final createdAt = item['created_at'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _expanded
                  ? color.withValues(alpha: 0.5)
                  : theme.border.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isBug ? 'BUG' : 'IDEA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: _expanded ? null : 1,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(fontSize: 10, color: theme.textMuted),
                    ),
                  ],
                ],
              ),
              if (_expanded) ...[
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (email != null)
                      _metaChip(theme, Icons.email_outlined, email),
                    if (platform != null)
                      _metaChip(theme, Icons.smartphone_outlined, platform),
                    if (appVersion != null)
                      _metaChip(theme, Icons.info_outline_rounded, 'v$appVersion'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(dynamic theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: theme.textMuted),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: theme.textSecondary)),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final mon = dt.month.toString().padLeft(2, '0');
    return '$dd/$mon $hh:$mm';
  }
}

final _errorLogsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final response = await client
      .from('application_logs')
      .select(
          'id, level, message, stack_trace, context, device_info, created_at')
      .order('created_at', ascending: false)
      .limit(50);
  return List<Map<String, dynamic>>.from(response as List);
});

class _ErrorLogsSection extends ConsumerStatefulWidget {
  final dynamic theme;
  const _ErrorLogsSection({required this.theme});

  @override
  ConsumerState<_ErrorLogsSection> createState() => _ErrorLogsSectionState();
}

class _ErrorLogsSectionState extends ConsumerState<_ErrorLogsSection> {
  String? _expandedLogId;
  String _levelFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final logsAsync = ref.watch(_errorLogsProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bug_report_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logs de Error',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      'Errores capturados por la app en tiempo real',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () => ref.invalidate(_errorLogsProvider),
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _levelChip('all', 'Todos'),
                _levelChip('error', 'Error'),
                _levelChip('critical', 'Critical'),
                _levelChip('warning', 'Warning'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          logsAsync.when(
            data: (logs) {
              final filtered = _levelFilter == 'all'
                  ? logs
                  : logs
                      .where((l) => (l['level'] as String?) == _levelFilter)
                      .toList();
              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      _levelFilter == 'all'
                          ? 'Sin errores registrados'
                          : 'Sin errores de nivel $_levelFilter',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: filtered.map((log) {
                  final id = log['id'] as String;
                  final isExpanded = _expandedLogId == id;
                  return _ErrorLogTile(
                    log: log,
                    theme: theme,
                    isExpanded: isExpanded,
                    onToggle: () =>
                        setState(() => _expandedLogId = isExpanded ? null : id),
                  );
                }).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (e, _) => Text(
              'Error cargando logs: $e',
              style: TextStyle(color: theme.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelChip(String value, String label) {
    final selected = _levelFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onSelected: (_) => setState(() => _levelFilter = value),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ErrorLogTile extends StatelessWidget {
  final Map<String, dynamic> log;
  final dynamic theme;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ErrorLogTile({
    required this.log,
    required this.theme,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final level = log['level'] as String? ?? 'error';
    final message = log['message'] as String? ?? 'Unknown error';
    final createdAt = log['created_at'] as String?;
    final contextData = log['context'] as Map<String, dynamic>?;
    final stackTrace = log['stack_trace'] as String?;
    final diagnostics = contextData?['full_diagnostics'] as String?;
    final stackHead = contextData?['stack_frames_head'] as String?;
    final errorContext = contextData?['context'] as String?;
    final library = contextData?['library'] as String?;
    final email = contextData?['email'] as String?;

    final levelColor = switch (level) {
      'critical' => AppColors.error,
      'error' => AppColors.warning,
      'warning' => AppColors.accentOrange,
      _ => AppColors.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: theme.scaffoldBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? levelColor.withValues(alpha: 0.5)
                : theme.border.withValues(alpha: 0.35),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: levelColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          level.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: levelColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (library != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            library,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (email != null) ...[
                        const Spacer(),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatLogTime(createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    if (errorContext != null && errorContext.isNotEmpty) ...[
                      _buildDetailBlock('Contexto', errorContext, theme),
                      const SizedBox(height: 8),
                    ],
                    if (diagnostics != null && diagnostics.isNotEmpty) ...[
                      _buildDetailBlock('Diagnostics', diagnostics, theme),
                      const SizedBox(height: 8),
                    ],
                    if (stackHead != null && stackHead.isNotEmpty) ...[
                      _buildDetailBlock('Stack (top 20)', stackHead, theme),
                      const SizedBox(height: 8),
                    ],
                    if (stackTrace != null && stackTrace.isNotEmpty) ...[
                      _buildDetailBlock(
                          'Stack trace completo', stackTrace, theme),
                    ],
                    if (contextData != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailBlock(
                        'Context JSON',
                        contextData.entries
                            .where((e) =>
                                e.key != 'full_diagnostics' &&
                                e.key != 'stack_frames_head' &&
                                e.key != 'context' &&
                                e.key != 'library')
                            .map((e) => '${e.key}: ${e.value}')
                            .join('\n'),
                        theme,
                      ),
                    ],
                  ],
                  if (!isExpanded) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Spacer(),
                        Icon(
                          Icons.expand_more_rounded,
                          size: 14,
                          color: theme.textMuted,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBlock(String label, String content, dynamic theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: theme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.surfaceContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              height: 1.4,
              color: theme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatLogTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final mon = dt.month.toString().padLeft(2, '0');
    return '$dd/$mon $hh:$mm:$ss';
  }
}

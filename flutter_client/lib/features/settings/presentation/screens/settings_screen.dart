import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/theme_palettes.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/admin_testing_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/screens/couple_split_strategy_screen.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/couple_home_tour_controller.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:homesync_client/features/settings/presentation/providers/settings_provider.dart';
import 'package:homesync_client/features/settings/presentation/widgets/faq_sheet.dart';
import 'package:homesync_client/features/settings/presentation/widgets/feedback_sheet.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_account_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_admin_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_household_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_parent_mode_card.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/shared/widgets/admin_panel.dart';
import 'package:homesync_client/shared/widgets/avatar_picker_sheet.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.onLogout,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  String? _householdId;
  String? _invitationCode;
  List<Map<String, dynamic>> _members = [];
  String? _householdName;
  String? _householdType;
  bool _tasksEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _refreshAdminScenarioState() async {
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
    ref.invalidate(qaAdminRecentEventsProvider);
    await ref.read(householdMembersNotifierProvider.notifier).refresh();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasLoadedOnce = true;
          });
        }
        return;
      }

      final hId = await ref.read(householdIdProvider.future);
      if (hId == null || hId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasLoadedOnce = true;
          });
        }
        return;
      }
      _householdId = hId;

      final supabaseClient = ref.read(supabaseClientProvider);
      final householdFuture = supabaseClient
          .from('households')
          .select('name, household_type, tasks_enabled')
          .eq('id', hId)
          .maybeSingle();
      final invitationFuture = supabaseClient
          .from('household_invitations')
          .select('code')
          .eq('household_id', hId)
          .isFilter('used_at', null)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final membersFuture =
          ref.read(householdRepositoryProvider).getHouseholdMembersRaw();

      final householdResult = await Future.wait<dynamic>([
        householdFuture,
        invitationFuture,
        membersFuture,
      ]);
      final household = householdResult[0] as Map<String, dynamic>?;
      final invitation = householdResult[1] as Map<String, dynamic>?;
      final membersResult =
          householdResult[2] as Either<Failure, List<Map<String, dynamic>>>;
      final membersList = membersResult.match(
        (failure) {
          log.e('Error loading members: ${failure.message}');
          return <Map<String, dynamic>>[];
        },
        (members) => members,
      );

      if (mounted) {
        setState(() {
          _householdName = household?['name'];
          _householdType = household?['household_type'];
          _tasksEnabled = household?['tasks_enabled'] as bool? ?? true;
          _invitationCode = invitation?['code'];
          _members = List<Map<String, dynamic>>.from(membersList);
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      log.e('Error loading settings: $e', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  Future<void> _generateNewCode() async {
    try {
      final result =
          await ref.read(householdRepositoryProvider).generateInvitationCode();

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (code) => setState(() => _invitationCode = code),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Codigo generado'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _copyCode() {
    final code = _invitationCode;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Codigo copiado al portapapeles'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    if (_invitationCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Genera un codigo primero')),
      );
      return;
    }
    String intro = '¡Hola! Te invito a unirte a nuestro hogar en HomeSync.';
    if (_householdType == 'couple') {
      intro =
          '¡Hola! Únete a mi pareja en HomeSync para organizar nuestros gastos y tareas.';
    } else if (_householdType == 'family') {
      intro = '¡Hola! Te invito a unirte a nuestro hogar familiar en HomeSync.';
    } else if (_householdType == 'friends') {
      intro =
          '¡Hola! Únete a nuestra convivencia en HomeSync para organizar mejor el piso.';
    }

    final text =
        '$intro\n\nDescarga la app e ingresa este código: *$_invitationCode*\n\n¡Organicemos nuestro hogar juntos!';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        final webUrl =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          _copyCode();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir WhatsApp. Codigo copiado.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      _copyCode();
    }
  }

  void _showJoinDialog() {
    showSettingsJoinHouseholdDialog(
      context,
      onJoin: (code) async {
        try {
          final result =
              await ref.read(householdRepositoryProvider).joinHousehold(code);

          return await result.fold(
            (failure) async => failure.message,
            (_) async {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Te uniste al hogar exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
                await _loadData();
              }
              return null;
            },
          );
        } catch (e) {
          return e.toString().replaceFirst('Exception: ', '');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // ── Rol del miembro actual ─────────────────────────────────────────────
    final currentMember = ref.watch(currentMemberProvider);
    final isChild = currentMember?.isChild ?? false;
    final isTeen = currentMember?.isTeen ?? false;
    // isMinor = cualquier menor de edad (child o teen)
    final isMinor = isChild || isTeen;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackground,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              color: theme.primary,
              backgroundColor: theme.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _SettingsHeader(onBack: _handleBackNavigation),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionLabel(
                            eyebrow: 'PERFIL',
                            title: 'Tu espacio',
                            subtitle:
                                'Avatar, nombre y datos basicos de tu cuenta.',
                          ),
                          const SizedBox(height: 14),
                          _buildProfileCard(),
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            eyebrow: 'HOGAR',
                            title: 'Casa compartida',
                            subtitle:
                                'Miembros, invitaciones y reglas del hogar.',
                          ),
                          const SizedBox(height: 14),
                          if (_householdId != null) ...[
                            _buildCombinedHouseholdCard(),
                            // Modo Padres solo visible para adultos; menores
                            // no pueden gestionar ni ver esta seccion.
                            if (!isMinor) ...[
                              const SizedBox(height: 16),
                              const SettingsParentModeCard(),
                            ],
                          ] else if (!_hasLoadedOnce && _isLoading) ...[
                            _buildLoadingCard(height: 220),
                          ] else ...[
                            _buildNoHouseholdCard(),
                          ],
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            eyebrow: 'APP',
                            title: 'Preferencias',
                            subtitle: 'Tema, notificaciones, ayuda y feedback.',
                          ),
                          const SizedBox(height: 14),
                          // Menores no pueden comprar premium — solo ven una
                          // tarjeta informativa que los redirige a sus padres.
                          if (isMinor)
                            SettingsMinorPremiumCard(isChild: isChild)
                          else
                            _buildPremiumCard(),
                          const SizedBox(height: 24),
                          _buildAppearanceCard(isMinor: isMinor),
                          const SizedBox(height: 24),
                          _buildNotificationsCard(),
                          const SizedBox(height: 16),
                          if (AppEnvironment.enableAdminTesting) ...[
                            _buildAdminTestingCard(),
                            const SizedBox(height: 16),
                          ],
                          _buildFAQButton(),
                          const SizedBox(height: 16),
                          _buildFeedbackCard(),
                          const SizedBox(height: 14),
                          _buildReplayTourButton(),
                          const SizedBox(height: 48),
                          _buildSectionLabel(
                            eyebrow: 'CUENTA',
                            title: 'Sesion y seguridad',
                            subtitle:
                                'Salir de la cuenta o reiniciar tus datos si lo necesitas.',
                          ),
                          const SizedBox(height: 14),
                          _buildLogoutButton(),
                          const SizedBox(height: 32),
                          _buildResetAccountButton(),
                          const SizedBox(height: 48),
                          _buildSectionLabel(
                            eyebrow: 'LEGAL',
                            title: 'Privacidad',
                            subtitle:
                                'Politica de privacidad y terminos de uso.',
                          ),
                          const SizedBox(height: 14),
                          _buildLegalCard(),
                          const SizedBox(height: 48),
                          SettingsVersionFooter(
                            isAdminEnabled: AppEnvironment.enableAdminTesting &&
                                ref.watch(adminProvider).isAdminUser,
                            onTap: () => AdminPanel.show(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading && !_hasLoadedOnce)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: theme.scaffoldBackground.withValues(alpha: 0.001),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: theme.primary,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    ref.read(bottomNavIndexProvider.notifier).setIndex(0);
    Navigator.pop(context);
  }

  Widget _buildLoadingCard({double height = 180}) {
    return SettingsLoadingCard(height: height);
  }

  // Profile Card

  // Profile Card

  Widget _buildSectionLabel({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return SettingsSectionLabel(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildProfileCard() {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.whenOrNull(data: (p) => p);
    final name = (profile?['full_name'] as String?) ?? 'Usuario';
    final email = (profile?['email'] as String?) ?? '';
    final avatar = profile?['avatar_url'] as String?;
    return SettingsProfileCard(
      name: name,
      email: email,
      avatarUrl: avatar,
      onAvatarTap: () => AvatarPickerSheet.show(context),
      onNameTap: () => _showRenameDialog(name),
    );
  }

  Widget _buildCombinedHouseholdCard() {
    final typeLabels = {
      'couple': '💑 Pareja',
      'family': '👨‍👩‍👧‍👦 Familia',
      'friends': '🏠 Convivencia',
      'roommates': '🏠 Compañeros',
      'solo': '👤 Solo',
    };
    final memberCount = _members.length;
    final currentUserId = ref.read(currentUserIdProvider);
    final isOwner = _members.any(
      (member) =>
          member['user_id'] == currentUserId && member['role'] == 'owner',
    );
    final isAdminQaUser = ref.watch(adminProvider).isAdminUser;

    // Determinar si mostrar el toggle según tipo de hogar
    // Family NO puede ocultar tareas, los demás SÍ pueden
    final householdType = HouseholdType.fromString(_householdType);
    final showTasksToggle = householdType != HouseholdType.family;

    final members = buildSettingsHouseholdMemberData(
      context: context,
      members: _members,
      currentUserId: currentUserId,
      isAdminQaUser: isAdminQaUser,
      roleLabelBuilder: _getMemberRoleLabel,
      onEditRole: _updateMemberRole,
      onRemoveMember: _confirmRemoveMember,
      onDeleteDummyMember: _confirmDeleteDummyMember,
      isOwner: isOwner,
    );

    return buildSettingsCombinedHouseholdCard(
      context,
      householdName: _householdName ?? 'Mi hogar',
      householdTypeLabel: typeLabels[_householdType] ?? 'Hogar',
      onEdit: _showEditHouseholdMenu,
      memberCount: memberCount,
      members: members,
      tasksEnabled: _tasksEnabled,
      showTasksToggle: showTasksToggle,
      onTasksEnabledChanged: (showTasksToggle && (isOwner || isAdminQaUser))
          ? _onTasksToggled
          : null,
    );
  }

  void _onTasksToggled(bool enabled) {
    _confirmAndUpdateTasksEnabled(enabled);
  }

  Future<void> _confirmAndUpdateTasksEnabled(bool enabled) async {
    final action = enabled ? 'activar' : 'desactivar';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar cambio'),
        content: Text(
          'Al $action el modo "Solo finanzas", TODOS los miembros del hogar '
          'verán solo funcionalidades financieras (sin tareas, compras, etc.). '
          'Esta configuración se aplica a todo el hogar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateTasksEnabled(enabled);
    }
  }

  Future<void> _updateTasksEnabled(bool enabled) async {
    final householdId = _householdId;
    if (householdId == null || _tasksEnabled == enabled) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(householdRepositoryProvider)
          .updateTasksEnabled(householdId, enabled);
      result.fold((failure) => throw failure, (_) {});

      ref.invalidate(currentHouseholdProvider);
      ref.invalidate(householdCapabilitiesProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(tasksProvider);
      ref.invalidate(statsControllerProvider);
      ref.invalidate(recentActivityProvider);

      if (!enabled) {
        ref.read(bottomNavIndexProvider.notifier).setIndex(0);
      }

      if (mounted) {
        setState(() => _tasksEnabled = enabled);
      }
      await _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? '✅ Tareas del hogar activadas'
                : '✅ Modo finanzas y compras activado',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error, stackTrace) {
      log.e(
        'Error updating household tasks visibility',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar la configuracion: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmRemoveMember(String userId, String name) async {
    final theme = context.theme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '¿Quitar miembro?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content:
            Text('¿Estás seguro de que quieres quitar a $name de este hogar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(100, 48), // Prevents infinite width error
            ),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(householdRepositoryProvider).removeMember(userId);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $name ha sido quitado del hogar'),
              backgroundColor: theme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDeleteDummyMember(String userId, String name) async {
    final theme = context.theme;
    final householdId = _householdId;
    if (householdId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '¿Eliminar dummy QA?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Esto eliminará a $name como usuario dummy QA. Si no pertenece a otro hogar QA, también se borrará su identidad técnica.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(128, 48),
            ),
            child: const Text('Eliminar dummy'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final result =
          await ref.read(householdRepositoryProvider).qaDeleteDummyMember(
                householdId: householdId,
                userId: userId,
              );

      result.fold(
        (failure) => throw failure,
        (_) {},
      );

      ref.invalidate(householdMembersNotifierProvider);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dummy QA eliminado: $name'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos eliminar el dummy: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showRenameHouseholdDialog() async {
    final ctrl = TextEditingController(text: _householdName);
    final theme = context.theme;
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nombre del hogar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Tu nombre',
            filled: true,
            fillColor: theme.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 48), // Prevents infinite width error
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == _householdName) return;

    try {
      final hId = _householdId;
      if (hId == null) return;

      await ref
          .read(supabaseClientProvider)
          .from('households')
          .update({'name': newName}).eq('id', hId);

      if (mounted) {
        setState(() => _householdName = newName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Hogar renombrado'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getMemberRoleLabel(Map<String, dynamic> member, String? role) {
    final displayRole = member['display_role'] as String?;
    if (displayRole != null && displayRole.isNotEmpty) {
      return displayRole;
    }
    if (role == 'owner') return 'Propietario';
    switch (_householdType) {
      case 'couple':
        return 'Pareja';
      case 'family':
        return 'Integrante';
      case 'friends':
        return 'Compañero';
      default:
        return 'Miembro';
    }
  }

  Future<void> _updateMemberRole(Map<String, dynamic> member) async {
    final theme = context.theme;
    final userId = member['user_id'];
    final currentLabel = member['display_role'] ?? '';
    final suggestions = <String>[];
    if (_householdType == 'family') {
      suggestions.addAll([
        'Padre',
        'Madre',
        'Tutor/a',
        'Adolescente',
        'Hijo/a',
        'Abuelo/a',
      ]);
    } else if (_householdType == 'couple') {
      suggestions.addAll(['Pareja', 'Novio', 'Novia', 'Esposo', 'Esposa']);
    } else if (_householdType == 'friends') {
      suggestions.addAll(['Compañero', 'Roommate', 'Invitado', 'Responsable']);
    }

    final ctrl = TextEditingController(text: currentLabel);

    final String? newRole = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Asignar Rol / Apodo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: _householdType == 'family'
                    ? 'Nombre del rol (ej: Madre)'
                    : _householdType == 'friends'
                        ? 'Nombre del rol (ej: Compañero)'
                        : 'Nombre del rol (ej: Padre)',
                filled: true,
                fillColor: theme.primary.withValues(alpha: 0.05),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Sugerencias:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: suggestions
                    .map(
                      (s) => ActionChip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        onPressed: () => ctrl.text = s,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (newRole == null || newRole == currentLabel) return;

    try {
      setState(() => _isLoading = true);
      final repo = ref.read(householdRepositoryProvider);
      final result = await repo.updateMemberDisplayRole(userId, newRole);

      result.fold(
        (l) => throw l,
        (r) {
          if (mounted) {
            setState(() {
              member['display_role'] = newRole;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Rol actualizado'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditHouseholdMenu() {
    showSettingsEditHouseholdMenu(
      context,
      householdName: _householdName ?? 'Mi hogar',
      invitationCode: _invitationCode,
      householdType: _householdType,
      onEditName: _showRenameHouseholdDialog,
      onInvitationCode: _showInvitationCodeSheet,
      onCoupleSplit: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CoupleSplitStrategyScreen(),
          ),
        );
      },
    );
  }

  void _showInvitationCodeSheet() {
    showSettingsInvitationCodeSheet(
      context,
      invitationCode: _invitationCode,
      onShareWhatsApp: _shareViaWhatsApp,
      onCopyCode: _copyCode,
      onGenerateCode: (refreshSheet) async {
        refreshSheet();
        await _generateNewCode();
        refreshSheet();
      },
    );
  }

  Widget _buildAppearanceCard({bool isMinor = false}) {
    final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;
    final currentColor = ref.watch(primaryColorProvider);
    final defaultPalette = ThemePalette.all.firstWhere(
      (palette) => palette.name == 'Naranja (Original)',
      orElse: () => ThemePalette.all.first,
    );
    final selectedPalette = ThemePalette.all.cast<ThemePalette?>().firstWhere(
          (palette) => palette?.primary.toARGB32() == currentColor.toARGB32(),
          orElse: () => null,
        );
    final isFreeSelected = selectedPalette != null &&
        const {'Naranja (Original)'}.contains(selectedPalette.name);
    final effectiveColor =
        (!isPremium && !isFreeSelected) ? defaultPalette.primary : currentColor;

    return SettingsAppearanceCard(
      effectiveColor: effectiveColor,
      isPremium: isPremium,
      currentThemeMode: ref.watch(themeModeProvider),
      onThemeModeChanged: (mode) {
        HapticFeedback.lightImpact();
        ref.read(themeModeProvider.notifier).setMode(mode);
      },
      // Menores ven el candado pero no se redirigen al paywall — se les indica
      // que deben pedirle a sus padres que activen el plan.
      onLockedTap: isMinor
          ? _showMinorPremiumSnackbar
          : () => PremiumPaywall.show(context),
      onPaletteTap: (palette) {
        HapticFeedback.lightImpact();
        ref.read(primaryColorProvider.notifier).setColor(palette.primary);
      },
    );
  }

  void _showMinorPremiumSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Esta funcion es premium 🌟 Pedi a tus papas que activen el plan.',
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildPremiumCard() {
    final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;

    return SettingsPremiumCard(
      isPremium: isPremium,
      onTapPlans: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
        );
      },
      premiumFeatures: const [
        'Sincronizacion Shopping a Finanzas',
        'Pagos Recurrentes (Suscripciones)',
        'Notas de Amor en Dashboard',
        'Avatares Exclusivos',
      ],
    );
  }

  Future<void> _showRenameDialog(String currentName) async {
    final newName = await showSettingsRenameProfileDialog(
      context,
      currentName: currentName,
    );

    if (newName == null || newName.isEmpty || newName == currentName) return;

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .updateProfile(fullName: newName);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) {},
      );

      // Invalidate profile cache so header updates
      ref.invalidate(userProfileProvider);
      ref.invalidate(householdMembersNotifierProvider);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        await _loadData();
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('✅ Nombre actualizado'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildNotificationsCard() {
    final isEnabled = ref.watch(notificationEnabledProvider);
    final theme = context.theme;

    return SettingsNotificationsCard(
      isEnabled: isEnabled,
      onChanged: (value) {
        HapticFeedback.lightImpact();
        ref.read(notificationEnabledProvider.notifier).toggle(value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? '🔔 Notificaciones activadas'
                  : '🔕 Notificaciones desactivadas',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: value ? theme.success : theme.textMuted,
          ),
        );
      },
    );
  }

  Widget _buildAdminTestingCard() {
    final admin = ref.watch(adminProvider);
    final selectedScenario =
        AdminTestingConfig.scenarioByHouseholdId(admin.selectedHouseholdId);

    return SettingsAdminTestingCard(
      admin: admin,
      selectedScenario: selectedScenario,
      onOpenPanel: () => AdminPanel.show(context),
      onOpenOnboarding: () {
        ref.read(adminProvider.notifier).openOnboardingPreview();
        Navigator.pop(context);
      },
      onResetScenario: selectedScenario == null
          ? () {}
          : () => _resetAdminScenario(selectedScenario),
      onAddDummyMember: selectedScenario == null
          ? () {}
          : () => _showAdminAddDummyMemberDialog(selectedScenario),
      onSelectScenario: (scenario) async {
        ref.read(adminProvider.notifier).setAdminScenario(scenario);
        await _refreshAdminScenarioState();
        await _loadData();
      },
    );
  }

  Future<void> _resetAdminScenario(AdminTestingScenario scenario) async {
    setState(() => _isLoading = true);
    try {
      final result =
          await ref.read(householdRepositoryProvider).qaResetScenario(
                scenario.householdId,
              );

      result.fold(
        (failure) => throw failure,
        (_) {},
      );

      ref.read(adminProvider.notifier).setAdminScenario(scenario);
      await _refreshAdminScenarioState();
      await _loadData();

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAdminAddDummyMemberDialog(
    AdminTestingScenario scenario,
  ) async {
    final payload = await showSettingsAdminAddDummyMemberDialog(context);

    if (payload == null || (payload['full_name'] ?? '').trim().isEmpty) return;

    setState(() => _isLoading = true);
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

      ref.read(adminProvider.notifier).setAdminScenario(scenario);
      ref.invalidate(householdIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(currentHouseholdProvider);
      ref.invalidate(householdMembersNotifierProvider);
      ref.invalidate(qaAdminRecentEventsProvider);
      await _loadData();

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildNoHouseholdCard() {
    return SettingsNoHouseholdCard(
      onJoin: _showJoinDialog,
    );
  }

  Widget _buildFAQButton() {
    return SettingsFaqCard(
      onTap: () {
        HapticFeedback.lightImpact();
        FAQSheet.show(context);
      },
    );
  }

  Widget _buildFeedbackCard() {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            FeedbackSheet.show(context, screen: 'settings');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enviar feedback',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Reporta un bug o sugiere una mejora',
                        style: TextStyle(
                          color: theme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplayTourButton() {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.accentGold,
            size: 22,
          ),
        ),
        title: Text(
          'Ver guia de nuevo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        subtitle: Text(
          'Repasa la introduccion del hogar',
          style: TextStyle(color: theme.textSecondary, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.textMuted),
        onTap: () async {
          HapticFeedback.lightImpact();
          final controller =
              ref.read(coupleHomeTourControllerProvider.notifier);
          await controller.reset();
          ref.invalidate(coupleHomeTourSeenProvider);
          if (!mounted) return;
          final tasks = ref.read(todayTasksProvider).whenOrNull(data: (t) => t);
          controller.start(hasTasks: tasks?.isNotEmpty ?? false);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SettingsLogoutButton(
      onPressed: () async {
        HapticFeedback.mediumImpact();
        final confirm = await showSettingsLogoutDialog(context);

        if (confirm == true) {
          await ref.read(authControllerProvider.notifier).signOut();
          if (!mounted) return;
          // Pop ALL routes to root so the auth state change can drive
          // MyApp to show LoginScreen cleanly, without stale routes on stack.
          Navigator.of(context).popUntil((route) => route.isFirst);
          widget.onLogout();
        }
      },
    );
  }

  Widget _buildResetAccountButton() {
    return SettingsDangerZone(
      onResetPressed: () {
        HapticFeedback.vibrate();
        _resetAccount();
      },
    );
  }

  Widget _buildLegalCard() {
    final theme = context.theme;

    Future<void> openUrl(String url) async {
      HapticFeedback.lightImpact();
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ListTile(
            leading:
                Icon(Icons.privacy_tip_outlined, color: theme.textSecondary),
            title: Text(
              'Politica de Privacidad',
              style: TextStyle(color: theme.textPrimary, fontSize: 15),
            ),
            trailing: Icon(
              Icons.open_in_new_rounded,
              color: theme.textMuted,
              size: 18,
            ),
            onTap: () =>
                openUrl('https://homesync-app.github.io/homesync-privacy/'),
          ),
          Divider(
            height: 1,
            color: theme.divider.withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            leading:
                Icon(Icons.description_outlined, color: theme.textSecondary),
            title: Text(
              'Terminos de Uso',
              style: TextStyle(color: theme.textPrimary, fontSize: 15),
            ),
            trailing: Icon(
              Icons.open_in_new_rounded,
              color: theme.textMuted,
              size: 18,
            ),
            onTap: () =>
                openUrl('https://homesync-app.github.io/homesync-privacy/'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAccount() async {
    final theme = context.theme;
    final confirm = await showSettingsResetAccountDialog(context);

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final res = await ref
            .read(householdRepositoryProvider)
            .resetAndClearHousehold();

        res.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${failure.message}'),
                  backgroundColor: theme.error,
                ),
              );
            }
          },
          (data) {
            if (data['success'] == true) {
              ref.invalidate(userProfileProvider);
              ref.invalidate(userBalanceProvider);
              ref.invalidate(expenseBalancesProvider);
              ref.invalidate(tasksProvider);
              ref.invalidate(recentActivityProvider);
              ref.invalidate(householdIdProvider);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('✅ Datos reiniciados y hogar liberado'),
                    backgroundColor: theme.success,
                  ),
                );
                Navigator.pop(context);
              }
            }
          },
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: theme.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Premium Card
}

class _SettingsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _SettingsHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withValues(alpha: 0.06),
            theme.scaffoldBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: theme.textPrimary,
                  size: 28,
                ),
                tooltip: 'Volver',
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'Configuracion',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 34,
                    height: 0.95,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

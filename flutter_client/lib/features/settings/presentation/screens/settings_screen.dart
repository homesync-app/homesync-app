import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/locale_provider.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/theme_palettes.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/admin_testing_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/family_role_option.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/screens/couple_split_strategy_screen.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/couple_home_tour_controller.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:homesync_client/features/settings/domain/usecases/delete_account_usecase.dart';
import 'package:homesync_client/features/settings/presentation/providers/settings_provider.dart';
import 'package:homesync_client/features/settings/presentation/widgets/faq_sheet.dart';
import 'package:homesync_client/features/settings/presentation/widgets/feedback_sheet.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_account_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_admin_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_household_components.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/family_member_dashboard_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/admin_panel.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
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
    ref.invalidate(householdMembersProvider);
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(tasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(qaAdminRecentEventsProvider);
    await ref.read(householdMembersProvider.notifier).refresh();
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
          (code) {
            setState(() => _invitationCode = code);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Codigo generado'),
                backgroundColor: AppColors.success,
              ),
            );
          },
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
    final t = AppLocalizations.of(context);

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
                            eyebrow: t.settingsSectionProfileEyebrow,
                            title: t.settingsSectionProfileTitle,
                            subtitle: t.settingsSectionProfileSubtitle,
                          ),
                          const SizedBox(height: 14),
                          _buildProfileCard(),
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            eyebrow: t.settingsSectionHouseholdEyebrow,
                            title: t.settingsSectionHouseholdTitle,
                            subtitle: t.settingsSectionHouseholdSubtitle,
                          ),
                          const SizedBox(height: 14),
                          if (_householdId != null) ...[
                            _buildCombinedHouseholdCard(),
                          ] else if (!_hasLoadedOnce && _isLoading) ...[
                            _buildLoadingCard(height: 220),
                          ] else ...[
                            _buildNoHouseholdCard(),
                          ],
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            eyebrow: t.settingsSectionAppEyebrow,
                            title: t.settingsSectionAppTitle,
                            subtitle: t.settingsSectionAppSubtitle,
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
                          const SizedBox(height: 16),
                          _buildLanguageCard(),
                          const SizedBox(height: 16),
                          if (!isMinor) ...[
                            _buildCurrencyCard(),
                            const SizedBox(height: 24),
                          ] else
                            const SizedBox(height: 8),
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
                            eyebrow: t.settingsSectionAccountEyebrow,
                            title: t.settingsSectionAccountTitle,
                            subtitle: t.settingsSectionAccountSubtitle,
                          ),
                          const SizedBox(height: 14),
                          _buildLogoutButton(),
                          const SizedBox(height: 32),
                          _buildResetAccountButton(),
                          const SizedBox(height: 48),
                          _buildSectionLabel(
                            eyebrow: t.settingsSectionLegalEyebrow,
                            title: t.settingsSectionLegalTitle,
                            subtitle: t.settingsSectionLegalSubtitle,
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
    final currentMember = ref.watch(currentMemberProvider);
    final canManageMemberRoles =
        (currentMember?.canManageHousehold ?? false) || isAdminQaUser;

    // Determinar si mostrar el toggle según tipo de hogar
    // Family NO puede ocultar tareas, los demás SÍ pueden
    final householdType = HouseholdType.fromString(_householdType);
    final showTasksToggle = householdType != HouseholdType.family;

    final members = buildSettingsHouseholdMemberData(
      context: context,
      members: _members,
      currentUserId: currentUserId,
      isAdminQaUser: isAdminQaUser,
      canManageMemberRoles: canManageMemberRoles,
      allowCurrentUserRoleEdit: _householdType != 'family',
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
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(
          t.settingsRemoveMemberTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(t.settingsRemoveMemberBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              minimumSize: const Size(100, 48), // Prevents infinite width error
            ),
            child: Text(t.settingsRemoveMemberAction),
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
              content: Text(t.settingsMemberRemoved(name)),
              backgroundColor: theme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.commonErrorWithDetails('$e')),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
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
                borderRadius: BorderRadius.circular(AppRadii.sm),
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

      ref.invalidate(householdMembersProvider);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
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
    final t = AppLocalizations.of(context);
    if (_householdType == 'family') {
      return _memberTypeLabel(
        _memberTypeFromRaw(member['member_type'] as String?),
        t,
      );
    }

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
    if (_householdType == 'family') {
      await _updateFamilyMemberType(member);
      return;
    }

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
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

  Future<void> _updateFamilyMemberType(Map<String, dynamic> member) async {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final userId = member['user_id'] as String?;
    if (userId == null || userId.isEmpty) return;

    final userData = (member['users'] is Map) ? member['users'] as Map : {};
    final name = (userData['full_name'] as String?) ??
        (userData['email'] as String?)?.split('@').first ??
        t.settingsHouseholdMemberFallbackName;
    final currentType = _memberTypeFromRaw(member['member_type'] as String?);
    final current = FamilyRoleOption.fromMember(
      displayRole: member['display_role'] as String?,
      type: currentType,
    );
    final options = _familyRoleOptionsFor(currentType);

    final selected = await AppSheet.show<FamilyRoleOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.membersRolePickerTitle(name),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.membersRolePickerSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final option in options)
                        _buildMemberTypeOption(option, current, theme, t),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected == null || selected == current) return;

    try {
      setState(() => _isLoading = true);
      final repo = ref.read(householdRepositoryProvider);
      final result = await repo.updateMemberType(
        userId,
        selected.memberType.name,
        displayRole: selected.displayRole,
      );

      result.fold(
        (failure) => throw failure,
        (_) {
          if (mounted) {
            setState(() {
              member['member_type'] = selected.memberType.name;
              member['display_role'] = selected.displayRole;
            });
            ref.invalidate(householdMembersProvider);
            ref.invalidate(currentHouseholdProvider);
            ref.invalidate(familyMemberDashboardProvider);
            ref.invalidate(homeBootstrapProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.membersRoleUpdated),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    } catch (e, stack) {
      await ref.read(adminRpcServiceProvider).logApplicationError(
        message: 'Family member role update failed',
        stackTrace: stack.toString(),
        context: {
          'source': 'settings_update_family_member_type',
          'household_type': _householdType,
          'member_user_id': userId,
          'member_name': name,
          'current_member_type': currentType.name,
          'selected_member_type': selected.memberType.name,
          'error': e.toString(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.membersRoleUpdateError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<FamilyRoleOption> _familyRoleOptionsFor(MemberType currentType) {
    return switch (currentType) {
      MemberType.child || MemberType.teen => const [
          FamilyRoleOption.teen,
          FamilyRoleOption.son,
          FamilyRoleOption.daughter,
        ],
      MemberType.parent || MemberType.guardian => const [
          FamilyRoleOption.father,
          FamilyRoleOption.mother,
          FamilyRoleOption.guardianMale,
          FamilyRoleOption.guardianFemale,
        ],
    };
  }

  Widget _buildMemberTypeOption(
    FamilyRoleOption option,
    FamilyRoleOption? current,
    AppThemeColors theme,
    AppLocalizations t,
  ) {
    final isCurrent = option == current;
    final subtitle = switch (option.memberType) {
      MemberType.parent ||
      MemberType.guardian =>
        t.membersRoleParentGuardianDesc,
      MemberType.teen => t.membersRoleTeenDesc,
      MemberType.child => t.membersRoleChildDesc,
    };

    return InkWell(
      onTap: () => Navigator.pop(context, option),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.primary.withValues(alpha: 0.08)
              : theme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isCurrent
                ? theme.primary.withValues(alpha: 0.4)
                : theme.divider.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label(t),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Icon(Icons.check_rounded, color: theme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  MemberType _memberTypeFromRaw(String? rawType) {
    return MemberType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => MemberType.parent,
    );
  }

  String _memberTypeLabel(MemberType type, AppLocalizations t) {
    return switch (type) {
      MemberType.parent => t.membersRoleParent,
      MemberType.guardian => t.membersRoleGuardian,
      MemberType.teen => t.membersRoleTeen,
      MemberType.child => t.membersRoleChild,
    };
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

  Widget _buildLanguageCard() {
    return SettingsLanguageCard(
      currentLocale: ref.watch(localeProvider),
      onLocaleChanged: (locale) {
        AppHaptics.tap();
        ref.read(localeProvider.notifier).setLocale(locale);
      },
    );
  }

  Widget _buildCurrencyCard() {
    return SettingsCurrencyCard(
      currentCurrency: ref.watch(currencyProvider),
      onCurrencyChanged: (currency) {
        AppHaptics.tap();
        ref.read(currencyProvider.notifier).setCurrency(currency);
      },
    );
  }

  Widget _buildAppearanceCard({bool isMinor = false}) {
    final isPremium = ref.watch(premiumProvider).value ?? false;
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
        AppHaptics.tap();
        ref.read(themeModeProvider.notifier).setMode(mode);
      },
      // Menores ven el candado pero no se redirigen al paywall — se les indica
      // que deben pedirle a sus padres que activen el plan.
      onLockedTap: isMinor
          ? _showMinorPremiumSnackbar
          : () => PremiumPaywall.show(context),
      onPaletteTap: (palette) {
        AppHaptics.tap();
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
    final isPremium = ref.watch(premiumProvider).value ?? false;
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsPremiumCard(
          isPremium: isPremium,
          onTapPlans: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
            );
          },
          premiumFeatures: [
            t.settingsPremiumFeatureShoppingFinanceSync,
            t.settingsPremiumFeatureRecurringPayments,
            t.premiumBenefitAdvancedStats,
            t.premiumBenefitFullCustomization,
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            AppHaptics.tap();
            FeedbackSheet.show(
              context,
              type: FeedbackType.bug,
              screen: 'settings',
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? const Color(0xFF241E1B)
                  : AppColors.primaryLight.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.isDarkMode
                    ? AppColors.primary.withValues(alpha: 0.34)
                    : AppColors.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? AppColors.primary.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.74),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: const Icon(
                    Icons.bug_report_outlined,
                    color: AppColors.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.settingsPremiumFeedbackRewardNote,
                    style: TextStyle(
                      color: theme.isDarkMode
                          ? theme.textPrimary.withValues(alpha: 0.82)
                          : theme.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
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
      ref.invalidate(householdMembersProvider);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final t = AppLocalizations.of(context);
        await _loadData();
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(t.settingsProfileNameUpdated),
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
        AppHaptics.tap();
        ref.read(notificationEnabledProvider.notifier).toggle(value);
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? t.settingsNotificationsEnabled
                  : t.settingsNotificationsDisabled,
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
      ref.invalidate(householdMembersProvider);
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
        AppHaptics.tap();
        FAQSheet.show(context);
      },
    );
  }

  Widget _buildFeedbackCard() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: () {
            AppHaptics.tap();
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
                    borderRadius: BorderRadius.circular(AppRadii.sm),
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
                        t.settingsFeedbackTitle,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.settingsFeedbackSubtitle,
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
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accentGold,
              size: 22,
            ),
          ),
          title: Text(
            t.settingsReplayTourTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          subtitle: Text(
            t.settingsReplayTourSubtitle,
            style: TextStyle(color: theme.textSecondary, fontSize: 12),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: theme.textMuted),
          onTap: () async {
            AppHaptics.tap();
            final controller =
                ref.read(coupleHomeTourControllerProvider.notifier);
            await controller.reset();
            ref.invalidate(coupleHomeTourSeenProvider);
            if (!mounted) return;
            final tasks =
                ref.read(todayTasksProvider).whenOrNull(data: (t) => t);
            controller.start(hasTasks: tasks?.isNotEmpty ?? false);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SettingsLogoutButton(
      onPressed: () async {
        AppHaptics.success();
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
        AppHaptics.error();
        _resetAccount();
      },
      onDeletePressed: () {
        AppHaptics.error();
        _deleteAccount();
      },
    );
  }

  Widget _buildLegalCard() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    Future<void> openUrl(String url) async {
      AppHaptics.tap();
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading:
                  Icon(Icons.privacy_tip_outlined, color: theme.textSecondary),
              title: Text(
                t.settingsLegalPrivacyPolicy,
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
                t.settingsLegalTermsOfUse,
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
                final t = AppLocalizations.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.settingsAccountReset),
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

  Future<void> _deleteAccount() async {
    final theme = context.theme;
    final confirm = await showSettingsDeleteAccountDialog(context);
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(deleteAccountUseCaseProvider).execute();

      if (!mounted) return;
      final t = AppLocalizations.of(context);

      switch (result.status) {
        case DeleteAccountStatus.backendFailed:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? t.settingsDeleteAccountError),
              backgroundColor: theme.error,
            ),
          );
          return;
        case DeleteAccountStatus.requiresRecentLogin:
          // Data is already purged; Firebase needs a fresh login to drop the
          // credential. Sign out so the user re-authenticates, then can retry.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.settingsDeleteAccountReauthNeeded),
              backgroundColor: theme.error,
            ),
          );
          await ref.read(authControllerProvider.notifier).signOut();
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        case DeleteAccountStatus.success:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.settingsDeleteAccountSuccess),
              backgroundColor: theme.success,
            ),
          );
          // Ensure local session is fully cleared and route back to auth.
          await ref.read(authControllerProvider.notifier).signOut();
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
      }
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

  // Premium Card
}

class _SettingsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _SettingsHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

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
                tooltip: t.settingsBackTooltip,
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Text(
                  t.settingsAppBarTitle,
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

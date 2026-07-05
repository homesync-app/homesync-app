import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/family_role_option.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/screens/couple_split_strategy_screen.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_household_components.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/family_member_dashboard_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla de detalle del hogar (Casa compartida): miembros, roles, modo de
/// tareas, invitación. Extraída del settings monolítico (fase 2) — patrón
/// list-detail. Mantiene la carga imperativa de datos crudos (_members) tal
/// cual estaba, para no cambiar comportamiento.
class HouseholdSettingsScreen extends ConsumerStatefulWidget {
  const HouseholdSettingsScreen({super.key});

  @override
  ConsumerState<HouseholdSettingsScreen> createState() =>
      _HouseholdSettingsScreenState();
}

class _HouseholdSettingsScreenState
    extends ConsumerState<HouseholdSettingsScreen> {
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
      log.e('Error loading household settings: $e', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          t.settingsSectionHouseholdTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: theme.primary,
          backgroundColor: theme.surface,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              if (_householdId != null)
                _buildCombinedHouseholdCard()
              else if (!_hasLoadedOnce && _isLoading)
                const SettingsLoadingCard(height: 220)
              else
                _buildNoHouseholdCard(),
            ],
          ),
        ),
      ),
    );
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
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.financeOnlyConfirmTitle),
        content: Text(
          t.financeOnlyConfirmBody(enabled ? 'enable' : 'disable'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.commonConfirm),
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

  Widget _buildNoHouseholdCard() {
    return SettingsNoHouseholdCard(
      onJoin: _showJoinDialog,
    );
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

  MemberType _memberTypeFromRaw(String? rawType) {
    return MemberType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => MemberType.parent,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/features/household/presentation/screens/couple_split_strategy_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/admin_testing_provider.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/theme_palettes.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/avatar_picker_sheet.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/settings/presentation/widgets/faq_sheet.dart';
import 'package:homesync_client/features/settings/presentation/providers/settings_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/shared/widgets/admin_panel.dart';

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

      final householdFuture = Supabase.instance.client
          .from('households')
          .select('name, household_type')
          .eq('id', hId)
          .maybeSingle();
      final invitationFuture = Supabase.instance.client
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
      final membersResult = householdResult[2];
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
                  backgroundColor: AppColors.error),
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
                  'Error: ${e.toString().replaceFirst("Exception: ", "")}'),
              backgroundColor: AppColors.error),
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
          const SnackBar(content: Text('Genera un codigo primero')));
      return;
    }
    String intro = '¡Hola! Te invito a unirte a nuestro hogar en HomeSync.';
    if (_householdType == 'couple') {
      intro =
          '¡Hola! Únete a mi pareja en HomeSync para organizar nuestros gastos y tareas.';
    } else if (_householdType == 'family') {
      intro = '¡Hola! Te invito a unirte a nuestro hogar familiar en HomeSync.';
    } else if (_householdType == 'friends') {
      intro = '¡Hola! Únete a nuestro grupo en HomeSync para convivir mejor.';
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
                  content: Text('No se pudo abrir WhatsApp. Codigo copiado.')),
            );
          }
        }
      }
    } catch (e) {
      _copyCode();
    }
  }

  void _showJoinDialog() {
    final codeController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          bool isLoading = false;

          Future<void> doJoin() async {
            final code = codeController.text.trim().toUpperCase();
            if (code.length != 6) {
              setDialogState(
                  () => errorText = 'El codigo debe tener 6 caracteres');
              return;
            }

            setDialogState(() {
              isLoading = true;
              errorText = null;
            });

            try {
              final result = await ref
                  .read(householdRepositoryProvider)
                  .joinHousehold(code);

              result.fold(
                (failure) {
                  setDialogState(() {
                    isLoading = false;
                    errorText = failure.message;
                  });
                },
                (success) {
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Te uniste al hogar exitosamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    _loadData();
                  }
                },
              );
            } catch (e) {
              setDialogState(() {
                isLoading = false;
                errorText = e.toString().replaceFirst('Exception: ', '');
              });
            }
          }

          return AlertDialog(
            backgroundColor: context.theme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.login_rounded,
                    color: context.theme.primary, size: 22),
                const SizedBox(width: 10),
                const Text('Unirse a un hogar'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingresa el codigo de invitacion que te compartio tu pareja:',
                  style: TextStyle(
                      color: context.theme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  textAlign: TextAlign.center,
                  enabled: !isLoading,
                  style: TextStyle(
                      fontSize: 28,
                      letterSpacing: 10,
                      fontWeight: FontWeight.w800,
                      color: context.theme.primary),
                  maxLength: 6,
                  onChanged: (_) => setDialogState(() => errorText = null),
                  onSubmitted: (_) => doJoin(),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'ABC123',
                    hintStyle: TextStyle(
                        letterSpacing: 4,
                        color: context.theme.textMuted,
                        fontSize: 22),
                    filled: true,
                    fillColor: context.theme.primary.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: context.theme.primary, width: 2),
                    ),
                    errorText: errorText,
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : doJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.primary,
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(100, 48), // Prevents infinite width error
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Unirme',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Go to home tab and pop
        ref.read(bottomNavIndexProvider.notifier).setIndex(0);
        Navigator.pop(context);
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
                    parent: BouncingScrollPhysics()),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 140,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    stretch: true,
                    backgroundColor: theme.scaffoldBackground,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
                      title: Text(
                        'Configuracion',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: -0.5,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primary.withValues(alpha: 0.05),
                              theme.scaffoldBackground,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
                          ] else if (!_hasLoadedOnce && _isLoading) ...[
                            _buildLoadingCard(height: 220),
                          ] else ...[
                            _buildNoHouseholdCard(),
                          ],
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            eyebrow: 'APP',
                            title: 'Preferencias',
                            subtitle:
                                'Tema, notificaciones y herramientas de ayuda.',
                          ),
                          const SizedBox(height: 14),
                          _buildPremiumCard(),
                          const SizedBox(height: 24),
                          _buildAppearanceCard(),
                          const SizedBox(height: 24),
                          _buildNotificationsCard(),
                          const SizedBox(height: 24),
                          if (AppEnvironment.enableAdminTesting) ...[
                            _buildAdminTestingCard(),
                            const SizedBox(height: 24),
                          ],
                          _buildFAQButton(),
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
                          GestureDetector(
                            onTap: AppEnvironment.enableAdminTesting &&
                                    ref.watch(adminProvider).isAdminUser
                                ? () => AdminPanel.show(context)
                                : null,
                            child: Opacity(
                              opacity: 0.4,
                              child: Column(
                                children: [
                                  Text(
                                    'HOMESYNC',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Version 1.0.0',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
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

  Widget _buildLoadingCard({double height = 180}) {
    final theme = context.theme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: theme.primary,
        strokeWidth: 2.5,
      ),
    );
  }

  // Profile Card

  // Profile Card

  Widget _buildSectionLabel({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: theme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.whenOrNull(data: (p) => p);
    final name = (profile?['full_name'] as String?) ?? 'Usuario';
    final email = (profile?['email'] as String?) ?? '';
    final avatar = profile?['avatar_url'] as String?;
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: theme.shadow.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar (tappable -> picker)
              GestureDetector(
                onTap: () => AvatarPickerSheet.show(context),
                child: Hero(
                  tag: 'user-profile-avatar',
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (avatar?.startsWith('premium://') == true)
                        // Premium avatar: show without circular clip
                        CustomUserAvatar(
                          name: name,
                          avatarUrl: avatar,
                          radius: 36,
                          isAnimated: true,
                          isPriority: true,
                        )
                      else
                        // Normal emoji/initial avatar with ring border
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primary.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: CustomUserAvatar(
                              name: name, avatarUrl: avatar, radius: 36),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: theme.surface, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: theme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quick actions row
          Row(
            children: [
              Expanded(
                child: _profileActionBtn(
                  icon: Icons.pets_rounded,
                  label: 'Avatar',
                  onTap: () => AvatarPickerSheet.show(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _profileActionBtn(
                  icon: Icons.badge_rounded,
                  label: 'Nombre',
                  onTap: () => _showRenameDialog(name),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedHouseholdCard() {
    final typeLabels = {
      'couple': '💑 Pareja',
      'family': '👨‍👩‍👧‍👦 Familia',
      'roommates': '🏠 Compañeros',
      'solo': '👤 Solo',
    };
    final memberCount = _members.length;
    final currentUserId = ref.read(currentUserIdProvider);
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Part
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primary.withValues(alpha: 0.08),
                  theme.primary.withValues(alpha: 0.00)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      Icon(Icons.home_rounded, color: theme.primary, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _householdName ?? 'Mi hogar',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: theme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (typeLabels[_householdType] ?? 'Hogar').toUpperCase(),
                          style: TextStyle(
                              color: theme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showEditHouseholdMenu(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.edit_note_rounded,
                          color: theme.primary, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Members Part
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MIEMBROS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: theme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '$memberCount ${memberCount == 1 ? "miembro" : "miembros"}',
                      style: TextStyle(color: theme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._members.map((member) {
                  final userData =
                      (member['users'] is Map) ? member['users'] as Map : {};
                  final rawName = (userData['full_name'] as String?) ??
                      (userData['email'] as String?)?.split('@').first ??
                      'Miembro';
                  final email = userData['email'] as String?;
                  final avatarUrl = userData['avatar_url'] as String?;
                  final role = member['role'] ?? 'member';
                  final isCurrentUser = member['user_id'] == currentUserId;
                  final isQaDummy = AppEnvironment.enableAdminTesting &&
                      ref.watch(adminProvider).isAdminUser &&
                      (email?.startsWith('qa.') ?? false) &&
                      (email?.endsWith('@homesync.local') ?? false);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CustomUserAvatar(
                          name: rawName,
                          avatarUrl: avatarUrl,
                          radius: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    rawName,
                                    style: TextStyle(
                                      fontWeight: isCurrentUser
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      fontSize: 14,
                                      color: isCurrentUser
                                          ? theme.primary
                                          : theme.textPrimary,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 6),
                                    Text(' (Tu)',
                                        style: TextStyle(
                                            color: theme.textMuted,
                                            fontSize: 12)),
                                  ],
                                ],
                              ),
                              Text(
                                _getMemberRoleLabel(member, role),
                                style: TextStyle(
                                    color: theme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        // Edit role button (only for current user or household owner)
                        if (isCurrentUser ||
                            _members.any((m) =>
                                m['user_id'] == currentUserId &&
                                m['role'] == 'owner'))
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  size: 16, color: theme.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              splashRadius: 18,
                              onPressed: () => _updateMemberRole(member),
                            ),
                          ),
                        if (role == 'owner')
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.star_rounded,
                                size: 14, color: Colors.amber),
                          ),
                        // Remove member button (only for owner, can't remove self)
                        if (_members.any((m) =>
                                m['user_id'] == currentUserId &&
                                m['role'] == 'owner') &&
                            !isCurrentUser)
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              icon: Icon(Icons.person_remove_outlined,
                                  size: 18, color: theme.error),
                              onPressed: () => _confirmRemoveMember(
                                  member['user_id'], rawName),
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                              splashRadius: 18,
                            ),
                          ),
                        if (isQaDummy && !isCurrentUser)
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              icon: Icon(Icons.delete_forever_rounded,
                                  size: 18, color: theme.error),
                              onPressed: () => _confirmDeleteDummyMember(
                                member['user_id'],
                                rawName,
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                              splashRadius: 18,
                              tooltip: 'Eliminar dummy QA',
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveMember(String userId, String name) async {
    final theme = context.theme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Quitar miembro?',
            style: TextStyle(fontWeight: FontWeight.w900)),
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
                  borderRadius: BorderRadius.circular(12)),
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
                backgroundColor: theme.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'), backgroundColor: AppColors.error),
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
        (failure) => throw Exception(failure.message),
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
        title: const Text('Nombre del hogar',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: const Text('Cancelar')),
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

      await Supabase.instance.client
          .from('households')
          .update({'name': newName}).eq('id', hId);

      if (mounted) {
        setState(() => _householdName = newName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Hogar renombrado'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _getMemberRoleLabel(Map<String, dynamic> member, String? role) {
    if (member['display_role'] != null && member['display_role'].isNotEmpty) {
      return member['display_role'];
    }
    if (role == 'owner') return 'Propietario';
    switch (_householdType) {
      case 'couple':
        return 'Pareja';
      case 'family':
        return 'Familiar';
      case 'friends':
        return 'Amigo';
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
      suggestions
          .addAll(['Padre', 'Madre', 'Hijo', 'Hija', 'Abuelo', 'Abuela']);
    } else if (_householdType == 'couple') {
      suggestions.addAll(['Pareja', 'Novio', 'Novia', 'Esposo', 'Esposa']);
    } else if (_householdType == 'friends') {
      suggestions.addAll(['Amigo', 'Compañero', 'Invitado']);
    }

    final ctrl = TextEditingController(text: currentLabel);

    final String? newRole = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Asignar Rol / Apodo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre del rol (ej: Padre)',
                filled: true,
                fillColor: theme.primary.withValues(alpha: 0.05),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Sugerencias:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: suggestions
                    .map((s) => ActionChip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          onPressed: () => ctrl.text = s,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
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
        (l) => throw Exception(l.message),
        (r) {
          if (mounted) {
            setState(() {
              member['display_role'] = newRole;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('✅ Rol actualizado'),
                  backgroundColor: AppColors.success),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditHouseholdMenu() {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _householdName ?? 'Mi hogar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.edit_rounded, color: AppColors.primary),
                ),
                title: const Text('Editar nombre'),
                subtitle: const Text('Cambia el nombre de tu hogar'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRenameHouseholdDialog();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.share_rounded,
                      color: AppColors.accentBlue),
                ),
                title: const Text('Codigo de invitacion'),
                subtitle: Text(
                  _invitationCode != null
                      ? 'Compartir o generar nuevo codigo'
                      : 'Generar codigo para invitar',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showInvitationCodeSheet();
                },
              ),
              if (_householdType == 'couple')
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.balance_rounded,
                        color: AppColors.accentTeal),
                  ),
                  title: const Text('División de gastos'),
                  subtitle: const Text('Ajustar porcentaje de pareja'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CoupleSplitStrategyScreen(),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvitationCodeSheet() {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.share_rounded, color: theme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Codigo de invitacion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Comparte este codigo para que otros se unan a tu hogar',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                if (_invitationCode != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.primary.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              _invitationCode ?? '---',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                color: theme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _shareViaWhatsApp,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('WhatsApp',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 0,
                            minimumSize: const Size(
                                120, 48), // Overrides global infinite width
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _copyCode();
                          },
                          icon: Icon(Icons.copy_rounded, color: theme.primary),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                theme.primary.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Sin codigo activo',
                        style: TextStyle(color: theme.textMuted),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      setSheetState(() {});
                      await _generateNewCode();
                      setSheetState(() {});
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(_invitationCode == null
                        ? 'Generar codigo'
                        : 'Generar nuevo codigo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primary,
                      side: BorderSide(color: theme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final currentColor = ref.watch(primaryColorProvider);
    final theme = context.theme;

    const List<ThemePalette> palettes = ThemePalette.all;
    const Set<String> freePaletteNames = {'Naranja (Original)'};
    final defaultPalette = palettes.firstWhere(
      (palette) => palette.name == 'Naranja (Original)',
      orElse: () => palettes.first,
    );
    final selectedPalette = palettes.cast<ThemePalette?>().firstWhere(
          (palette) => palette?.primary.toARGB32() == currentColor.toARGB32(),
          orElse: () => null,
        );
    final isFreeSelected = selectedPalette != null &&
        freePaletteNames.contains(selectedPalette.name);
    final effectiveColor =
        (!isPremium && !isFreeSelected) ? defaultPalette.primary : currentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Color del Tema',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary),
            ),
            const SizedBox(width: 8),
            if (!isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded,
                        size: 10, color: AppColors.accentGold),
                    SizedBox(width: 4),
                    Text('PREMIUM',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentGold)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: palettes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final palette = palettes[index];
              final isSelected =
                  effectiveColor.toARGB32() == palette.primary.toARGB32();
              final isFreePalette = freePaletteNames.contains(palette.name);
              final isLocked = !isPremium && !isFreePalette;

              return GestureDetector(
                onTap: () {
                  if (isLocked) {
                    PremiumPaywall.show(context);
                  } else {
                    HapticFeedback.lightImpact();
                    ref
                        .read(primaryColorProvider.notifier)
                        .setColor(palette.primary);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: theme.surface, width: 3)
                        : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: palette.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : (isLocked)
                          ? Icon(Icons.lock_outline_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 18)
                          : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showRenameDialog(String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final theme = context.theme;
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cambiar nombre',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primary, width: 2),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == currentName) return;

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null || userId.isEmpty) return;

      await Supabase.instance.client
          .from('users')
          .update({'full_name': newName}).eq('id', userId);

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
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildNoHouseholdCard() {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: theme.shadow.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.group_add_rounded, size: 40, color: theme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Comienza tu equipo!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: theme.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Unite a un equipo existente con un codigo de invitacion para empezar a compartir tareas y gastos.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _showJoinDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login_rounded, size: 20),
                SizedBox(width: 12),
                Text('Unirse con codigo',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: theme.shadow.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: theme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apariencia',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary)),
                    Text('Elige el tema visual de la app',
                        style: TextStyle(
                            color: theme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildColorPicker(ref),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    final isEnabled = ref.watch(notificationEnabledProvider);
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: theme.shadow.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: theme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notificaciones',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary)),
                    Text('Recibe avisos de gastos y tareas',
                        style: TextStyle(
                            color: theme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                activeTrackColor: theme.primary,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  ref.read(notificationEnabledProvider.notifier).toggle(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? '🔔 Notificaciones activadas'
                          : '🔕 Notificaciones desactivadas'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: value ? theme.success : theme.textMuted,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTestingCard() {
    final theme = context.theme;
    final admin = ref.watch(adminProvider);
    final selectedScenario =
        AdminTestingConfig.scenarioByHouseholdId(admin.selectedHouseholdId);

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
                    onPressed: () => AdminPanel.show(context),
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
                  child: _buildAdminScenarioTile(scenario, admin),
                ),
              ),
              if (selectedScenario != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(adminProvider.notifier)
                            .openOnboardingPreview();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: const Text('Onboarding'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showAdminAddDummyMemberDialog(selectedScenario),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Agregar miembro'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _resetAdminScenario(selectedScenario),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Resetear seed'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Tip: eliminá miembros desde la sección "Miembros" de este mismo hogar QA.',
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

  Future<void> _resetAdminScenario(AdminTestingScenario scenario) async {
    setState(() => _isLoading = true);
    try {
      final result =
          await ref.read(householdRepositoryProvider).qaResetScenario(
                scenario.householdId,
              );

      result.fold(
        (failure) => throw Exception(failure.message),
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
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final avatarCtrl = TextEditingController();
    String selectedRole = 'member';

    final payload = await showDialog<Map<String, String?>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
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
        ),
      ),
    );

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
        (failure) => throw Exception(failure.message),
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

  Widget _buildAdminScenarioTile(
    AdminTestingScenario scenario,
    AdminState admin,
  ) {
    final theme = context.theme;
    final isSelected = admin.selectedHouseholdId == scenario.householdId;

    final (icon, color) = switch (scenario.householdType) {
      HouseholdType.solo => (Icons.person_rounded, Colors.blue),
      HouseholdType.couple => (Icons.favorite_rounded, Colors.pink),
      HouseholdType.friends => (Icons.group_rounded, Colors.orange),
      HouseholdType.family => (Icons.family_restroom_rounded, Colors.green),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          ref.read(adminProvider.notifier).setAdminScenario(scenario);
          await _refreshAdminScenarioState();
          await _loadData();
        },
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

  Widget _buildFAQButton() {
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
              offset: const Offset(0, 8)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              Icon(Icons.help_outline_rounded, color: theme.primary, size: 22),
        ),
        title: Text('Preguntas Frecuentes',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary)),
        subtitle: Text('Aprende como funciona HomeSync',
            style: TextStyle(color: theme.textSecondary, fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.textMuted),
        onTap: () {
          HapticFeedback.lightImpact();
          FAQSheet.show(context);
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    final theme = context.theme;
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: theme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text('Cerrar sesion?',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              content: const Text(
                  'Vas a tener que iniciar sesion de nuevo para acceder a tu hogar.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Cerrar sesion',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ref.read(authControllerProvider.notifier).signOut();
            if (!mounted) return;
            Navigator.of(context).pop();
            widget.onLogout();
          }
        },
        style: OutlinedButton.styleFrom(
          side:
              BorderSide(color: theme.error.withValues(alpha: 0.2), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          foregroundColor: theme.error,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 22),
            SizedBox(width: 12),
            Text(
              'Cerrar Sesion',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetAccountButton() {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'ZONA DE PELIGRO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: theme.error,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 62,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.vibrate();
              _resetAccount();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: theme.error.withValues(alpha: 0.2), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              foregroundColor: theme.error,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_forever_rounded, size: 22),
                SizedBox(width: 12),
                Text(
                  'Reiniciar Datos de Cuenta',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _resetAccount() async {
    final theme = context.theme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.error),
            const SizedBox(width: 12),
            Text('Reiniciar todo?',
                style:
                    TextStyle(fontWeight: FontWeight.w900, color: theme.error)),
          ],
        ),
        content: const Text(
            'Esta accion borrara todas tus tareas, gastos y progreso de forma permanente, y te quitara del hogar actual para que puedas configurar uno nuevo o unirte a otro.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Reiniciar',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );

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
                    backgroundColor: theme.error),
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
                      content:
                          const Text('✅ Datos reiniciados y hogar liberado'),
                      backgroundColor: theme.success),
                );
                // Return true to signal MainScreen to re-check setup
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

  Widget _buildPremiumCard() {
    final isPremium = ref.watch(premiumProvider);
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [
                  const Color(0xFFFDE68A),
                  const Color(0xFFF59E0B).withValues(alpha: 0.1)
                ]
              : [
                  theme.primary.withValues(alpha: 0.05),
                  theme.surface,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isPremium
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
              : theme.border.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? const Color(0xFFF59E0B) : theme.shadow)
                .withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPremium
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                      : theme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPremium
                      ? Icons.auto_awesome_rounded
                      : Icons.star_outline_rounded,
                  color: isPremium ? const Color(0xFFB45309) : theme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOMESYNC PREMIUM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isPremium
                            ? const Color(0xFF92400E)
                            : theme.textPrimary,
                      ),
                    ),
                    Text(
                      'Modo simulador para testing',
                      style: TextStyle(
                        fontSize: 12,
                        color: isPremium
                            ? const Color(0xFFB45309).withValues(alpha: 0.8)
                            : theme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PremiumPaywallScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isPremium ? const Color(0xFFF59E0B) : theme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(isPremium ? 'Gestionar' : 'Ver Planes'),
              ),
            ],
          ),
          if (isPremium) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Funciones habilitadas:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB45309),
              ),
            ),
            const SizedBox(height: 8),
            _buildPremiumFeatureItem('Sincronizacion Shopping a Finanzas'),
            _buildPremiumFeatureItem('Pagos Recurrentes (Suscripciones)'),
            _buildPremiumFeatureItem('Notas de Amor en Dashboard'),
            _buildPremiumFeatureItem('Avatares Exclusivos'),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 14, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

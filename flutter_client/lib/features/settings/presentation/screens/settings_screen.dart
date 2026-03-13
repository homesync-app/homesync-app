import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/features/household/presentation/screens/couple_split_strategy_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/avatar_picker_sheet.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/shared/widgets/mercadopago_settings_card.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/settings/presentation/widgets/faq_sheet.dart';
import 'package:homesync_client/features/settings/presentation/providers/settings_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final householdMember = await Supabase.instance.client
          .from('household_members')
          .select('household_id, role')
          .eq('user_id', user.id)
          .maybeSingle();

      if (householdMember == null) {
        setState(() => _isLoading = false);
        return;
      }

      final hId = householdMember['household_id'];
      if (hId == null) {
        setState(() => _isLoading = false);
        return;
      }
      _householdId = hId;

      final household = await Supabase.instance.client
          .from('households')
          .select('name, household_type')
          .eq('id', hId)
          .maybeSingle();

      final invitation = await Supabase.instance.client
          .from('household_invitations')
          .select('code')
          .eq('household_id', hId)
          .isFilter('used_at', null)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final membersResult =
          await ref.read(householdRepositoryProvider).getHouseholdMembersRaw();
      final membersList = membersResult.getOrElse((failure) {
        log.e('Error loading members: ${failure.message}');
        return [];
      });

      setState(() {
        _householdName = household?['name'];
        _householdType = household?['household_type'];
        _invitationCode = invitation?['code'];
        _members = List<Map<String, dynamic>>.from(membersList);
        _isLoading = false;
      });
    } catch (e) {
      log.e('Error loading settings: $e', error: e);
      setState(() => _isLoading = false);
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
                backgroundColor: AppColors.error
              ),
            );
          },
          (code) => setState(() => _invitationCode = code),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Código generado'),
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
        content: Text('📋 Código copiado al portapapeles'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    if (_invitationCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Genera un código primero')));
      return;
    }
    final text =
        '¡Hola! Únete a nuestro hogar en HomeSync.\n\nDescarga la app e ingresa este código: *$_invitationCode*\n\n🏡 Organizemos nuestro hogar juntos.';
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
                  content: Text('No se pudo abrir WhatsApp. Código copiado.')),
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
                  () => errorText = 'El código debe tener 6 caracteres');
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
                        content: Text('🎉 ¡Te uniste al hogar exitosamente!'),
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.login_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text('Unirse a un hogar'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresá el código de invitación que te compartió tu pareja:',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  textAlign: TextAlign.center,
                  enabled: !isLoading,
                  style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                  maxLength: 6,
                  onChanged: (_) => setDialogState(() => errorText = null),
                  onSubmitted: (_) => doJoin(),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'ABC123',
                    hintStyle: const TextStyle(
                        letterSpacing: 4,
                        color: AppColors.textMuted,
                        fontSize: 22),
                    filled: true,
                    fillColor: AppColors.primary.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
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
                  backgroundColor: AppColors.primary,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
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
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
                      title: Text(
                        'Configuración',
                        style: TextStyle(
                          color:
                              Theme.of(context).textTheme.headlineMedium?.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: -0.5,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.05),
                              Theme.of(context).scaffoldBackgroundColor,
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
                          _buildProfileCard(),
                          const SizedBox(height: 24),
                          if (_householdId != null) ...[
                            _buildCombinedHouseholdCard(),
                          ] else ...[
                            _buildNoHouseholdCard(),
                          ],
                          const SizedBox(height: 24),
                          const MercadoPagoSettingsCard(),
                          const SizedBox(height: 24),
                          _buildAppearanceCard(),
                          const SizedBox(height: 24),
                          _buildNotificationsCard(),
                          const SizedBox(height: 24),
                          _buildFAQButton(),
                          const SizedBox(height: 48),
                          _buildLogoutButton(),
                          const SizedBox(height: 32),
                          _buildResetAccountButton(),
                          const SizedBox(height: 48),
                          Opacity(
                            opacity: 0.4,
                            child: Column(
                              children: [
                                const Text(
                                  'HOMESYNC',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Versión 1.0.0 (Building with ❤️)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Profile Card ──────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.whenOrNull(data: (p) => p);
    final name = (profile?['full_name'] as String?) ?? 'Usuario';
    final email = (profile?['email'] as String?) ?? '';
    final avatar = profile?['avatar_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar (tappable → picker)
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
                              color: AppColors.primary.withValues(alpha: 0.3),
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
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).cardColor, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
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
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.00)
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _householdName ?? 'Mi hogar',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (typeLabels[_householdType] ?? 'Hogar').toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
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
                      child: const Icon(Icons.edit_note_rounded,
                          color: AppColors.primary, size: 28),
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
                    const Text(
                      'MIEMBROS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '$memberCount ${memberCount == 1 ? "miembro" : "miembros"}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
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
                  final avatarUrl = userData['avatar_url'] as String?;
                  final role = member['role'] ?? 'member';
                  final isCurrentUser = member['user_id'] == currentUserId;

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
                                          ? AppColors.primary
                                          : null,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 6),
                                    const Text(' (Tú)',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12)),
                                  ],
                                ],
                              ),
                              Text(
                                role == 'owner' ? 'Propietario' : 'Miembro',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11),
                              ),
                            ],
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
                          IconButton(
                            icon: const Icon(Icons.person_remove_outlined,
                                size: 18, color: AppColors.error),
                            onPressed: () => _confirmRemoveMember(
                                member['user_id'], rawName),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
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
              backgroundColor: AppColors.error,
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
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showRenameHouseholdDialog() async {
    final ctrl = TextEditingController(text: _householdName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            fillColor: AppColors.primary.withValues(alpha: 0.05),
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
              backgroundColor: AppColors.primary,
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

  void _showEditHouseholdMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _householdName ?? 'Mi hogar',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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
                title: const Text('Código de invitación'),
                subtitle: Text(
                  _invitationCode != null
                      ? 'Compartir o generar nuevo código'
                      : 'Generar código para invitar',
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.share_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text(
                      'Código de invitación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Compartí este código para que otros se unan a tu hogar',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                if (_invitationCode != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1)),
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
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                color: AppColors.primary,
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
                            backgroundColor: AppColors.primary,
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
                          icon: const Icon(Icons.copy_rounded,
                              color: AppColors.primary),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Sin código activo',
                        style: TextStyle(color: AppColors.textMuted),
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
                        ? 'Generar código'
                        : 'Generar nuevo código'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
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

  Future<void> _showRenameDialog(String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
              backgroundColor: AppColors.primary,
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
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('users')
          .update({'full_name': newName}).eq('id', user.id);

      // Invalidate profile cache so header updates
      ref.invalidate(userProfileProvider);

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
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_add_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Comienza tu equipo!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Unite a un equipo existente con un código de invitación para empezar a compartir tareas y gastos.',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _showJoinDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
                Text('Unirse con código',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apariencia',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Elige el tema visual de la app',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _themeBtn(ThemeMode.light, '☀️ Claro', Icons.light_mode_rounded,
                  themeMode),
              const SizedBox(width: 8),
              _themeBtn(ThemeMode.dark, '🌙 Oscuro', Icons.dark_mode_rounded,
                  themeMode),
              const SizedBox(width: 8),
              _themeBtn(ThemeMode.system, '⚙️ Sistema',
                  Icons.settings_suggest_rounded, themeMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themeBtn(
      ThemeMode mode, String label, IconData icon, ThemeMode current) {
    final isSelected = current == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(themeModeProvider.notifier).setMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    final isEnabled = ref.watch(notificationEnabledProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notificaciones',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Recibe avisos de gastos y tareas',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  ref.read(notificationEnabledProvider.notifier).toggle(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? '🔔 Notificaciones activadas'
                          : '🔕 Notificaciones desactivadas'),
                      duration: const Duration(seconds: 2),
                      backgroundColor:
                          value ? AppColors.success : AppColors.textMuted,
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

  Widget _buildFAQButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.help_outline_rounded,
              color: AppColors.primary, size: 22),
        ),
        title: const Text('Preguntas Frecuentes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        subtitle: const Text('Aprende cómo funciona HomeSync',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: () {
          HapticFeedback.lightImpact();
          FAQSheet.show(context);
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text('¿Cerrar sesión?',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              content: const Text(
                  'Vas a tener que iniciar sesión de nuevo para acceder a tu hogar.'),
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
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Cerrar sesión',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ref.read(authControllerProvider.notifier).signOut();
            widget.onLogout();
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.2), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          foregroundColor: AppColors.error,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 22),
            SizedBox(width: 12),
            Text(
              'Cerrar Sesión',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'ZONA DE PELIGRO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.error,
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
                  color: AppColors.error.withValues(alpha: 0.2), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              foregroundColor: AppColors.error,
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('¿Reiniciar todo?',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.error)),
          ],
        ),
        content: const Text(
            'Esta acción borrará todas tus tareas, gastos y progreso de forma permanente, y te quitará del hogar actual para que puedas configurar uno nuevo o unirte a otro.'),
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
                  backgroundColor: AppColors.error,
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
                    backgroundColor: AppColors.error),
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
              const SnackBar(
                  content: Text('✅ Datos reiniciados y hogar liberado'),
                  backgroundColor: AppColors.success),
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
            SnackBar(
                content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

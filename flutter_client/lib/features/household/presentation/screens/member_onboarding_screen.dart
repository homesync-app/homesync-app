import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/widgets/app_background.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';

class MemberOnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const MemberOnboardingScreen({required this.onComplete, super.key});

  @override
  ConsumerState<MemberOnboardingScreen> createState() =>
      _MemberOnboardingScreenState();
}

class _MemberOnboardingScreenState extends ConsumerState<MemberOnboardingScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  String _selectedDisplayRole = 'Padre';
  String _selectedMemberType = 'parent';
  List<String> _availableRoles = [];
  bool _isLoadingRoles = false;
  bool _isSaving = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _loadHouseholdType();
  }

  Future<void> _loadHouseholdType() async {
    try {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) return;
      final client = ref.read(supabaseClientProvider);
      final result = await client
          .from('households')
          .select('household_type')
          .eq('id', householdId)
          .maybeSingle();
      if (result != null && mounted) {
        final hType = result['household_type'] as String?;
        if (hType == 'family') {
          await _loadAvailableRoles(householdId);
        } else {
          setState(() {
            _availableRoles = ['Adulto'];
            _selectedDisplayRole = 'Adulto';
            _selectedMemberType = 'parent';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadAvailableRoles(String householdId) async {
    setState(() => _isLoadingRoles = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final result = await client.rpc('get_available_family_roles',
          params: {'p_household_id': householdId});
      final roles =
          result == null ? <String>[] : (result as List).cast<String>();
      if (roles.isEmpty) {
        log.w('get_available_family_roles returned empty, using safe defaults');
        if (mounted) {
          setState(() {
            _availableRoles = ['Tutor/a', 'Adolescente', 'Hijo/a'];
            _selectedDisplayRole = 'Tutor/a';
            _selectedMemberType = 'parent';
          });
        }
      } else if (mounted) {
        setState(() {
          _availableRoles = roles;
          _selectedDisplayRole = roles.first;
          _updateMemberTypeFromRole(_selectedDisplayRole);
        });
      }
    } catch (e) {
      log.w('Failed to load available roles, using safe defaults: $e');
      if (mounted) {
        setState(() {
          _availableRoles = ['Tutor/a', 'Adolescente', 'Hijo/a'];
          _selectedDisplayRole = 'Tutor/a';
          _selectedMemberType = 'parent';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingRoles = false);
    }
  }

  void _updateMemberTypeFromRole(String displayRole) {
    final lower = displayRole.toLowerCase();
    if (lower.contains('adolesc')) {
      _selectedMemberType = 'teen';
    } else if (lower.contains('hij')) {
      _selectedMemberType = 'child';
    } else {
      _selectedMemberType = 'parent';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    HapticFeedback.mediumImpact();
    _fadeController.reset();
    setState(() => _step = step);
    _fadeController.forward();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);
    HapticFeedback.heavyImpact();

    try {
      final client = ref.read(supabaseClientProvider);

      final rpcResult = await client.rpc(
        'complete_member_onboarding',
        params: {
          'p_member_type': _selectedMemberType,
          'p_display_role': _selectedDisplayRole,
        },
      ).catchError((e) {
        log.e('Error in complete_member_onboarding RPC: $e');
        throw e;
      });

      if (rpcResult is Map<String, dynamic> && rpcResult['ok'] == false) {
        final errorMsg = rpcResult['error'] as String? ?? 'Error desconocido';
        log.w('complete_member_onboarding returned error: $errorMsg');
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
        return;
      }

      ref.invalidate(memberOnboardingProvider);
      ref.invalidate(householdMembersNotifierProvider);
      ref.invalidate(householdMembersProvider);
      ref.invalidate(userProfileProvider);

      if (mounted) widget.onComplete();
    } catch (e) {
      log.e('Error completing onboarding: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar. Intentá de nuevo.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppBackground(isDarkMode: theme.isDarkMode),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _step == 0
                    ? _buildWelcomeStep(theme)
                    : _buildRoleStep(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep(AppThemeColors theme) {
    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.waving_hand_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              '¡Bienvenido al hogar!',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.4,
                height: 0.95,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Elegí tu rol para empezar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          _buildPrimaryButton(
            text: 'Continuar',
            onPressed: () => _goToStep(1),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static const _roleConfig = {
    'Padre': (
      Icons.person_rounded,
      AppColors.primary,
      'Responsable del hogar. Administra gastos y tareas.'
    ),
    'Madre': (
      Icons.person_rounded,
      AppColors.primary,
      'Responsable del hogar. Administra gastos y tareas.'
    ),
    'Tutor/a': (
      Icons.supervisor_account_rounded,
      AppColors.primary,
      'Responsable del hogar. Administra gastos y tareas.'
    ),
    'Adulto': (
      Icons.person_rounded,
      AppColors.primary,
      'Responsable del hogar. Administra gastos y tareas.'
    ),
    'Adolescente': (
      Icons.emoji_people_rounded,
      AppColors.accentTeal,
      'Gestión personal de gastos y tareas.'
    ),
    'Hijo/a': (
      Icons.child_care_rounded,
      AppColors.accentPurple,
      'Participa con tareas y puede ganar recompensas.'
    ),
  };

  Widget _buildRoleStep(AppThemeColors theme) {
    if (_isLoadingRoles) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      key: const ValueKey('role'),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildStepEyebrow('Rol en el hogar'),
          const SizedBox(height: 10),
          const Text(
            '¿Quién sos?',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
              height: 0.95,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Elegí tu rol en el hogar.',
            style: TextStyle(
              fontSize: 15.5,
              height: 1.28,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: _availableRoles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final role = _availableRoles[index];
                final config = _roleConfig[role] ??
                    (
                      Icons.person_rounded,
                      AppColors.primary,
                      'Miembro del hogar.'
                    );
                return _buildRoleCard(
                  icon: config.$1,
                  title: role,
                  desc: config.$3,
                  isSelected: _selectedDisplayRole == role,
                  tone: config.$2,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedDisplayRole = role;
                      _updateMemberTypeFromRole(role);
                    });
                  },
                );
              },
            ),
          ),
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else
            _buildPrimaryButton(
              text: '¡Listo!',
              onPressed: _completeOnboarding,
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStepEyebrow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isSelected,
    required Color tone,
    required VoidCallback onTap,
  }) {
    return AnimatedPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? tone.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.8),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? tone.withValues(alpha: 0.08)
                  : AppColors.shadowBase.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: tone, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.84),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? tone : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? tone
                      : AppColors.border.withValues(alpha: 0.9),
                  width: 1.4,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

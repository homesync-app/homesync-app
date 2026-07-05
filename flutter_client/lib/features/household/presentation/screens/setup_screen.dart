import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'setup_steps/setup_household_config_step.dart';
import 'setup_steps/setup_identity_step.dart';
import 'setup_steps/setup_invite_code_step.dart';
import 'setup_steps/setup_mode_step.dart';
import 'setup_steps/setup_task_selection_step.dart';
import 'setup_steps/setup_team_options_step.dart';
import 'setup_steps/setup_value_prop_step.dart';
import 'setup_steps/setup_welcome_step.dart';

/// Shell del wizard de setup. La navegación y el estado del formulario viven
/// en [SetupWizardController]; acá quedan solo los side effects (crear hogar,
/// unirse por código, guardar perfil/finanzas/tareas) porque necesitan
/// `BuildContext` para snackbars y coordinar providers de sesión.
class SetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final bool isAdminPreview;

  const SetupScreen({
    required this.onComplete,
    this.isAdminPreview = false,
    super.key,
  });

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _familyHouseholdNameController = TextEditingController();

  // Email resolved from auth on init — used as name fallback when Supabase
  // session isn't ready yet (Firebase fires signedIn before session syncs).
  String? _authEmail;

  // Invite code shown to "create" users
  String? _myInviteCode;
  bool _isGeneratingCode = false;

  // Join flow state
  bool _isJoining = false;

  // TaskModel templates
  List<Category> _categories = [];
  Map<String, List<TaskTemplate>> _templatesByCategory = {};
  bool _isLoadingTemplates = true;
  bool _isSaving = false;
  TemplateService get _templateService => ref.read(templateServiceProvider);

  SetupWizardController get _wizard =>
      ref.read(setupWizardControllerProvider.notifier);
  SetupWizardState get _wizardState => ref.read(setupWizardControllerProvider);

  static const _initialTaskCategoryPriority = <String, int>{
    'limpieza': 1,
    'baño': 2,
    'bano': 2,
    'cocina': 3,
    'ropa': 4,
    'residuos': 5,
    'sala': 6,
    'dormitorio': 7,
    'compras': 8,
    'mascotas': 9,
    'exterior': 10,
    'mantenimiento': 11,
    'niños': 12,
    'ninos': 12,
    'administracion': 13,
  };

  @override
  void initState() {
    super.initState();
    // Provider mutations can't happen while the tree is building; defer the
    // seeding of wizard state (avatar/templates) to after the first frame.
    Future.microtask(() {
      if (!mounted) return;
      _wizard.setAvatarEmoji(
        UserAvatar.defaultAvatars.first['emoji'] as String,
      );
      _prefillIdentityFromAuth();
    });
    _loadTemplates();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _familyHouseholdNameController.dispose();
    super.dispose();
  }

  void _prefillIdentityFromAuth() {
    final currentUser = ref.read(currentUserProvider);
    // currentUser may be null if the Supabase session is still being established
    // (Firebase auth fires signedIn before _syncSupabaseWithEmailPassword completes).
    // We store the email as a fallback so _saveAndComplete can still derive a name.
    _authEmail = currentUser?.email;

    // Prefer Firebase user data (available immediately, even before Supabase session).
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final photoUrl = firebaseUser.photoURL;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        _wizard.setAvatarUrl(photoUrl);
      }

      final displayName = firebaseUser.displayName;
      final firstName = _firstNameFromDisplayName(displayName);
      if (firstName != null) {
        _nameController.text = firstName;
      }
      if (_nameController.text.trim().isNotEmpty || currentUser == null) return;
    }

    // Fallback: use Supabase user metadata (email/password sign-in).
    if (currentUser == null) return;

    final metadata = currentUser.userMetadata ?? const <String, dynamic>{};
    final profileImage = [
      currentUser.userMetadata?['avatar_url'],
      currentUser.userMetadata?['picture'],
      currentUser.userMetadata?['photo_url'],
    ].whereType<String>().map((value) => value.trim()).firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => '',
        );

    final displayName = [
      metadata['full_name'],
      metadata['name'],
    ].whereType<String>().map((value) => value.trim()).firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => '',
        );

    if (displayName.isNotEmpty) {
      _nameController.text = _firstNameFromDisplayName(displayName) ?? '';
    }

    if (profileImage.isNotEmpty) {
      _wizard.setAvatarUrl(profileImage);
    }
  }

  String? _firstNameFromDisplayName(String? displayName) {
    final firstName = displayName?.trim().split(RegExp(r'\s+')).first.trim();
    return firstName == null || firstName.isEmpty ? null : firstName;
  }

  List<Category> _sortInitialTaskCategories(List<Category> categories) {
    return [...categories]..sort((a, b) {
        final aPriority =
            _initialTaskCategoryPriority[a.id.toLowerCase()] ?? a.sortOrder;
        final bPriority =
            _initialTaskCategoryPriority[b.id.toLowerCase()] ?? b.sortOrder;
        final priorityCompare = aPriority.compareTo(bPriority);
        if (priorityCompare != 0) return priorityCompare;
        return a.sortOrder.compareTo(b.sortOrder);
      });
  }

  Future<void> _loadTemplates() async {
    try {
      final categories = await _templateService.getCategories();
      final templates = await _templateService.getTemplates();

      final templatesByCategory = <String, List<TaskTemplate>>{};
      for (final template in templates) {
        templatesByCategory.putIfAbsent(template.categoryId, () => []);
        templatesByCategory[template.categoryId]!.add(template);
      }

      if (!mounted) return;
      _wizard.seedSelectedTemplates(
        templates.where((t) => t.isPopular).map((t) => t.id),
      );

      setState(() {
        _categories = _sortInitialTaskCategories(categories);
        _templatesByCategory = templatesByCategory;
        _isLoadingTemplates = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingTemplates = false);
    }
  }

  Future<bool> _isTasksEnabledForCurrentHousehold() async {
    final currentHousehold = ref.read(currentHouseholdProvider).value;
    if (currentHousehold != null) {
      return currentHousehold.tasksEnabled;
    }

    try {
      final household = await ref.read(currentHouseholdProvider.future);
      return household?.tasksEnabled ?? true;
    } catch (error, stackTrace) {
      log.w(
        'SetupScreen: fallback to tasks enabled during onboarding',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    }
  }

  Future<void> _advanceToTaskSelectionOrComplete() async {
    final tasksEnabled = await _isTasksEnabledForCurrentHousehold();
    if (!mounted) return;

    if (tasksEnabled) {
      _wizard.goTo(SetupStep.taskSelection);
      return;
    }

    await _saveAndComplete();
  }

  // -- Step handlers ----------------------------------------------------------

  void _onModeSelected() {
    HapticFeedback.mediumImpact();
    if (_wizardState.selectedMode == 'family' &&
        _familyHouseholdNameController.text.trim().isEmpty) {
      _familyHouseholdNameController.text = _suggestFamilyHouseholdName();
    }
    _wizard.confirmMode();
  }

  String _suggestFamilyHouseholdName() {
    final rawName = _nameController.text.trim();
    if (rawName.isEmpty) {
      return AppLocalizations.of(context).setupFamilyDefaultName;
    }

    final firstName = rawName.split(' ').first.trim();
    return '$firstName y familia';
  }

  Future<void> _handleCreateTeam() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isGeneratingCode = true;
    });

    try {
      final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      final mode = _wizardState.selectedMode ?? 'couple';
      // Mark setup as in-progress BEFORE creating the household. Creating it
      // makes householdId non-null, which would otherwise make MainScreen swap
      // this wizard out for Home/MemberOnboarding before the remaining steps
      // (profile save, finance, tasks) run.
      ref.read(setupInProgressProvider.notifier).begin();
      final householdId =
          await firebaseAuthService.createHouseholdForUser(mode);
      if (householdId == null || householdId.isEmpty) {
        throw Exception('No se pudo crear el hogar');
      }
      _invalidateHouseholdSession();

      final result =
          await ref.read(generateInvitationCodeUseCaseProvider).call();
      if (mounted) {
        result.fold(
          (failure) {
            setState(() => _isGeneratingCode = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)
                      .commonErrorWithDetails(failure.message),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (code) {
            setState(() {
              _myInviteCode = code;
              _isGeneratingCode = false;
            });
            _wizard.goTo(SetupStep.inviteCode);
          },
        );
      }
    } catch (e) {
      // Creation failed — clear the in-progress guard so the router can show
      // the normal setup entry point again instead of being stuck.
      ref.read(setupInProgressProvider.notifier).finish();
      if (mounted) {
        setState(() => _isGeneratingCode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).setupGenerateCodeError('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _invalidateHouseholdSession() {
    ref.invalidate(householdIdProvider);
    ref.invalidate(currentHouseholdProvider);
    ref.invalidate(householdCapabilitiesProvider);
  }

  void _notifySetupComplete() {
    // Setup finished — release the in-progress guard so the router resumes
    // normal household-based routing.
    ref.read(setupInProgressProvider.notifier).finish();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onComplete();
    });
  }

  String get _creatorMemberTypeForOnboarding =>
      _wizardState.selectedMode == 'family'
          ? _wizardState.creatorMemberType
          : 'parent';

  String get _creatorDisplayRoleForOnboarding =>
      _wizardState.selectedMode == 'family' ? _wizardState.familyRole : 'Adulto';

  String? _memberOnboardingErrorMessage(
    Object? rpcResult,
    String fallbackMessage,
  ) {
    if (rpcResult == false) return fallbackMessage;
    if (rpcResult is Map<String, dynamic> && rpcResult['ok'] == false) {
      return rpcResult['error'] as String? ?? fallbackMessage;
    }
    return null;
  }

  Future<String?> _ensureHouseholdForSetupCompletion({
    bool refreshSessionImmediately = true,
  }) async {
    final selectedMode = _wizardState.selectedMode ?? 'solo';
    final createNew = _wizardState.createNew;
    var householdId = await ref.read(householdIdProvider.future);

    if (householdId == null && createNew) {
      householdId = await ref
          .read(firebaseAuthServiceProvider)
          .createHouseholdForUser(selectedMode);
      if (householdId == null || householdId.isEmpty) {
        throw Exception('No se pudo crear el hogar');
      }
      if (refreshSessionImmediately) {
        _invalidateHouseholdSession();
      }
    }

    // Only update household type when the user CREATED the household.
    // Joiners don't own the household and RLS blocks the update.
    if (householdId != null &&
        _wizardState.selectedMode != null &&
        createNew) {
      final result = await ref
          .read(updateHouseholdTypeUseCaseProvider)
          .call(householdId, selectedMode);
      result.fold((failure) => throw failure, (_) {});
      if (refreshSessionImmediately) {
        _invalidateHouseholdSession();
      }
    }

    return householdId;
  }

  Future<void> _handleJoinTeam() async {
    HapticFeedback.mediumImpact();
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      _wizard.setJoinError('El código debe tener 6 caracteres');
      return;
    }

    setState(() => _isJoining = true);
    _wizard.setJoinError(null);

    try {
      final result = await ref.read(joinHouseholdUseCaseProvider).call(code);
      final joinError = result.fold<String?>(
        (failure) => failure.message,
        (_) => null,
      );
      if (joinError != null) {
        if (mounted) {
          setState(() => _isJoining = false);
          _wizard.setJoinError(joinError);
        }
        return;
      }

      if (!widget.isAdminPreview) {
        final typedName = _nameController.text.trim();
        final fallbackName =
            (_authEmail ?? ref.read(currentUserProvider)?.email)
                ?.split('@')
                .first
                .trim();
        final nameToSave = typedName.isNotEmpty ? typedName : fallbackName;
        if (nameToSave != null && nameToSave.isNotEmpty) {
          final profileResult =
              await ref.read(authRepositoryProvider).updateProfile(
                    fullName: nameToSave,
                    avatarUrl: _wizardState.resolvedAvatarValue,
                  );
          profileResult.fold(
            (failure) => log.e(
              'SetupScreen._handleJoinTeam: updateProfile failed: ${failure.message}',
            ),
            (_) => log.i(
              'SetupScreen._handleJoinTeam: updateProfile ok name="$nameToSave"',
            ),
          );
        }
      }

      ref.invalidate(householdIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(currentHouseholdProvider);
      ref.invalidate(userBalanceProvider);
      ref.invalidate(householdMembersProvider);
      ref.invalidate(memberOnboardingProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).setupSnackJoinedHousehold),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isJoining = false);
        if (!widget.isAdminPreview) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('setup_completed', true);
        }
        if (mounted) _notifySetupComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        _wizard.setJoinError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _saveFamilySetup() async {
    final defaultHouseholdName =
        AppLocalizations.of(context).setupHouseholdDefaultName;
    final householdId = await ref.read(householdIdProvider.future);
    final currentUserId = ref.read(currentUserIdProvider);
    final rawName = _familyHouseholdNameController.text.trim();
    final householdName = rawName.isNotEmpty ? rawName : defaultHouseholdName;
    final familyRole = _wizardState.familyRole;

    try {
      if (householdId != null) {
        await ref
            .read(supabaseClientProvider)
            .from('households')
            .update({'name': householdName}).eq('id', householdId);
        ref.invalidate(currentHouseholdProvider);
      }

      if (currentUserId != null && familyRole.trim().isNotEmpty) {
        final result = await ref
            .read(updateMemberDisplayRoleUseCaseProvider)
            .call(currentUserId, familyRole);
        result.fold((failure) => throw failure, (_) {});
        ref.invalidate(householdMembersProvider);
      }
    } catch (error, stackTrace) {
      log.w(
        'SetupScreen family onboarding best-effort update failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (mounted) {
      await _advanceToTaskSelectionOrComplete();
    }
  }

  Future<void> _saveFriendsSplit() async {
    try {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId != null) {
        final result = await ref
            .read(updateDefaultSplitRatioUseCaseProvider)
            .call(householdId, 0.5);
        result.fold((failure) => throw failure, (_) {});
      }
    } catch (e, st) {
      log.w(
        'Failed to update default split ratio during setup',
        error: e,
        stackTrace: st,
      );
    }
    await _advanceToTaskSelectionOrComplete();
  }

  Future<void> _saveFinanceSettings() async {
    final financeMode = _wizardState.financeMode;
    final splitRatio = _wizardState.splitRatio;
    try {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId != null) {
        final result =
            await ref.read(updateFinanceSettingsUseCaseProvider).call(
                  householdId,
                  financeMode: financeMode,
                  defaultSplitRatio:
                      financeMode == 'shared' ? 0.5 : splitRatio,
                );
        result.fold((failure) => throw failure, (_) {});
      }
    } catch (e) {
      // Ignore error
    }
    await _advanceToTaskSelectionOrComplete();
  }

  Future<void> _saveAndComplete() async {
    final t = AppLocalizations.of(context);
    final tasksEnabled = await _isTasksEnabledForCurrentHousehold();
    if (!mounted) return;
    final selectedTemplateIds = _wizardState.selectedTemplateIds;
    if (tasksEnabled && selectedTemplateIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.setupSnackPickAtLeastOneTask),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Guard the whole completion flow: for solo / "configure later" paths the
    // household is created here (inside _ensureHouseholdForSetupCompletion), so
    // keep the wizard mounted until we finish persisting profile/tasks.
    ref.read(setupInProgressProvider.notifier).begin();

    final client = ref.read(supabaseClientProvider);

    try {
      log.i(
        'SetupScreen._saveAndComplete: starting '
        'mode=${_wizardState.selectedMode ?? 'solo'} '
        'selectedTemplates=${selectedTemplateIds.length}',
      );
      final householdId = await _ensureHouseholdForSetupCompletion(
        refreshSessionImmediately: false,
      );
      if (householdId == null || householdId.isEmpty) {
        throw Exception('No se pudo resolver el hogar para finalizar setup');
      }

      if (!mounted) return;

      // Update user profile with name and avatar.
      // When the Supabase session isn't ready at init time (Firebase fires
      // signedIn before _syncSupabaseWithEmailPassword completes), the name
      // field may be empty — fall back to the email username so we always
      // persist something meaningful.
      if (!widget.isAdminPreview) {
        final typedName = _nameController.text.trim();
        final fallbackName =
            (_authEmail ?? ref.read(currentUserProvider)?.email)
                ?.split('@')
                .first
                .trim();
        final nameToSave = typedName.isNotEmpty ? typedName : fallbackName;
        log.i(
          'SetupScreen._saveAndComplete: saving profile '
          'typed="$typedName" fallback="$fallbackName" saving="$nameToSave"',
        );
        if (nameToSave != null && nameToSave.isNotEmpty) {
          final profileResult =
              await ref.read(authRepositoryProvider).updateProfile(
                    fullName: nameToSave,
                    avatarUrl: _wizardState.resolvedAvatarValue,
                  );
          profileResult.fold(
            (failure) {
              log.e(
                'SetupScreen._saveAndComplete: updateProfile failed: ${failure.message}',
              );
              throw failure;
            },
            (_) => log.i('SetupScreen._saveAndComplete: updateProfile ok'),
          );
        }
      }

      if (!mounted) return;

      if (tasksEnabled) {
        log.i(
          '_saveAndComplete: cloning ${selectedTemplateIds.length} templates',
        );
        final count = await _templateService.cloneTemplates(
          selectedTemplateIds.toList(),
          householdId: householdId,
        );
        if (count <= 0) {
          throw Exception('No se pudieron crear las tareas iniciales');
        }
        log.i('_saveAndComplete: cloned $count tasks household=$householdId');
      }

      if (!mounted) return;

      if (!widget.isAdminPreview) {
        try {
          final rpcResult = await client.rpc(
            'complete_member_onboarding',
            params: {
              'p_member_type': _creatorMemberTypeForOnboarding,
              'p_display_role': _creatorDisplayRoleForOnboarding,
            },
          );
          final onboardingError = _memberOnboardingErrorMessage(
            rpcResult,
            t.setupSnackUnknownError,
          );
          if (onboardingError != null) {
            log.w(
              'complete_member_onboarding (creator) returned: $onboardingError',
            );
            if (mounted) {
              setState(() => _isSaving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(onboardingError)),
              );
            }
            return;
          }
        } catch (e, stack) {
          log.w(
            'complete_member_onboarding (creator) failed: $e',
            error: e,
            stackTrace: stack,
          );
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.setupSnackOnboardingFailed)),
            );
          }
          return;
        }
      }

      if (!mounted) return;

      ref.invalidate(householdIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(userBalanceProvider);
      ref.invalidate(householdMembersProvider);
      ref.invalidate(memberOnboardingProvider);

      if (!widget.isAdminPreview) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('setup_completed', true);
      }
      if (mounted && !widget.isAdminPreview) {
        await _showCompletionCelebration();
      }
      if (mounted) _notifySetupComplete();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        log.e('_saveAndComplete error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.commonErrorWithDetails(e.toString())),
          ),
        );
      }
    }
  }

  /// Micro-celebración al terminar el setup: tarjeta con el acento del modo,
  /// se cierra sola a los ~1.6s (o antes con un tap) y recién ahí se navega.
  Future<void> _showCompletionCelebration() async {
    final t = AppLocalizations.of(context);
    final design = _wizardState.modeDesign;
    final modeKey = _wizardState.selectedMode ?? 'solo';
    HapticFeedback.mediumImpact();

    var dismissed = false;
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xxl),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.normal,
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Transform.scale(
            scale: 0.9 + 0.1 * value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: design.heroGradient,
              ),
              borderRadius: BorderRadius.circular(AppRadii.xxl),
              border: Border.all(
                color: design.accent.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: design.accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(design.icon, color: design.accent, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  t.setupCompletionTitle(modeKey),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: context.theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.setupCompletionMessage(modeKey),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color:
                        context.theme.textSecondary.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => dismissed = true);

    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!dismissed && mounted) {
      Navigator.of(context, rootNavigator: true).maybePop();
    }
    await dialogFuture;
  }

  void _copyCode() {
    if (_myInviteCode == null) return;
    Clipboard.setData(ClipboardData(text: _myInviteCode!));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).setupSnackCodeCopied),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    if (_myInviteCode == null) return;
    final text =
        '¡Hola! Únete a nuestro hogar en HomeSync.\n\nDescarga la app e ingresa este código: *$_myInviteCode*\n\n?? Organizemos nuestro hogar juntos.';
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
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).setupSnackWhatsappFailed,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      _copyCode();
    }
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(setupWizardControllerProvider);

    return PopScope(
      canPop: wizard.step == SetupStep.valueProp,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _wizard.goBack();
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackground,
        body: Container(
          decoration: AppTheme.backgroundGradientBox,
          child: Stack(
            children: [
              // Background decor
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentTeal.withValues(alpha: 0.035),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    _buildProgressIndicator(wizard),
                    Expanded(
                      child: Column(
                        children: [
                          if (widget.isAdminPreview)
                            Container(
                              margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.18),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.auto_fix_high_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Preview QA del onboarding. No modifica tu perfil real; sirve para configurar y testear el escenario activo.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.35,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: AppMotion.slow,
                              switchInCurve: AppMotion.standard,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.05),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: switch (wizard.step) {
                                SetupStep.valueProp =>
                                  const SetupValuePropStep(),
                                SetupStep.welcome => const SetupWelcomeStep(),
                                SetupStep.identity => SetupIdentityStep(
                                    nameController: _nameController,
                                  ),
                                SetupStep.mode =>
                                  SetupModeStep(onContinue: _onModeSelected),
                                SetupStep.teamOptions => SetupTeamOptionsStep(
                                    codeController: _codeController,
                                    isJoining: _isJoining,
                                    onCreateTeam: _handleCreateTeam,
                                    onJoinTeam: _handleJoinTeam,
                                  ),
                                SetupStep.inviteCode => SetupInviteCodeStep(
                                    inviteCode: _myInviteCode,
                                    isGeneratingCode: _isGeneratingCode,
                                    onCopyCode: _copyCode,
                                    onShareCode: _shareViaWhatsApp,
                                  ),
                                SetupStep.householdConfig =>
                                  SetupHouseholdConfigStep(
                                    familyHouseholdNameController:
                                        _familyHouseholdNameController,
                                    onSaveFamily: _saveFamilySetup,
                                    onSaveFinanceSettings: _saveFinanceSettings,
                                    onSaveFriendsSplit: _saveFriendsSplit,
                                    onSkip: _advanceToTaskSelectionOrComplete,
                                  ),
                                SetupStep.taskSelection =>
                                  SetupTaskSelectionStep(
                                    isLoadingTemplates: _isLoadingTemplates,
                                    isSaving: _isSaving,
                                    categories: _categories,
                                    templatesByCategory: _templatesByCategory,
                                    onFinish: _saveAndComplete,
                                  ),
                              },
                            ),
                          ),
                        ],
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

  Widget _buildProgressIndicator(SetupWizardState wizard) {
    // La intro (value prop) no cuenta como progreso. La cantidad de
    // segmentos es la ruta efectiva del modo elegido: solo no ve los pasos
    // de equipo/invitación/configuración, así que su barra no los muestra.
    if (wizard.progressIndex < 0) return const SizedBox(height: 8);
    final theme = context.theme;
    // Con modo elegido la barra adopta el acento de ese modo.
    final accent =
        wizard.selectedMode != null ? wizard.modeDesign.accent : theme.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: List.generate(wizard.progressTotal, (index) {
          final isActive = index <= wizard.progressIndex;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? accent
                    : theme.border.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                boxShadow: index == wizard.progressIndex
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

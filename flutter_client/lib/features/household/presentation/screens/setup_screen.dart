import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'setup_widgets.dart';

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

class _SetupScreenState extends ConsumerState<SetupScreen>
    with TickerProviderStateMixin {
  // Steps: 0=ValueProp, 1=Welcome, 2=Identity, 3=mode, 4=teamOptions,
  // 5=creating(code display), 6=household setup, 7=taskSelection
  int _currentStep = 0;
  String? _selectedMode;
  bool _createNew = true;
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _familyHouseholdNameController = TextEditingController();
  String _selectedAvatar = UserAvatar.defaultAvatars.first['emoji'] as String;
  String? _selectedAvatarUrl;
  String _familyRole = 'Padre';
  String _selectedCreatorMemberType = 'parent';

  // Email resolved from auth on init — used as name fallback when Supabase
  // session isn't ready yet (Firebase fires signedIn before session syncs).
  String? _authEmail;

  // Invite code shown to "create" users
  String? _myInviteCode;
  bool _isGeneratingCode = false;

  // Join flow state
  bool _isJoining = false;
  String? _joinError;

  // TaskModel selection
  final Set<String> _selectedTemplateIds = {};
  List<Category> _categories = [];
  Map<String, List<TaskTemplate>> _templatesByCategory = {};
  bool _isLoadingTemplates = true;
  bool _isSaving = false;
  TemplateService get _templateService => ref.read(templateServiceProvider);

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
  // Names and descriptions live in app_es.arb / app_en.arb under
  // `setupModeName` / `setupModeDescription` (ICU select on the id below).
  final List<Map<String, dynamic>> _modes = [
    {
      'id': 'couple',
      'icon': Icons.handshake_rounded,
      'gradient': [const Color(0xFFEF7A4B), const Color(0xFFFFB085)],
    },
    {
      'id': 'family',
      'icon': Icons.family_restroom_rounded,
      'gradient': [const Color(0xFFEE652B), const Color(0xFFFF8F5F)],
    },
    {
      'id': 'friends',
      'icon': Icons.groups_rounded,
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF7DD3FC)],
    },
    {
      'id': 'solo',
      'icon': Icons.task_alt_rounded,
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFFC4B5FD)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _prefillIdentityFromAuth();
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
        _selectedAvatarUrl = photoUrl;
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
      _selectedAvatarUrl = profileImage;
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

  String get _resolvedAvatarValue => _selectedAvatarUrl ?? _selectedAvatar;

  Color get _resolvedAvatarAccentColor {
    final value = _resolvedAvatarValue;
    if (value.startsWith('http') || value.startsWith('assets/')) {
      return AppColors.primary.withValues(alpha: 0.16);
    }
    return UserAvatar.getColorForEmoji(value);
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

      for (final template in templates) {
        if (template.isPopular) {
          _selectedTemplateIds.add(template.id);
        }
      }

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
      setState(() => _currentStep = 7);
      return;
    }

    await _saveAndComplete();
  }

  // -- Step handlers ----------------------------------------------------------

  void _onModeSelected() {
    HapticFeedback.mediumImpact();
    if (_selectedMode == 'family' &&
        _familyHouseholdNameController.text.trim().isEmpty) {
      _familyHouseholdNameController.text = _suggestFamilyHouseholdName();
    }
    if (_selectedMode == 'solo') {
      setState(() => _currentStep = 7);
    } else {
      setState(() => _currentStep = 4);
    }
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
      final mode = _selectedMode ?? 'couple';
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
                content: Text('Error: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (code) {
            setState(() {
              _myInviteCode = code;
              _isGeneratingCode = false;
              _currentStep = 5; // Mostrar código
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingCode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar código: $e'),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onComplete();
    });
  }

  Future<String?> _ensureHouseholdForSetupCompletion() async {
    final selectedMode = _selectedMode ?? 'solo';
    var householdId = await ref.read(householdIdProvider.future);

    if (householdId == null && _createNew) {
      householdId = await ref
          .read(firebaseAuthServiceProvider)
          .createHouseholdForUser(selectedMode);
      if (householdId == null || householdId.isEmpty) {
        throw Exception('No se pudo crear el hogar');
      }
      _invalidateHouseholdSession();
    }

    // Only update household type when the user CREATED the household.
    // Joiners don't own the household and RLS blocks the update.
    if (householdId != null && _selectedMode != null && _createNew) {
      final result = await ref
          .read(updateHouseholdTypeUseCaseProvider)
          .call(householdId, _selectedMode!);
      result.fold((failure) => throw failure, (_) {});
      _invalidateHouseholdSession();
    }

    return householdId;
  }

  Future<void> _handleJoinTeam() async {
    HapticFeedback.mediumImpact();
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _joinError = 'El código debe tener 6 caracteres');
      return;
    }

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      final result = await ref.read(joinHouseholdUseCaseProvider).call(code);
      final joinError = result.fold<String?>(
        (failure) => failure.message,
        (_) => null,
      );
      if (joinError != null) {
        if (mounted) {
          setState(() {
            _isJoining = false;
            _joinError = joinError;
          });
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
                    avatarUrl: _resolvedAvatarValue,
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
        setState(() {
          _isJoining = false;
          _joinError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _saveAndComplete() async {
    final t = AppLocalizations.of(context);
    final tasksEnabled = await _isTasksEnabledForCurrentHousehold();
    if (!mounted) return;
    if (tasksEnabled && _selectedTemplateIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.setupSnackPickAtLeastOneTask),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final client = ref.read(supabaseClientProvider);

    try {
      await _ensureHouseholdForSetupCompletion();

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
                    avatarUrl: _resolvedAvatarValue,
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
          '_saveAndComplete: cloning ${_selectedTemplateIds.length} templates',
        );
        final count = await _templateService
            .cloneTemplates(_selectedTemplateIds.toList());
        log.i('_saveAndComplete: cloned $count tasks');
      }

      if (!mounted) return;

      if (!widget.isAdminPreview) {
        try {
          final rpcResult = await client.rpc(
            'complete_member_onboarding',
            params: {
              'p_member_type': _selectedCreatorMemberType,
              'p_display_role': _familyRole,
            },
          );
          if (rpcResult is Map<String, dynamic> && rpcResult['ok'] == false) {
            final errorMsg =
                rpcResult['error'] as String? ?? t.setupSnackUnknownError;
            log.w('complete_member_onboarding (creator) returned: $errorMsg');
            if (mounted) {
              setState(() => _isSaving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMsg)),
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
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
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
                    _buildProgressIndicator(),
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
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.easeOutQuart,
                              switchOutCurve: Curves.easeInQuart,
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
                              child: switch (_currentStep) {
                                0 => _buildValuePropStepV3(),
                                1 => _buildWelcomeStepV5(),
                                2 => _buildIdentityStepV3(),
                                3 => _buildModeSelectionV3(),
                                4 => _buildTeamOptionsV3(),
                                5 => _buildInviteCodeStepV2(),
                                6 => _buildHouseholdSetupStepV2(),
                                7 => _buildTaskSelectionV2(),
                                _ => _buildValuePropStepV3(),
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

  Widget _buildProgressIndicator() {
    // Only show progress from step 1 onward (step 0 is value prop / intro)
    if (_currentStep == 0) return const SizedBox(height: 8);
    const totalSteps = 7; // steps 1-7
    final activeStep = _currentStep - 1; // normalize
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= activeStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                boxShadow: index == activeStep
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
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

  Widget _buildJoinInput({
    bool showLabel = true,
    bool compact = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return FractionalTranslation(
          translation: Offset(0, 0.1 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Text(
              AppLocalizations.of(context).setupJoinCodeTitle,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            SizedBox(height: compact ? 8 : 12),
          ],
          TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 26 : 32,
              letterSpacing: compact ? 8 : 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
            maxLength: 6,
            onChanged: (_) => setState(() => _joinError = null),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'ABCDEF',
              hintStyle: TextStyle(
                letterSpacing: compact ? 5 : 8,
                color: AppColors.textMuted.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.92),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(compact ? 18 : 20),
                borderSide:
                    BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(compact ? 18 : 20),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: compact ? 18 : 24,
              ),
              errorText: _joinError,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  double _tempRatio = 0.5;

  Future<void> _saveFamilySetup() async {
    final defaultHouseholdName =
        AppLocalizations.of(context).setupHouseholdDefaultName;
    final householdId = await ref.read(householdIdProvider.future);
    final currentUserId = ref.read(currentUserIdProvider);
    final rawName = _familyHouseholdNameController.text.trim();
    final householdName = rawName.isNotEmpty ? rawName : defaultHouseholdName;

    try {
      if (householdId != null) {
        await ref
            .read(supabaseClientProvider)
            .from('households')
            .update({'name': householdName}).eq('id', householdId);
        ref.invalidate(currentHouseholdProvider);
      }

      if (currentUserId != null && _familyRole.trim().isNotEmpty) {
        final result = await ref
            .read(updateMemberDisplayRoleUseCaseProvider)
            .call(currentUserId, _familyRole);
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

  Widget _buildValuePropStepV3() {
    final t = AppLocalizations.of(context);
    final features = [
      (
        icon: Icons.checklist_rounded,
        title: t.setupFeatureTasksTitle,
        desc: t.setupFeatureTasksDesc,
        color: AppColors.primary,
      ),
      (
        icon: Icons.account_balance_wallet_rounded,
        title: t.setupFeatureExpensesTitle,
        desc: t.setupFeatureExpensesDesc,
        color: AppColors.sage,
      ),
      (
        icon: Icons.workspace_premium_rounded,
        title: t.setupFeatureGamificationTitle,
        desc: t.setupFeatureGamificationDesc,
        color: AppColors.accentGold,
      ),
      (
        icon: Icons.shopping_cart_checkout_rounded,
        title: t.setupFeatureShoppingTitle,
        desc: t.setupFeatureShoppingDesc,
        color: AppColors.accentBlue,
      ),
    ];

    return Padding(
      key: const ValueKey('value_prop_v3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            SetupStepEyebrow(text: t.setupValuePropEyebrow),
            const SizedBox(height: 12),
            const Text(
              'HomeSync',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                height: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.setupValuePropTagline,
              style: TextStyle(
                fontSize: 18,
                height: 1.45,
                color: AppColors.textSecondary.withValues(alpha: 0.88),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            ...features.asMap().entries.map((entry) {
              final index = entry.key;
              final feature = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 320 + (index * 70)),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: child,
                  ),
                ),
                child: SetupFeatureCard(
                  icon: feature.icon,
                  title: feature.title,
                  desc: feature.desc,
                  color: feature.color,
                ),
              );
            }),
            const SizedBox(height: 24),
            SetupPrimaryButton(
              text: t.setupValuePropStartButton,
              onPressed: () {
                HapticFeedback.heavyImpact();
                setState(() => _currentStep = 1);
              },
            ),
            const SizedBox(height: 12),
            Text(
              t.setupValuePropTimeHint,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStepV5() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final t = AppLocalizations.of(context);
        return SingleChildScrollView(
          key: const ValueKey('welcome_v5'),
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SetupOnboardingIllustration(
                  imagePath: 'assets/images/onboarding_welcome_cat.png',
                ),
                const SizedBox(height: 18),
                Text(
                  t.setupWelcomeTitle,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.8,
                    height: 0.94,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t.setupWelcomeBody,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.36,
                    color: AppColors.textSecondary.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SetupSupportBullet(
                  icon: Icons.timer_outlined,
                  color: AppColors.primary,
                  text: t.setupWelcomeBulletQuick,
                ),
                const SizedBox(height: 12),
                SetupSupportBullet(
                  icon: Icons.groups_2_rounded,
                  color: const Color(0xFF6FA097),
                  text: t.setupWelcomeBulletJoin,
                ),
                const SizedBox(height: 30),
                SetupPrimaryButton(
                  text: t.setupWelcomeStartButton,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    setState(() => _currentStep = 2);
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdentityStepV3() {
    final t = AppLocalizations.of(context);
    return Padding(
      key: const ValueKey('identity_v3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            SetupStepEyebrow(text: t.setupProfileEyebrow),
            const SizedBox(height: 10),
            SetupHeading(
              title: t.setupProfileTitle,
              subtitle: t.setupProfileSubtitle,
            ),
            const SizedBox(height: 32),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: _resolvedAvatarAccentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _resolvedAvatarAccentColor.withValues(alpha: 0.32),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowBase.withValues(alpha: 0.08),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomUserAvatar(
                        name: _nameController.text.trim(),
                        avatarUrl: _resolvedAvatarValue,
                        radius: 52,
                        forceCircular: true,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedAvatarUrl != null
                  ? t.setupProfileGoogleAvatarHint
                  : t.setupProfileEmptyAvatarHint,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.textSecondary.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: t.authNameHint,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.9),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.6,
                  ),
                ),
                contentPadding: const EdgeInsets.all(22),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_nameController.text.trim().isNotEmpty) {
                  setState(() => _currentStep = 3);
                }
              },
            ),
            const SizedBox(height: 22),
            Text(
              t.setupProfileAvatarLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 78,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: UserAvatar.defaultAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = UserAvatar.defaultAvatars[index];
                  final emoji = avatar['emoji'] as String;
                  final isSelected =
                      _selectedAvatarUrl == null && _selectedAvatar == emoji;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedAvatar = emoji;
                        _selectedAvatarUrl = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 68,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.84),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border.withValues(alpha: 0.9),
                          width: isSelected ? 1.8 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            SetupPrimaryButton(
              text: t.commonContinue,
              onPressed: _nameController.text.trim().isEmpty
                  ? null
                  : () {
                      HapticFeedback.heavyImpact();
                      setState(() => _currentStep = 3);
                    },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelectionV3() {
    final t = AppLocalizations.of(context);
    return Padding(
      key: const ValueKey('mode_v3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SetupStepEyebrow(text: t.setupModePickerEyebrow),
          const SizedBox(height: 8),
          SetupHeading(
            title: t.setupModePickerTitle,
            subtitle: t.setupModePickerSubtitle,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          ..._modes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final mode = entry.value;
                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 280 + (index * 60)),
                              tween: Tween(begin: 0, end: 1),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(18 * (1 - value), 0),
                                  child: child,
                                ),
                              ),
                              child: _buildModeCardV3(mode),
                            );
                          }),
                          const Spacer(flex: 2),
                          const SizedBox(height: 8),
                          SetupPrimaryButton(
                            text: t.commonContinue,
                            onPressed:
                                _selectedMode != null ? _onModeSelected : null,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 0,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 34),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .signOut();
                                },
                                child: Text(
                                  t.setupSignOutLink,
                                  style: TextStyle(
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.64),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '·',
                                style: TextStyle(
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.38),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 34),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () =>
                                    setState(() => _currentStep = 0),
                                child: Text(
                                  t.setupSeeFeaturesLink,
                                  style: TextStyle(
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.52),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCardV3(Map<String, dynamic> mode) {
    final t = AppLocalizations.of(context);
    final id = mode['id'] as String;
    final isSelected = _selectedMode == id;
    final gradient = mode['gradient'] as List<Color>;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedMode = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.52)
                : AppColors.border.withValues(alpha: 0.82),
            width: isSelected ? 1.7 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.07)
                  : AppColors.shadowBase.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildModeIconV3(mode, gradient),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.setupModeName(id),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.setupModeDescription(id),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.84),
                      fontSize: 13,
                      height: 1.28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.9),
                  width: 1.3,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeIconV3(Map<String, dynamic> mode, List<Color> gradient) {
    final id = mode['id'] as String;
    final accent = gradient.first;

    IconData primary;
    switch (id) {
      case 'couple':
        primary = Icons.favorite_rounded;
        break;
      case 'family':
        primary = Icons.family_restroom_rounded;
        break;
      case 'friends':
        primary = Icons.apartment_rounded;
        break;
      default:
        primary = Icons.check_circle_rounded;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(
        primary,
        color: Colors.white,
        size: id == 'friends' ? 29 : 31,
      ),
    );
  }

  Widget _buildTeamOptionsV3() {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      key: const ValueKey('team_options_v3'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          SetupStepEyebrow(text: t.setupConnectEyebrow),
          const SizedBox(height: 10),
          Text(
            t.setupConnectTitle,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
              height: 0.95,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.setupConnectSubtitle,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.28,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SetupOptionTile(
            icon: Icons.add_home_work_rounded,
            title: t.setupConnectCreateTitle,
            desc: t.setupConnectCreateDesc,
            isSelected: _createNew,
            tone: AppColors.primary,
            onTap: () => setState(() {
              _createNew = true;
              _joinError = null;
            }),
          ),
          const SizedBox(height: 10),
          SetupOptionTile(
            icon: Icons.qr_code_scanner_rounded,
            title: t.setupConnectJoinTitle,
            desc: t.setupConnectJoinDesc,
            isSelected: !_createNew,
            tone: AppColors.sage,
            onTap: () => setState(() {
              _createNew = false;
              _joinError = null;
            }),
          ),
          if (!_createNew) ...[
            const SizedBox(height: 14),
            Text(
              t.setupConnectCodeInputLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            _buildJoinInput(showLabel: false, compact: true),
          ],
          const SizedBox(height: 20),
          if (_isJoining)
            const Center(child: CircularProgressIndicator())
          else
            SetupPrimaryButton(
              text: _createNew
                  ? t.setupConnectCreateButton
                  : t.setupConnectJoinButton,
              onPressed: _createNew ? _handleCreateTeam : _handleJoinTeam,
            ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentStep = 3),
              child: Text(t.setupConnectBackButton),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInviteCodeStepV2() {
    final t = AppLocalizations.of(context);
    final modeKey = _selectedMode ?? 'couple';
    return Column(
      key: const ValueKey('invite_code_v2'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SetupStepEyebrow(text: t.setupInvitationEyebrow),
              const SizedBox(height: 10),
              SetupHeading(
                title: t.setupInvitationTitle(modeKey),
                subtitle: t.setupInvitationSubtitle(modeKey),
              ),
              const SizedBox(height: 28),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowBase.withValues(alpha: 0.07),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    t.setupInvitationCodeEyebrow,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  if (_isGeneratingCode)
                                    const CircularProgressIndicator(
                                      color: AppColors.primary,
                                    )
                                  else
                                    FittedBox(
                                      child: Text(
                                        _myInviteCode ?? '------',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 56,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.85),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.sage,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.setupInvitationFooter,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SetupSecondaryButton(
                      text: t.setupInvitationCopyButton,
                      icon: Icons.copy_rounded,
                      onTap: _copyCode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SetupSecondaryButton(
                      text: t.setupInvitationShareButton,
                      icon: Icons.share_rounded,
                      onTap: _shareViaWhatsApp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SetupPrimaryButton(
            text: t.commonContinue,
            onPressed: () {
              setState(() {
                _currentStep = _selectedMode == 'solo' ? 7 : 6;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _currentStep = 4),
          child: Text(t.commonBack),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHouseholdSetupStepV2() {
    if (_selectedMode == 'family') {
      return _buildFamilySetupStepV2();
    }
    return _buildSplitStepV2();
  }

  Widget _buildFamilySetupStepV2() {
    final t = AppLocalizations.of(context);
    return Padding(
      key: const ValueKey('family_setup_v2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SetupStepEyebrow(text: t.setupFamilyBaseEyebrow),
          const SizedBox(height: 10),
          SetupHeading(
            title: t.setupFamilyBaseTitle,
            subtitle: t.setupFamilyBaseSubtitle,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SetupFamilyPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.setupFamilyHouseholdNameLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _familyHouseholdNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: t.setupFamilyHouseholdNameHint,
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.92),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.9),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SetupFamilyPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.setupFamilyRoleLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            // Internal id stays in Spanish for backend compat
                            // (sent as 'p_display_role'); only the UI label is
                            // localized via the lookup below.
                            ('Padre', t.setupFamilyRoleFather),
                            ('Madre', t.setupFamilyRoleMother),
                            ('Tutor/a', t.setupFamilyRoleGuardian),
                            ('Adolescente', t.setupFamilyRoleTeen),
                          ].map((entry) {
                            final id = entry.$1;
                            final label = entry.$2;
                            return SetupFamilyChoiceChip(
                              label: label,
                              selected: _familyRole == id,
                              onTap: () => setState(() {
                                _familyRole = id;
                                if (id == 'Adolescente') {
                                  _selectedCreatorMemberType = 'teen';
                                } else {
                                  _selectedCreatorMemberType = 'parent';
                                }
                              }),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SetupPrimaryButton(
            text: t.setupSaveAndContinue,
            onPressed: _saveFamilySetup,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _advanceToTaskSelectionOrComplete,
              child: Text(t.setupConfigureLater),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFriendsEqualSplitStepV2() {
    final t = AppLocalizations.of(context);
    _tempRatio = 0.5;
    return Padding(
      key: const ValueKey('split_friends_v2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SetupStepEyebrow(text: t.setupExpensesEyebrow),
          const SizedBox(height: 10),
          SetupHeading(
            title: t.setupExpensesTitle,
            subtitle: t.setupFriendsExpensesSubtitle,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.85),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.sage.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.balance_rounded,
                            color: AppColors.sage,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          t.setupFriendsExpensesCardTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.setupFriendsExpensesCardBody,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.84),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SetupStrategyTip(
                    title: t.setupFriendsExpensesTipTitle,
                    desc: t.setupFriendsExpensesTipDesc,
                    active: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SetupPrimaryButton(
            text: t.setupSaveAndContinue,
            onPressed: () async {
              _tempRatio = 0.5;
              try {
                final householdId = await ref.read(householdIdProvider.future);
                if (householdId != null) {
                  final result = await ref
                      .read(updateDefaultSplitRatioUseCaseProvider)
                      .call(householdId, _tempRatio);
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
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _advanceToTaskSelectionOrComplete,
              child: Text(t.setupConfigureLater),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSplitStepV2() {
    if (_selectedMode == 'friends') {
      return _buildFriendsEqualSplitStepV2();
    }

    final t = AppLocalizations.of(context);
    final modeKey = _selectedMode ?? 'couple';

    return Padding(
      key: const ValueKey('split_v2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SetupStepEyebrow(text: t.setupExpensesEyebrow),
          const SizedBox(height: 10),
          SetupHeading(
            title: t.setupExpensesTitle,
            subtitle: t.setupCoupleFamilyExpensesSubtitle(modeKey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.cardBorder.withValues(alpha: 0.85),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.sage.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.balance_rounded,
                            color: AppColors.sage,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            t.setupCoupleFamilyExpensesNote(modeKey),
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.84),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    t.setupCoupleFamilyExpensesSplitLabel(modeKey),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_tempRatio * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${(100 - (_tempRatio * 100)).toInt()}%',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.sage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.2),
                      trackHeight: 12,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 18),
                    ),
                    child: Slider(
                      value: _tempRatio,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _tempRatio = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SetupStrategyTip(
                    title: t.setupCoupleFamilyTipEqualTitle,
                    desc: _selectedMode == 'couple'
                        ? t.setupCoupleFamilyTipEqualDescCouple
                        : t.setupCoupleFamilyTipEqualDescOther,
                    active: _tempRatio == 0.5,
                  ),
                  SetupStrategyTip(
                    title: t.setupCoupleFamilyTipProportionalTitle,
                    desc: t.setupCoupleFamilyTipProportionalDesc,
                    active: _tempRatio != 0.5,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SetupPrimaryButton(
            text: t.setupSaveAndContinue,
            onPressed: () async {
              try {
                final householdId = await ref.read(householdIdProvider.future);
                if (householdId != null) {
                  final result = await ref
                      .read(updateDefaultSplitRatioUseCaseProvider)
                      .call(householdId, _tempRatio);
                  result.fold((failure) => throw failure, (_) {});
                }
              } catch (e) {
                // Ignore error
              }
              await _advanceToTaskSelectionOrComplete();
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _advanceToTaskSelectionOrComplete,
              child: Text(t.setupConfigureLater),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTaskSelectionV2() {
    if (_isLoadingTemplates) {
      return const Center(child: CircularProgressIndicator());
    }

    final t = AppLocalizations.of(context);
    final modeKey = _selectedMode ?? 'couple';

    return Column(
      key: const ValueKey('tasks_v2'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SetupStepEyebrow(text: t.setupFirstTasksEyebrow),
              const SizedBox(height: 10),
              SetupHeading(
                title: t.setupFirstTasksTitle(modeKey),
                subtitle: t.setupFirstTasksSubtitle(modeKey),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: _categories.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final templates = _templatesByCategory[category.id] ?? [];
              if (templates.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 24, bottom: 16, left: 4),
                    child: Text(
                      '${category.icon}  ${category.name.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary.withValues(alpha: 0.82),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        templates.map((t) => _buildTaskChipV2(t)).toList(),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBase.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SetupPrimaryButton(
              text: t.setupFinishButton,
              isLoading: _isSaving,
              onPressed:
                  _selectedTemplateIds.isNotEmpty ? _saveAndComplete : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskChipV2(TaskTemplate template) {
    final isSelected = _selectedTemplateIds.contains(template.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (isSelected) {
            _selectedTemplateIds.remove(template.id);
          } else {
            _selectedTemplateIds.add(template.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.28)
                : AppColors.border.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              template.title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

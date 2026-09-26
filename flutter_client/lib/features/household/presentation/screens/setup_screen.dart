import 'dart:async';

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
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/features/household/presentation/utils/invite_share.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'setup_steps/setup_household_step.dart';
import 'setup_steps/setup_invite_step.dart';
import 'setup_steps/setup_start_step.dart';
import 'setup_steps/setup_task_selection_step.dart';

/// Shell del wizard de setup. La navegación y el estado del formulario viven
/// en [SetupWizardController]; acá quedan solo los side effects (crear hogar,
/// unirse por código, guardar perfil y tareas) porque necesitan
/// `BuildContext` para snackbars y coordinar providers de sesión.
///
/// El orden de los side effects importa:
/// - el hogar se crea recién al confirmar el paso "tu casa", nunca antes de
///   ofrecer "Tengo un código" (unirse borra un hogar de un solo miembro);
/// - el perfil se guarda en ese mismo momento, así la pareja ve el nombre
///   apenas se une;
/// - las tareas se clonan una sola vez (el clon no es idempotente);
/// - `setupInProgressProvider` mantiene montado el wizard desde que existe el
///   hogar hasta el último paso.
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

  // Email resuelto al iniciar: fallback de nombre cuando la sesión de Supabase
  // todavía no está lista (Firebase avisa signedIn antes de sincronizar).
  String? _authEmail;

  /// Foto de la cuenta (Google), para poder volver a elegirla como avatar.
  String? _accountPhotoUrl;

  /// La cuenta trajo nombre: quien se une no necesita escribirlo.
  bool _accountHasName = false;

  // Invitación
  String? _myInviteCode;
  bool _inviteCodeFailed = false;
  bool _isSharing = false;
  bool _hasShared = false;

  // Estados de las acciones
  bool _isCreating = false;
  bool _isJoining = false;
  bool _isSaving = false;
  bool _isFinishing = false;

  /// Las tareas iniciales ya se clonaron: reintentar el paso no las duplica.
  bool _tasksCloned = false;

  // Plantillas de tareas
  List<Category> _categories = [];
  Map<String, List<TaskTemplate>> _templatesByCategory = {};
  bool _isLoadingTemplates = true;
  bool _templatesLoadFailed = false;
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
    // Los providers no se pueden mutar durante el build: la siembra del
    // estado del wizard (avatar por defecto, datos de la cuenta) va después
    // del primer frame.
    Future.microtask(() {
      if (!mounted) return;
      _wizard.setAvatarEmoji(
        UserAvatar.defaultAvatars.first['emoji'] as String,
      );
      _prefillIdentityFromAuth();
      unawaited(_prefillInviteCodeFromInstall());
    });
    _loadTemplates();
  }

  /// Quien instaló desde el link de invitación trae el código en el referrer
  /// de Play: se abre "Tengo un código" ya completo para que solo toque
  /// "Unirme".
  Future<void> _prefillInviteCodeFromInstall() async {
    if (widget.isAdminPreview) return;
    final String? code;
    try {
      code = await ref.read(installReferrerServiceProvider).takeInviteCode();
    } catch (error, stackTrace) {
      log.w(
        'SetupScreen install referrer failed',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
    if (code == null || !mounted) return;
    // No pisar lo que la persona ya empezó: si avanzó a crear su hogar o
    // escribió otro código, se respeta.
    if (_wizardState.step != SetupStep.start ||
        _codeController.text.trim().isNotEmpty) {
      return;
    }
    _codeController.text = code;
    _wizard.setCreateNew(false);
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .trackInviteCodePrefilled(source: 'install_referrer'),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // -- Identidad -------------------------------------------------------------

  void _prefillIdentityFromAuth() {
    final currentUser = ref.read(currentUserProvider);
    _authEmail = currentUser?.email;

    // Primero Firebase (disponible al instante, incluso antes de Supabase).
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final photoUrl = firebaseUser.photoURL;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        _accountPhotoUrl = photoUrl;
        _wizard.setAvatarUrl(photoUrl);
      }
      final firstName = _firstNameFromDisplayName(firebaseUser.displayName);
      if (firstName != null) _nameController.text = firstName;
    }

    // Fallback: metadata de Supabase (registro con email y contraseña).
    if (_nameController.text.trim().isEmpty && currentUser != null) {
      final metadata = currentUser.userMetadata ?? const <String, dynamic>{};
      final displayName = [metadata['full_name'], metadata['name']]
          .whereType<String>()
          .map((value) => value.trim())
          .firstWhere((value) => value.isNotEmpty, orElse: () => '');
      if (displayName.isNotEmpty) {
        _nameController.text = _firstNameFromDisplayName(displayName) ?? '';
      }
      if (_accountPhotoUrl == null) {
        final profileImage = [
          metadata['avatar_url'],
          metadata['picture'],
          metadata['photo_url'],
        ].whereType<String>().map((value) => value.trim()).firstWhere(
              (value) => value.isNotEmpty,
              orElse: () => '',
            );
        if (profileImage.isNotEmpty) {
          _accountPhotoUrl = profileImage;
          _wizard.setAvatarUrl(profileImage);
        }
      }
    }

    if (mounted) {
      setState(
        () => _accountHasName = _nameController.text.trim().isNotEmpty,
      );
    }
  }

  String? _firstNameFromDisplayName(String? displayName) {
    final firstName = displayName?.trim().split(RegExp(r'\s+')).first.trim();
    return firstName == null || firstName.isEmpty ? null : firstName;
  }

  /// Nombre a guardar: el escrito, o el usuario del email si no hay otro.
  String? get _nameToSave {
    final typed = _nameController.text.trim();
    if (typed.isNotEmpty) return typed;
    final email = _authEmail ?? ref.read(currentUserProvider)?.email;
    final fallback = email?.split('@').first.trim();
    return fallback == null || fallback.isEmpty ? null : fallback;
  }

  // -- Plantillas ------------------------------------------------------------

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
    if (mounted) {
      setState(() {
        _isLoadingTemplates = true;
        _templatesLoadFailed = false;
      });
    }

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
    } catch (e, stack) {
      log.e('SetupScreen._loadTemplates failed', error: e, stackTrace: stack);
      if (mounted) {
        setState(() {
          _isLoadingTemplates = false;
          _templatesLoadFailed = true;
        });
      }
    }
  }

  Future<bool> _isTasksEnabledForCurrentHousehold() async {
    final currentHousehold = ref.read(currentHouseholdProvider).value;
    if (currentHousehold != null) return currentHousehold.tasksEnabled;

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

  // -- Sesión ----------------------------------------------------------------

  void _invalidateHouseholdSession() {
    ref.invalidate(householdIdProvider);
    ref.invalidate(currentHouseholdProvider);
    ref.invalidate(householdCapabilitiesProvider);
  }

  void _notifySetupComplete() {
    // Setup terminado: se libera la guarda para que el router vuelva a rutear
    // según el hogar.
    ref.read(setupInProgressProvider.notifier).finish();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onComplete();
    });
  }

  String get _creatorMemberTypeForOnboarding =>
      _wizardState.householdType == HouseholdType.family
          ? _wizardState.creatorMemberType
          : 'parent';

  String get _creatorDisplayRoleForOnboarding =>
      _wizardState.householdType == HouseholdType.family
          ? _wizardState.familyRole
          : 'Adulto';

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

  void _showError(String message) {
    if (!mounted) return;
    AppSnackBar.show(context, message: message, type: AppSnackBarType.error);
  }

  // -- Paso 1: unirse con un código ------------------------------------------

  Future<void> _handleJoin() async {
    if (_isJoining) return;

    AppHaptics.success();
    final t = AppLocalizations.of(context);
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      _wizard.setJoinError(t.setupJoinCodeLengthError);
      return;
    }

    setState(() => _isJoining = true);
    _wizard.setJoinError(null);

    try {
      final result = await ref.read(joinHouseholdUseCaseProvider).call(code);
      final joined = result.fold(
        (failure) {
          log.w('SetupScreen._handleJoin rejected code: ${failure.message}');
          return false;
        },
        (_) => true,
      );
      if (!joined) {
        if (mounted) _wizard.setJoinError(t.setupJoinHouseholdError);
        return;
      }

      if (!widget.isAdminPreview) {
        final nameToSave = _nameToSave;
        if (nameToSave != null) {
          final profileResult =
              await ref.read(authRepositoryProvider).updateProfile(
                    fullName: nameToSave,
                    avatarUrl: _wizardState.resolvedAvatarValue,
                  );
          profileResult.fold(
            (failure) => log.e(
              'SetupScreen._handleJoin: updateProfile failed: '
              '${failure.message}',
            ),
            (_) => log.i('SetupScreen._handleJoin: updateProfile ok'),
          );
        }
      }

      // Entró alguien con un código válido: cierra el loop de la invitación.
      // Se emite antes de los invalidates para no perderlo si algún refresh
      // falla.
      unawaited(
        ref.read(analyticsServiceProvider).trackInviteAccepted(mode: 'joined'),
      );
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .trackSetupCompleted(mode: 'joined', joined: true),
      );

      ref.invalidate(householdIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(currentHouseholdProvider);
      ref.invalidate(userBalanceProvider);
      ref.invalidate(householdMembersProvider);
      ref.invalidate(memberOnboardingProvider);

      if (!widget.isAdminPreview) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('setup_completed', true);
      }
      if (mounted) {
        AppSnackBar.show(
          context,
          message: t.setupSnackJoinedHousehold,
          type: AppSnackBarType.success,
        );
        _notifySetupComplete();
      }
    } catch (e, stack) {
      log.e('SetupScreen._handleJoin failed', error: e, stackTrace: stack);
      if (mounted) _wizard.setJoinError(t.setupJoinHouseholdError);
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  // -- Paso 2: crear el hogar ------------------------------------------------

  /// Guarda: el wizard puede aparecer por un falso negativo del router aunque
  /// el usuario ya tenga hogar. Crear otro fallaría (o duplicaría); en ese
  /// caso se entra al existente. Solo aplica con el wizard recién abierto, no
  /// a mitad de camino (volver atrás tras crear el hogar acá mismo).
  Future<bool> _enterExistingHouseholdIfAny() async {
    if (ref.read(setupInProgressProvider)) return false;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    final existing =
        await ref.read(householdRepositoryProvider).getHouseholdId(userId);
    final existingId = existing.fold<String?>((_) => null, (id) => id);
    if (existingId == null || existingId.isEmpty) return false;

    // log.e para que llegue al pipeline remoto: es la evidencia del falso
    // negativo del router.
    log.e(
      'SetupScreen: wizard shown for user with existing household '
      '$existingId, entering it instead of creating a new one',
    );
    _invalidateHouseholdSession();
    ref.invalidate(userProfileProvider);
    ref.invalidate(householdMembersProvider);
    ref.invalidate(memberOnboardingProvider);
    if (!widget.isAdminPreview) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setup_completed', true);
    }
    if (mounted) _notifySetupComplete();
    return true;
  }

  Future<void> _handleCreateHousehold() async {
    if (_isCreating) return;
    final t = AppLocalizations.of(context);
    final mode = _wizardState.selectedMode;
    setState(() => _isCreating = true);

    try {
      if (await _enterExistingHouseholdIfAny()) return;

      // La guarda va ANTES de crear el hogar: en cuanto existe, householdId
      // deja de ser null y MainScreen cambiaría el wizard por el Home antes de
      // los pasos que faltan.
      ref.read(setupInProgressProvider.notifier).begin();

      final householdId = await ref
          .read(firebaseAuthServiceProvider)
          .createHouseholdForUser(mode);
      if (householdId == null || householdId.isEmpty) {
        throw StateError('Household creation returned no id');
      }

      // ensure_household_for_user devuelve el hogar existente si el usuario
      // volvió atrás y cambió de modo: el tipo se actualiza igual.
      final typeResult = await ref
          .read(updateHouseholdTypeUseCaseProvider)
          .call(householdId, mode);
      typeResult.fold((failure) => throw failure, (_) {});

      if (!widget.isAdminPreview) {
        final nameToSave = _nameToSave;
        if (nameToSave != null) {
          final profileResult =
              await ref.read(authRepositoryProvider).updateProfile(
                    fullName: nameToSave,
                    avatarUrl: _wizardState.resolvedAvatarValue,
                  );
          profileResult.fold((failure) => throw failure, (_) {});
        }
      }

      await _applyModeDefaults(householdId: householdId, mode: mode);

      _invalidateHouseholdSession();
      ref.invalidate(userProfileProvider);
      ref.invalidate(householdMembersProvider);

      if (_wizardState.householdType != HouseholdType.solo) {
        unawaited(_loadInviteCode());
      }

      if (!mounted) return;
      if (await _isTasksEnabledForCurrentHousehold()) {
        _wizard.householdReady();
      } else {
        await _completeOnboarding();
      }
    } catch (e, stack) {
      log.e(
        'SetupScreen._handleCreateHousehold failed',
        error: e,
        stackTrace: stack,
      );
      _showError(t.setupCreateHouseholdError);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  /// Ajustes por modo que no merecen un paso propio. Best-effort: el hogar ya
  /// existe y todo esto se puede cambiar después desde Ajustes.
  Future<void> _applyModeDefaults({
    required String householdId,
    required String mode,
  }) async {
    final type = HouseholdType.fromString(mode);
    try {
      if (type == HouseholdType.family) {
        final t = AppLocalizations.of(context);
        final name = _nameToSave;
        final householdName = name == null
            ? t.setupFamilyDefaultName
            : t.setupFamilyHouseholdNameFor(name);
        await ref
            .read(supabaseClientProvider)
            .from('households')
            .update({'name': householdName}).eq('id', householdId);

        final currentUserId = ref.read(currentUserIdProvider);
        if (currentUserId != null) {
          final roleResult = await ref
              .read(updateMemberDisplayRoleUseCaseProvider)
              .call(currentUserId, _wizardState.familyRole);
          roleResult.fold((failure) => throw failure, (_) {});
        }
      } else if (type == HouseholdType.friends) {
        final splitResult = await ref
            .read(updateDefaultSplitRatioUseCaseProvider)
            .call(householdId, 0.5);
        splitResult.fold((failure) => throw failure, (_) {});
      }
    } catch (error, stackTrace) {
      log.w(
        'SetupScreen mode defaults failed; continuing setup',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // -- Paso 3: tareas iniciales ----------------------------------------------

  Future<void> _saveTasks() async {
    if (_isSaving) return;
    final t = AppLocalizations.of(context);
    final selectedTemplateIds = _wizardState.selectedTemplateIds;
    if (selectedTemplateIds.isEmpty) {
      _showError(t.setupSnackPickAtLeastOneTask);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null || householdId.isEmpty) {
        throw StateError('No household to clone tasks into');
      }

      if (!_tasksCloned) {
        final count = await _templateService.cloneTemplates(
          selectedTemplateIds.toList(),
          householdId: householdId,
        );
        if (count <= 0) {
          throw StateError('No initial tasks were created');
        }
        _tasksCloned = true;
        log.i('SetupScreen: cloned $count tasks household=$householdId');
      }

      await _completeOnboarding();
    } catch (e, stack) {
      log.e('SetupScreen._saveTasks failed', error: e, stackTrace: stack);
      _showError(t.setupCompleteError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Marca el onboarding del miembro como completo y decide si falta el paso
  /// de invitación (hogares compartidos) o si ya se puede entrar (solo).
  Future<void> _completeOnboarding() async {
    final t = AppLocalizations.of(context);

    if (!widget.isAdminPreview) {
      try {
        final rpcResult = await ref.read(supabaseClientProvider).rpc(
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
          log.w('complete_member_onboarding returned: $onboardingError');
          _showError(t.setupSnackOnboardingFailed);
          return;
        }
      } catch (e, stack) {
        log.w(
          'complete_member_onboarding failed',
          error: e,
          stackTrace: stack,
        );
        _showError(t.setupSnackOnboardingFailed);
        return;
      }
    }

    ref.invalidate(userProfileProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(householdMembersProvider);
    ref.invalidate(memberOnboardingProvider);

    unawaited(
      ref.read(analyticsServiceProvider).trackSetupCompleted(
            mode: _wizardState.selectedMode,
            joined: false,
          ),
    );

    if (!widget.isAdminPreview) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setup_completed', true);
    }

    if (!mounted) return;
    final needsInvite = _wizard.tasksSaved();
    if (!needsInvite) await _finishSetup();
  }

  // -- Paso 4: invitar -------------------------------------------------------

  Future<void> _loadInviteCode() async {
    if (mounted) setState(() => _inviteCodeFailed = false);
    try {
      final result =
          await ref.read(generateInvitationCodeUseCaseProvider).call();
      if (!mounted) return;
      result.fold(
        (failure) {
          log.w('SetupScreen invite code failed: ${failure.message}');
          setState(() => _inviteCodeFailed = true);
        },
        (code) => setState(() => _myInviteCode = code),
      );
    } catch (error, stackTrace) {
      log.w(
        'SetupScreen invite code threw',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _inviteCodeFailed = true);
    }
  }

  /// `invite_sent` es el primer paso del loop viral: sin él no se puede saber
  /// si el problema es que no invitan o que la invitación no convierte.
  void _trackInviteSent(String channel) {
    unawaited(
      ref.read(analyticsServiceProvider).trackInviteSent(
            mode: _wizardState.selectedMode,
            channel: channel,
          ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    final code = _myInviteCode;
    if (code == null || _isSharing) return;
    final t = AppLocalizations.of(context);
    setState(() => _isSharing = true);
    AppHaptics.tap();
    _trackInviteSent('whatsapp');
    final outcome = await shareInviteViaWhatsApp(
      t,
      code: code,
      type: _wizardState.householdType,
    );
    if (!mounted) return;
    setState(() {
      _isSharing = false;
      _hasShared = true;
    });
    if (outcome == InviteShareOutcome.copiedFallback) {
      AppSnackBar.show(
        context,
        message: t.partnerInviteMessageCopied,
        type: AppSnackBarType.neutral,
      );
    }
  }

  Future<void> _shareOther() async {
    final code = _myInviteCode;
    if (code == null || _isSharing) return;
    final t = AppLocalizations.of(context);
    setState(() => _isSharing = true);
    _trackInviteSent('share');
    final outcome = await shareInviteWithSystemSheet(
      t,
      code: code,
      type: _wizardState.householdType,
    );
    if (!mounted) return;
    setState(() {
      _isSharing = false;
      _hasShared = true;
    });
    if (outcome == InviteShareOutcome.copiedFallback) {
      AppSnackBar.show(
        context,
        message: t.partnerInviteMessageCopied,
        type: AppSnackBarType.neutral,
      );
    }
  }

  Future<void> _copyCode() async {
    final code = _myInviteCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    _trackInviteSent('copy');
    AppHaptics.selection();
    if (!mounted) return;
    setState(() => _hasShared = true);
    AppSnackBar.show(
      context,
      message: AppLocalizations.of(context).setupSnackCodeCopied,
      type: AppSnackBarType.success,
    );
  }

  Future<void> _finishSetup() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    try {
      unawaited(
        ref.read(analyticsServiceProvider).logEvent(
          'setup_invite_step_finished',
          parameters: {'shared': _hasShared, 'mode': _wizardState.selectedMode},
        ),
      );
      if (mounted && !widget.isAdminPreview) {
        await _showCompletionCelebration();
      }
      if (mounted) _notifySetupComplete();
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  /// Micro-celebración al terminar el setup: tarjeta con el acento del modo,
  /// se cierra sola a los ~1.6s (o antes con un tap) y recién ahí se navega.
  Future<void> _showCompletionCelebration() async {
    final t = AppLocalizations.of(context);
    final design = _wizardState.modeDesign;
    final modeKey = _wizardState.selectedMode;
    unawaited(AppHaptics.celebrate());

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
                  style: AppTypography.sectionTitle.copyWith(
                    color: context.theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.setupCompletionMessage(modeKey),
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.textSecondary,
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

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final wizard = ref.watch(setupWizardControllerProvider);
    final t = AppLocalizations.of(context);

    return PopScope(
      canPop: wizard.step == SetupStep.start,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _wizard.goBack();
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackground,
        body: Container(
          decoration: AppTheme.backgroundGradientBox,
          child: SafeArea(
            child: Column(
              children: [
                _buildProgressIndicator(wizard),
                if (widget.isAdminPreview) _buildAdminPreviewBanner(),
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
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: switch (wizard.step) {
                      SetupStep.start => SetupStartStep(
                          nameController: _nameController,
                          codeController: _codeController,
                          askName: !_accountHasName,
                          isJoining: _isJoining,
                          onCreate: _wizard.startCreate,
                          onJoin: _handleJoin,
                          onSignOut: () => ref
                              .read(authControllerProvider.notifier)
                              .signOut(),
                        ),
                      SetupStep.household => SetupHouseholdStep(
                          nameController: _nameController,
                          accountPhotoUrl: _accountPhotoUrl,
                          isCreating: _isCreating,
                          onContinue: _handleCreateHousehold,
                        ),
                      SetupStep.tasks => SetupTaskSelectionStep(
                          isLoadingTemplates: _isLoadingTemplates,
                          hasTemplatesError: _templatesLoadFailed,
                          isSaving: _isSaving,
                          categories: _categories,
                          templatesByCategory: _templatesByCategory,
                          onRetryTemplates: _loadTemplates,
                          onFinish: _saveTasks,
                          buttonLabel: wizard.isSolo
                              ? t.setupFinishButton
                              : t.commonContinue,
                        ),
                      SetupStep.invite => SetupInviteStep(
                          inviteCode: _myInviteCode,
                          codeFailed: _inviteCodeFailed,
                          isSharing: _isSharing,
                          hasShared: _hasShared,
                          isFinishing: _isFinishing,
                          onShareWhatsApp: _shareViaWhatsApp,
                          onShareOther: _shareOther,
                          onCopy: _copyCode,
                          onRetryCode: _loadInviteCode,
                          onFinish: _finishSetup,
                        ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminPreviewBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_fix_high_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Preview QA del onboarding. No modifica tu perfil real; sirve para configurar y testear el escenario activo.',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(SetupWizardState wizard) {
    // La bienvenida no cuenta como progreso. La cantidad de segmentos es la
    // ruta efectiva del modo: solo no tiene el paso de invitación.
    if (wizard.progressIndex < 0) return const SizedBox(height: 8);
    final theme = context.theme;
    final accent = wizard.modeDesign.accent;
    return Semantics(
      label: '${wizard.progressIndex + 1}/${wizard.progressTotal}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        child: Row(
          children: List.generate(wizard.progressTotal, (index) {
            final isActive = index <= wizard.progressIndex;
            return Expanded(
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.standard,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? accent : theme.border,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

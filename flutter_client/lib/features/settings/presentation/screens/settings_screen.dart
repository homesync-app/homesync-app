import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/locale_provider.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
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
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/couple_home_tour_controller.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:homesync_client/features/settings/domain/usecases/delete_account_usecase.dart';
import 'package:homesync_client/features/settings/presentation/providers/settings_provider.dart';
import 'package:homesync_client/features/settings/presentation/screens/household_settings_screen.dart';
import 'package:homesync_client/features/settings/presentation/widgets/faq_sheet.dart';
import 'package:homesync_client/features/settings/presentation/widgets/feedback_sheet.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_account_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_admin_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_components.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_nav_components.dart';
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
  // Flag transitorio para los overlays de operaciones admin / reset / borrado.
  bool _isLoading = false;

  Future<void> _refreshAdminScenarioState() async {
    ref.invalidate(householdIdProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(currentHouseholdProvider);
    ref.invalidate(householdMembersProvider);
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(tasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(qaAdminRecentEventsProvider);
    await ref.read(householdMembersProvider.notifier).refresh();
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
              onRefresh: () async {
                ref.invalidate(userProfileProvider);
                ref.invalidate(currentHouseholdProvider);
                ref.invalidate(householdMembersProvider);
              },
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
                          // Perfil: card "hero" con avatar y nombre.
                          _anchorLabel(t.settingsSectionProfileTitle),
                          _buildProfileCard(),
                          const SizedBox(height: AppSpacing.lg),

                          if (!isMinor) ...[
                            _buildPremiumCard(),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // Hogar: fila que abre su propia pantalla de detalle
                          // (miembros, roles, modo de tareas, invitación).
                          if (!isMinor) ...[
                            SettingsNavGroup(
                              children: [
                                SettingsNavRow(
                                  icon: Icons.home_rounded,
                                  iconColor: AppColors.primary,
                                  title: t.settingsSectionHouseholdTitle,
                                  subtitle: t.settingsSectionHouseholdSubtitle,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const HouseholdSettingsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SettingsNavGap(),
                          ],

                          // Preferencias: filas compactas que abren un sheet.
                          SettingsNavGroup(
                            label: t.settingsSectionAppTitle,
                            children: [
                              SettingsNavRow(
                                icon: Icons.palette_outlined,
                                iconColor: AppColors.accentTeal,
                                title: t.settingsAppearanceTitle,
                                value: _themeModeLabel(
                                  ref.watch(themeModeProvider),
                                  t,
                                ),
                                onTap: () => _openPreferenceSheet(
                                  t.settingsAppearanceTitle,
                                  (sheetRef) => _buildAppearanceCard(
                                    sheetRef,
                                    isMinor: isMinor,
                                  ),
                                ),
                              ),
                              SettingsNavRow(
                                icon: Icons.translate_rounded,
                                iconColor: AppColors.accentBlue,
                                title: t.settingsLanguageTitle,
                                value:
                                    _languageLabel(ref.watch(localeProvider)),
                                onTap: () => _openPreferenceSheet(
                                  t.settingsLanguageTitle,
                                  (sheetRef) => _buildLanguageCard(sheetRef),
                                ),
                              ),
                              if (!isMinor)
                                SettingsNavRow(
                                  icon: Icons.payments_outlined,
                                  iconColor: AppColors.accentGold,
                                  title: t.settingsCurrencyTitle,
                                  value: ref.watch(currencyProvider).code,
                                  onTap: () => _openPreferenceSheet(
                                    t.settingsCurrencyTitle,
                                    (sheetRef) => _buildCurrencyCard(sheetRef),
                                  ),
                                ),
                              SettingsNavRow(
                                icon: Icons.notifications_outlined,
                                iconColor: AppColors.accentRed,
                                title: t.settingsNotificationsTitle,
                                // Toda la fila togglea, no solo el switch.
                                onTap: () => _toggleNotifications(
                                  !ref.read(notificationEnabledProvider),
                                ),
                                trailing: Switch.adaptive(
                                  value: ref.watch(notificationEnabledProvider),
                                  onChanged: _toggleNotifications,
                                ),
                              ),
                            ],
                          ),
                          const SettingsNavGap(),

                          // Ayuda: FAQ, feedback y tour (abren sus sheets).
                          SettingsNavGroup(
                            children: [
                              SettingsNavRow(
                                icon: Icons.help_outline_rounded,
                                iconColor: AppColors.primary,
                                title: t.settingsFaqTitle,
                                onTap: () {
                                  AppHaptics.tap();
                                  FAQSheet.show(context);
                                },
                              ),
                              SettingsNavRow(
                                icon: Icons.chat_bubble_outline_rounded,
                                iconColor: const Color(0xFF6366F1),
                                title: t.settingsFeedbackTitle,
                                onTap: () {
                                  AppHaptics.tap();
                                  FeedbackSheet.show(
                                    context,
                                    screen: 'settings',
                                  );
                                },
                              ),
                              SettingsNavRow(
                                icon: Icons.auto_awesome_rounded,
                                iconColor: AppColors.accentGold,
                                title: t.settingsReplayTourTitle,
                                onTap: _replayTour,
                              ),
                            ],
                          ),
                          const SettingsNavGap(),

                          if (AppEnvironment.enableAdminTesting) ...[
                            _buildAdminTestingCard(),
                            const SettingsNavGap(),
                          ],

                          // Cuenta: cerrar sesión + zona de peligro.
                          SettingsNavGroup(
                            label: t.settingsSectionAccountTitle,
                            children: [
                              SettingsNavRow(
                                icon: Icons.logout_rounded,
                                title: t.settingsLogoutButton,
                                destructive: true,
                                onTap: _doLogout,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildResetAccountButton(),
                          const SettingsNavGap(),

                          // Legal
                          SettingsNavGroup(
                            label: t.settingsSectionLegalTitle,
                            children: [
                              SettingsNavRow(
                                icon: Icons.privacy_tip_outlined,
                                iconColor: AppColors.textSecondary,
                                title: t.settingsLegalPrivacyPolicy,
                                onTap: () => _openUrl(
                                  'https://homesync-app.github.io/homesync-privacy/',
                                ),
                              ),
                              SettingsNavRow(
                                icon: Icons.description_outlined,
                                iconColor: AppColors.textSecondary,
                                title: t.settingsLegalTermsOfUse,
                                onTap: () => _openUrl(
                                  'https://homesync-app.github.io/homesync-privacy/terms.html',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
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
            // Overlay durante operaciones largas (reset/borrado de cuenta, QA).
            if (_isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
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

  Widget _buildProfileCard() {
    final t = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.whenOrNull(data: (p) => p);
    final name =
        (profile?['full_name'] as String?) ?? t.settingsProfileNameFallback;
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

  Widget _buildLanguageCard(WidgetRef ref) {
    return SettingsLanguageCard(
      currentLocale: ref.watch(localeProvider),
      onLocaleChanged: (locale) {
        AppHaptics.tap();
        ref.read(localeProvider.notifier).setLocale(locale);
      },
    );
  }

  Widget _buildCurrencyCard(WidgetRef ref) {
    return SettingsCurrencyCard(
      currentCurrency: ref.watch(currencyProvider),
      onCurrencyChanged: (currency) {
        AppHaptics.tap();
        ref.read(currencyProvider.notifier).setCurrency(currency);
      },
    );
  }

  Widget _buildAppearanceCard(WidgetRef ref, {bool isMinor = false}) {
    final premiumStatus = ref.watch(premiumProvider);
    final isPremium = premiumStatus.value ?? false;
    final currentColor = ref.watch(primaryColorProvider);
    // Mismo gate que aplica MaterialApp (main.dart): el picker marca la
    // paleta que realmente se está renderizando, sin fingir.
    final effectiveColor = switch (premiumStatus) {
      AsyncData(value: false)
          when !ThemePalette.isFreePrimary(currentColor) =>
        ThemePalette.fallback.primary,
      _ => currentColor,
    };

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
        content: Text(AppLocalizations.of(context).settingsMinorPremiumSnack),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Selectores de preferencias como sheets (list-detail) ──────────────────
  // Cada fila del home abre el card existente en un sheet. El Consumer da un
  // ref válido para los ref.watch internos del card. El theme se lee ADENTRO
  // del builder: si el usuario cambia claro/oscuro desde el propio sheet
  // (Apariencia), el fondo y el título acompañan en vez de quedar en el tema
  // viejo hasta reabrir.
  void _openPreferenceSheet(String title, Widget Function(WidgetRef ref) body) {
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final theme = sheetCtx.theme;
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.modal),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.of(sheetCtx).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTypography.sectionTitle.copyWith(
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Consumer(builder: (_, ref, __) => body(ref)),
            ],
          ),
        );
      },
    );
  }

  String _themeModeLabel(ThemeMode mode, AppLocalizations t) {
    return switch (mode) {
      ThemeMode.light => t.settingsThemeModeLight,
      ThemeMode.dark => t.settingsThemeModeDark,
      ThemeMode.system => t.settingsThemeModeSystem,
    };
  }

  String? _languageLabel(Locale? locale) {
    if (locale == null) return null; // sigue el sistema → sin valor en la fila
    return switch (locale.languageCode) {
      'es' => 'Español',
      'en' => 'English',
      _ => locale.languageCode.toUpperCase(),
    };
  }

  Future<void> _replayTour() async {
    AppHaptics.tap();
    final controller = ref.read(coupleHomeTourControllerProvider.notifier);
    await controller.reset();
    ref.invalidate(coupleHomeTourSeenProvider);
    if (!mounted) return;
    controller.start(buildHomeTourContext(ref));
    Navigator.of(context).pop();
  }

  Future<void> _doLogout() async {
    // Abrir el confirm no es un "éxito": haptic neutro acá, la semántica
    // fuerte queda para el resultado de la acción.
    AppHaptics.tap();
    final confirm = await showSettingsLogoutDialog(context);
    if (confirm != true) return;
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onLogout();
  }

  Future<void> _openUrl(String url) async {
    AppHaptics.tap();
    final uri = Uri.parse(url);
    final opened = await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).settingsLinkOpenError),
        ),
      );
    }
  }

  void _toggleNotifications(bool value) {
    AppHaptics.tap();
    // Además de persistir la preferencia, aplica el efecto real: alta de
    // permisos/token FCM al activar, borrado del token al desactivar.
    unawaited(ref.read(notificationEnabledProvider.notifier).toggle(value));
    final t = AppLocalizations.of(context);
    final theme = context.theme;
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
  }

  /// Label tenue arriba de las cards "hero" (Perfil, Hogar). Sentence case.
  Widget _anchorLabel(String text) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: theme.textMuted,
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    final isPremium = ref.watch(premiumProvider).value ?? false;

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
          onFeedbackTap: isPremium
              ? null
              : () {
                  AppHaptics.tap();
                  FeedbackSheet.show(
                    context,
                    type: FeedbackType.bug,
                    screen: 'settings',
                  );
                },
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
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.settingsProfileNameUpdated),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.commonErrorWithDetails('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
      },
    );
  }

  // QA-only: agrega un miembro dummy al escenario. Vive acá (no en la pantalla
  // de hogar) porque lo dispara la admin testing card de esta pantalla.
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

  Future<void> _resetAccount() async {
    final theme = context.theme;
    final confirm = await showSettingsResetAccountDialog(context);
    if (!mounted) return;

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final res = await ref
            .read(householdRepositoryProvider)
            .resetAndClearHousehold();

        res.fold(
          (failure) {
            if (mounted) {
              final t = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.commonErrorWithDetails(failure.message)),
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
            } else if (mounted) {
              // Antes un success=false moría en silencio: overlay afuera y
              // ninguna señal de que el reset no ocurrió.
              final t = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    (data['message'] as String?) ??
                        t.settingsAccountResetError,
                  ),
                  backgroundColor: theme.error,
                ),
              );
            }
          },
        );
      } catch (e) {
        if (mounted) {
          final t = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.commonErrorWithDetails('$e')),
              backgroundColor: theme.error,
            ),
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
    if (confirm != true || !mounted) return;

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
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.commonErrorWithDetails('$e')),
            backgroundColor: theme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
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
                  style: AppTypography.heroAmount.copyWith(
                    height: 0.95,
                    color: theme.textPrimary,
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

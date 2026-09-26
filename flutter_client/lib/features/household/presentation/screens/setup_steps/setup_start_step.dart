import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

import '../setup_widgets.dart';

/// Primer paso: qué es HomeSync y los dos caminos posibles.
///
/// Quien llega invitado por su pareja no debería recorrer la configuración de
/// un hogar que ya existe: con "Tengo un código" se une en este mismo paso.
class SetupStartStep extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;

  /// true cuando la cuenta no trae nombre (registro con email): el panel para
  /// unirse lo pide antes de entrar.
  final bool askName;
  final bool isJoining;
  final VoidCallback onCreate;
  final VoidCallback onJoin;
  final VoidCallback onSignOut;

  const SetupStartStep({
    required this.nameController,
    required this.codeController,
    required this.askName,
    required this.isJoining,
    required this.onCreate,
    required this.onJoin,
    required this.onSignOut,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final controller = ref.read(setupWizardControllerProvider.notifier);
    final joinOpen = !wizard.createNew;

    return LayoutBuilder(
      key: const ValueKey('setup_start_v1'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Con el panel del código abierto se esconden la ilustración
                // y las viñetas: quien viene invitado tiene que ver el campo
                // y el botón sin scrollear.
                _Collapsible(
                  visible: !joinOpen,
                  child: Column(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          child: Image.asset(
                            'assets/images/onboarding_welcome_cat.webp',
                            width: 168,
                            height: 168,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    t.setupStartTitle,
                    style: AppTypography.heroAmount.copyWith(
                      fontSize: 34,
                      letterSpacing: -0.9,
                      height: 1.08,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.setupStartBody,
                  style: AppTypography.body.copyWith(
                    fontSize: 16,
                    height: 1.45,
                    color: theme.textSecondary,
                  ),
                ),
                _Collapsible(
                  visible: !joinOpen,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      SetupSupportBullet(
                        icon: Icons.task_alt_rounded,
                        color: theme.primary,
                        text: t.setupStartBulletTasks,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SetupSupportBullet(
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.iconSage,
                        text: t.setupStartBulletMoney,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SetupSupportBullet(
                        icon: Icons.insights_rounded,
                        color: AppColors.accentPeach,
                        text: t.setupStartBulletWeek,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: joinOpen ? AppSpacing.lg : AppSpacing.xl),
                AnimatedSwitcher(
                  duration: AppMotion.normal,
                  switchInCurve: AppMotion.standard,
                  switchOutCurve: Curves.easeInCubic,
                  child: joinOpen
                      ? _JoinPanel(
                          key: const ValueKey('join_panel'),
                          nameController: nameController,
                          codeController: codeController,
                          askName: askName,
                          isJoining: isJoining,
                          error: wizard.joinError,
                          onJoin: onJoin,
                          onClose: () => controller.setCreateNew(true),
                          onCodeChanged: () {
                            if (wizard.joinError != null) {
                              controller.setJoinError(null);
                            }
                          },
                        )
                      : Column(
                          key: const ValueKey('start_actions'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SetupPrimaryButton(
                              text: t.setupStartCreate,
                              onPressed: () {
                                AppHaptics.success();
                                onCreate();
                              },
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextButton.icon(
                              onPressed: () {
                                AppHaptics.selection();
                                controller.setCreateNew(false);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(
                                  AppControlSizes.buttonHeight,
                                ),
                              ),
                              icon: const Icon(Icons.vpn_key_outlined),
                              label: Text(
                                t.setupStartJoin,
                                style: AppTypography.bodyStrong,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    t.setupStartTime,
                    style: AppTypography.caption.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: onSignOut,
                    child: Text(
                      t.setupSignOutLink,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JoinPanel extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final bool askName;
  final bool isJoining;
  final String? error;
  final VoidCallback onJoin;
  final VoidCallback onClose;
  final VoidCallback onCodeChanged;

  const _JoinPanel({
    required this.nameController,
    required this.codeController,
    required this.askName,
    required this.isJoining,
    required this.error,
    required this.onJoin,
    required this.onClose,
    required this.onCodeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return SetupFamilyPanel(
      child: ListenableBuilder(
        listenable: Listenable.merge([codeController, nameController]),
        builder: (context, _) {
          final codeReady = codeController.text.trim().length == 6;
          final nameReady = !askName || nameController.text.trim().isNotEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.setupStartJoinTitle,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 18,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isJoining ? null : onClose,
                    tooltip: t.commonClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                t.setupStartJoinBody,
                style: AppTypography.body.copyWith(color: theme.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              if (askName) ...[
                TextField(
                  controller: nameController,
                  enabled: !isJoining,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t.setupStartJoinNameLabel,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              TextField(
                controller: codeController,
                enabled: !isJoining,
                autofocus: !askName,
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  _UpperCaseFormatter(),
                ],
                style: AppTypography.sectionTitle.copyWith(
                  letterSpacing: 6,
                  color: theme.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: t.setupStartJoinCodeLabel,
                  errorText: error,
                  errorMaxLines: 2,
                  counterText: '',
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                ),
                onChanged: (_) => onCodeChanged(),
                onSubmitted: (_) {
                  if (codeReady && nameReady && !isJoining) onJoin();
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SetupPrimaryButton(
                text: t.setupStartJoinButton,
                isLoading: isJoining,
                onPressed: codeReady && nameReady ? onJoin : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Muestra u oculta un bloque animando el alto, sin saltos de layout.
class _Collapsible extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _Collapsible({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      alignment: Alignment.topCenter,
      child:
          visible ? child : const SizedBox(width: double.infinity, height: 0),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

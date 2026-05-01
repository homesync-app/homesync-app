import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final dynamic prefs;

  const LoginScreen({
    super.key,
    required this.prefs,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUpMode = false;
  final String _loadingMessage = '';

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    log.setScreen('LoginScreen');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.72, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _formKey.currentState?.reset();
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.all(20),
        elevation: 0,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.all(20),
        elevation: 0,
      ),
    );
  }

  bool get _isAdminTestingInput {
    return AppEnvironment.adminTestingPasswordLoginEnabled &&
        _emailController.text.trim().toLowerCase() ==
            AppEnvironment.adminTestingUsername.toLowerCase() &&
        _passwordController.text == AppEnvironment.adminTestingPassword;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    await ref.read(authControllerProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

    final authState = ref.read(authControllerProvider);
    if (authState.hasError && mounted) {
      _showError(authState.error.toString());
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final fullName = _nameController.text.trim();

    await ref.read(authControllerProvider.notifier).signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          fullName.isEmpty ? null : fullName,
        );

    final authState = ref.read(authControllerProvider);
    if (authState.hasError && mounted) {
      _showError(authState.error.toString());
    } else if (mounted) {
      _showSuccess('¡Revisá tu correo para confirmar tu cuenta!');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.mediumImpact();

    final success =
        await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (!success && mounted) {
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        final error = authState.error.toString();
        if (!error.contains('Cancelado')) {
          _showError(error);
        }
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    HapticFeedback.lightImpact();
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF6F2ED),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
            child: const Text('Cancelar'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(132, 48),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Enviar enlace'),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );

    if (confirmed != true) return;

    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Ingresá un correo válido');
      return;
    }

    await ref.read(authControllerProvider.notifier).resetPassword(email);

    final authState = ref.read(authControllerProvider);
    if (authState.hasError && mounted) {
      _showError(authState.error.toString());
    } else if (mounted) {
      _showSuccess('¡Revisá tu correo para cambiar tu contraseña!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackground,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x08FFFFFF),
                      Colors.transparent,
                      Color(0x0CF6E8D8),
                      Color(0x18F4E8DD),
                    ],
                    stops: [0.0, 0.34, 0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -86,
            right: -32,
            child: _LoginOrb(
              size: 214,
              color: AppColors.primary.withValues(alpha: 0.038),
            ),
          ),
          Positioned(
            left: -92,
            bottom: 82,
            child: _LoginOrb(
              size: 182,
              color: AppColors.sage.withValues(alpha: 0.03),
            ),
          ),
          Positioned(
            top: 146,
            left: -54,
            child: _LoginOrb(
              size: 136,
              color: AppColors.primary.withValues(alpha: 0.01),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(theme),
                          const SizedBox(height: 18),
                          _buildAuthPanel(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) _PremiumLoadingOverlay(message: _loadingMessage),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Image.asset(
          'assets/images/login_home_hero.png',
          width: 286,
          height: 286,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
        const SizedBox(height: 0),
        Text(
          _isSignUpMode ? 'Armá tu hogar' : 'Bienvenido',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.3,
            height: 1.05,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 288),
          child: Text(
            _isSignUpMode
                ? 'Creá tu cuenta para empezar a organizar tu hogar.'
                : 'Ingresá para entrar a tu hogar y mantener todo al día.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthPanel(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.theme.surface.withValues(alpha: 0.9),
                AppColors.elevatedSurface.withValues(alpha: 0.93),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.34),
              width: 0.7,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBase.withValues(alpha: 0.012),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _isSignUpMode
                    ? _buildSignUpForm(
                        key: const ValueKey('signup'),
                        theme: theme,
                      )
                    : _buildLoginForm(
                        key: const ValueKey('login'),
                        theme: theme,
                      ),
              ),
              const SizedBox(height: 6),
              _buildModeTogglePrompt(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm({Key? key, required ThemeData theme}) {
    return Form(
      key: _formKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPremiumTextField(
            context: context,
            controller: _emailController,
            hint: 'Email',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              if (_isAdminTestingInput) return null;
              if (!value.contains('@')) return 'Inválido';
              return null;
            },
          ),
          const SizedBox(height: 8),
          _buildPremiumTextField(
            context: context,
            controller: _passwordController,
            hint: 'Contraseña',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            validator: (value) {
              if (value == null || value.length < 6) return 'Inválida';
              return null;
            },
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: _handleForgotPassword,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(6, 4, 6, 2),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xEDEE652B),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildPrimaryButton(label: 'Ingresar', onPressed: _handleLogin),
          const SizedBox(height: 12),
          _buildGoogleDivider(theme),
          const SizedBox(height: 10),
          _buildGoogleButton(theme),
        ],
      ),
    );
  }

  Widget _buildSignUpForm({Key? key, required ThemeData theme}) {
    return Form(
      key: _formKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPremiumTextField(
            context: context,
            controller: _nameController,
            hint: 'Tu nombre o apodo',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Requerido';
              return null;
            },
          ),
          const SizedBox(height: 8),
          _buildPremiumTextField(
            context: context,
            controller: _emailController,
            hint: 'Correo electrónico',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              if (!value.contains('@')) return 'Inválido';
              return null;
            },
          ),
          const SizedBox(height: 8),
          _buildPremiumTextField(
            context: context,
            controller: _passwordController,
            hint: 'Contraseña (mínimo 6 caracteres)',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            validator: (value) {
              if (value == null || value.length < 6) return 'Inválida';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildPrimaryButton(label: 'Crear cuenta', onPressed: _handleSignUp),
          const SizedBox(height: 12),
          _buildGoogleDivider(theme),
          const SizedBox(height: 10),
          _buildGoogleButton(theme),
          const SizedBox(height: 12),
          Text(
            'Al crear una cuenta aceptás nuestros términos y la política de privacidad.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.42),
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E948D),
        ),
        filled: true,
        fillColor: context.theme.surface.withValues(alpha: 0.9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 12),
          child: Icon(
            icon,
            color: AppColors.textMuted.withValues(alpha: 0.82),
            size: 23,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                    size: 23,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  splashRadius: 20,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.82),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        shadowColor: AppColors.primary.withValues(alpha: 0.2),
        elevation: 1.2,
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16.2,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.15,
              ),
            ),
    );
  }

  Widget _buildGoogleButton(ThemeData theme) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return OutlinedButton(
      onPressed: isLoading ? null : _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 13.5),
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(
          color: AppColors.border.withValues(alpha: 0.74),
          width: 1.2,
        ),
        backgroundColor: context.theme.surface.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.google,
            size: 18,
            color: AppColors.sage,
          ),
          const SizedBox(width: 12),
          Text(
            'Google',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleDivider(ThemeData theme) {
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.055);
    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o continuá con',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: color, thickness: 1)),
      ],
    );
  }

  Widget _buildModeTogglePrompt(ThemeData theme) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        Text(
          _isSignUpMode ? '¿Ya tenés cuenta?' : '¿Sos nuevo en HomeSync?',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.56),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          onTap: isLoading ? null : _toggleMode,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              _isSignUpMode ? 'Ingresá' : 'Registrate',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _LoginOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumLoadingOverlay extends StatelessWidget {
  final String message;

  const _PremiumLoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10 * value, sigmaY: 10 * value),
            child: Container(
              color: theme.colorScheme.surface.withValues(alpha: 0.6 * value),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      if (message.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

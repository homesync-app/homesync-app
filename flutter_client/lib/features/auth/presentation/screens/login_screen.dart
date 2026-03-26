import 'dart:ui' show ImageFilter;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/widgets/homesync_logo.dart';

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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    log.setScreen('LoginScreen');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
    ));
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
    HapticFeedback.lightImpact();
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
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 10,
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
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 10,
      ),
    );
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

  bool get _isAdminTestingInput {
    return _emailController.text.trim().toLowerCase() ==
            AppEnvironment.adminTestingUsername.toLowerCase() &&
        _passwordController.text == AppEnvironment.adminTestingPassword;
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
      _showSuccess('¡Revisa tu email para confirmar tu cuenta! 📧');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.heavyImpact();

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
          borderRadius: BorderRadius.circular(30),
        ),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Te enviaremos un link para restablecer tu contraseña.',
              style: TextStyle(
                color: AppColors.textSecondary,
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
                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Enviar link'),
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
      _showSuccess('¡Revisa tu email para cambiar tu contraseña! 📧');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient and Blobs
          Container(decoration: AppTheme.backgroundGradientBox),
          _AnimatedBackgroundBlob(
            top: -100,
            right: -50,
            color: AppColors.primary.withValues(alpha: 0.12),
            size: 400,
            duration: const Duration(seconds: 10),
          ),
          _AnimatedBackgroundBlob(
            bottom: -50,
            left: -50,
            color: AppColors.accentGold.withValues(alpha: 0.08),
            size: 350,
            duration: const Duration(seconds: 12),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogoHeader(),
                          const SizedBox(height: 40),
                          // ── Mode Selector ─────────────────────────────────
                          _buildModeSelector(),
                          const SizedBox(height: 24),
                          // ── Form Card ─────────────────────────────────────
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            child: _isSignUpMode
                                ? _buildSignUpCard(
                                    key: const ValueKey('signup'))
                                : _buildLoginCard(key: const ValueKey('login')),
                          ),
                          const SizedBox(height: 32),
                          _buildModeTogglePrompt(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Premium Loading Overlay
          if (isLoading) _PremiumLoadingOverlay(message: _loadingMessage),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: HomeSyncLogo(size: 96),
        ),
        const SizedBox(height: 24),
        const Text(
          'HomeSync',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'El hogar mejor organizado empieza aquí.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Mode Selector (Login / Registro) ───────────────────────────────────────

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildModeTab(
            label: 'Ingresar',
            isSelected: !_isSignUpMode,
            onTap: () => _isSignUpMode ? _toggleMode() : null,
          ),
          _buildModeTab(
            label: 'Crear cuenta',
            isSelected: _isSignUpMode,
            onTap: () => !_isSignUpMode ? _toggleMode() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  // ── Login Card ─────────────────────────────────────────────────────────────

  Widget _buildLoginCard({Key? key}) {
    return GlassContainer(
      key: key,
      borderRadius: 32,
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenido de nuevo 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ingresa tus datos para continuar',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildPrimaryButton(
              label: 'Entrar al Hogar',
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  // ── Sign Up Card ───────────────────────────────────────────────────────────

  Widget _buildSignUpCard({Key? key}) {
    return GlassContainer(
      key: key,
      borderRadius: 32,
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¡Crea tu cuenta! 🏡',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Completa tus datos para empezar',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            // ── Nombre ──────────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tu nombre',
                hintText: 'Ej: María',
                prefixIcon:
                    const Icon(Icons.person_outline, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                ),
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresá tu nombre';
                }
                if (value.trim().length < 2) return 'Nombre muy corto';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 8),
            // ── Password hint ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Mínimo 6 caracteres',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                ),
              ),
            ),
            _buildPrimaryButton(
              label: 'Crear mi cuenta',
              onPressed: _handleSignUp,
            ),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildGoogleButton(),
            const SizedBox(height: 16),
            // ── Terms note ───────────────────────────────────────────────────
            Text(
              'Al registrarte aceptas nuestros Términos de Servicio y Política de Privacidad.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared Fields ──────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: AppEnvironment.enableAdminTesting
            ? 'Correo electrónico o usuario QA'
            : 'Correo electrónico',
        hintText: AppEnvironment.enableAdminTesting
            ? 'ejemplo@gmail.com o ${AppEnvironment.adminTestingUsername}'
            : 'ejemplo@gmail.com',
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa tu correo';
        if (AppEnvironment.enableAdminTesting && _isAdminTestingInput) {
          return null;
        }
        if (!value.contains('@')) return 'Correo inválido';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Divider(color: AppColors.textMuted.withValues(alpha: 0.2))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o continúa con',
            style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
            child: Divider(color: AppColors.textMuted.withValues(alpha: 0.2))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ).copyWith(
          overlayColor:
              WidgetStateProperty.all(Colors.grey.withValues(alpha: 0.05)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.google,
              size: 20,
              color: Color(0xFFDB4437),
            ),
            SizedBox(width: 14),
            Text(
              'Continuar con Google',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTogglePrompt() {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUpMode ? '¿Ya tenés cuenta?' : '¿Eres nuevo?',
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
        TextButton(
          onPressed: isLoading ? null : _toggleMode,
          child: Text(
            _isSignUpMode ? 'Ingresar' : 'Crea tu cuenta',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedBackgroundBlob extends StatefulWidget {
  final double? top, bottom, left, right;
  final Color color;
  final double size;
  final Duration duration;

  const _AnimatedBackgroundBlob({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_AnimatedBackgroundBlob> createState() =>
      _AnimatedBackgroundBlobState();
}

class _AnimatedBackgroundBlobState extends State<_AnimatedBackgroundBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      _controller.forward();
    } else {
      _controller.repeat(reverse: true);
    }
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: widget.left,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PremiumLoadingOverlay extends StatelessWidget {
  final String message;
  const _PremiumLoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12 * value, sigmaY: 12 * value),
            child: Container(
              color: Colors.black.withValues(alpha: 0.4 * value),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          if (message.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

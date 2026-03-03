import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/main_screen.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_providers.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/error_handler.dart';
import 'package:homesync_client/core/services/logger_service.dart';

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
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
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
    super.dispose();
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
    setState(() => _isLoading = true);
    
    final signInUseCase = ref.read(signInUseCaseProvider);
    final result = await signInUseCase.execute(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          errorHandler.handleAndShow(context, failure, where: 'LoginScreen._handleLogin');
        },
        (_) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(
                prefs: widget.prefs,
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    
    final signUpUseCase = ref.read(signUpUseCaseProvider);
    final result = await signUpUseCase.execute(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      result.fold(
        (failure) => errorHandler.handleAndShow(context, failure, where: 'LoginScreen._handleSignUp'),
        (_) => _showSuccess('¡Revisa tu email para confirmar tu cuenta! 📧'),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isGoogleLoading = true);
    
    final googleSignInUseCase = ref.read(signInWithGoogleUseCaseProvider);
    final result = await googleSignInUseCase.execute();
    
    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isGoogleLoading = false);
          // Only show error if it's not a cancellation
          if (failure.message != 'Cancelado por el usuario') {
             errorHandler.handleAndShow(context, failure, where: 'LoginScreen._handleGoogleSignIn');
          }
        },
        (success) async {
          if (!success) {
            setState(() => _isGoogleLoading = false);
            return;
          }
          
          final authService = ref.read(authServiceProvider);
          await authService.ensureHouseholdExists();
          
          if (mounted) {
            setState(() => _isGoogleLoading = false);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  prefs: widget.prefs,
                ),
              ),
            );
          }
        },
      );
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

    setState(() => _isLoading = true);
    final resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);
    final result = await resetPasswordUseCase.execute(email);
    
    if (mounted) {
      setState(() => _isLoading = false);
      result.fold(
        (failure) => errorHandler.handleAndShow(context, failure, where: 'LoginScreen._handleForgotPassword'),
        (_) => _showSuccess('¡Revisá tu email para cambiar tu contraseña! 📧'),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient and Blobs
          Container(decoration: AppTheme.backgroundGradientBox),
          Positioned(
            top: -100,
            right: -50,
            child: _buildBackgroundBlob(AppColors.primary.withValues(alpha: 0.08), 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBackgroundBlob(AppColors.accentGold.withValues(alpha: 0.05), 250),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                          
                          GlassContainer(
                            borderRadius: 32,
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Inicio de Sesión',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
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
                                  _buildPrimaryButton(),
                                  const SizedBox(height: 24),
                                  _buildDivider(),
                                  const SizedBox(height: 24),
                                  _buildGoogleButton(),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          _buildSignUpPrompt(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Center(
            child: Text('🏡', style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'HomeSync',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestión de hogar para familias modernas',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'ejemplo@gmail.com',
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa tu correo';
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
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: _isLoading || _isGoogleLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
          : const Text(
              'Entrar al Hogar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.textMuted.withValues(alpha: 0.2))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o continúa con',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Divider(color: AppColors.textMuted.withValues(alpha: 0.2))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading || _isGoogleLoading ? null : _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: _isGoogleLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24, color: AppColors.primary),
            ),
      label: const Text(
        'Google Workspace',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Eres nuevo?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        TextButton(
          onPressed: _isLoading || _isGoogleLoading ? null : _handleSignUp,
          child: const Text(
            'Crea tu cuenta',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/core/utils/app_animations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import '../../data/repositories/supabase_household_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/household_providers.dart';

class SetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const SetupScreen({
    required this.onComplete,
    super.key,
  });

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with TickerProviderStateMixin {
  // Steps: 0=Welcome, 1=mode, 2=teamOptions, 3=creating(code display), 4=taskSelection
  int _currentStep = 0;
  String? _selectedMode;
  bool _createNew = true;
  final _codeController = TextEditingController();

  // Invite code shown to "create" users
  String? _myInviteCode;
  bool _isGeneratingCode = false;

  // Join flow state
  bool _isJoining = false;
  String? _joinError;

  // TaskModel selection
  final TemplateService _templateService = TemplateService();
  final Set<String> _selectedTemplateIds = {};
  List<Category> _categories = [];
  Map<String, List<TaskTemplate>> _templatesByCategory = {};
  bool _isLoadingTemplates = true;
  bool _isSaving = false;
  final List<Map<String, dynamic>> _modes = [
    {
      'id': 'couple',
      'name': 'Pareja',
      'icon': '💑',
      'desc': 'Compartimos el hogar juntos',
      'gradient': [Color(0xFF6B8E85), Color(0xFF84A59D)],
    },
    {
      'id': 'family',
      'name': 'Familia',
      'icon': '👨‍👩‍👧‍👦',
      'desc': 'Toda la familia participa',
      'gradient': [Color(0xFFEE652B), Color(0xFFFF8A65)],
    },
    {
      'id': 'roommates',
      'name': 'Compañeros',
      'icon': '🏠',
      'desc': 'Compartimos piso o depto',
      'gradient': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    },
    {
      'id': 'solo',
      'name': 'Solo yo',
      'icon': '👤',
      'desc': 'Mis tareas personales',
      'gradient': [Color(0xFF9575CD), Color(0xFFB39DDB)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
        _categories = categories;
        _templatesByCategory = templatesByCategory;
        _isLoadingTemplates = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingTemplates = false);
    }
  }

  // ── Step handlers ──────────────────────────────────────────────────────────

  void _onModeSelected() {
    HapticFeedback.mediumImpact();
    if (_selectedMode == 'solo') {
      setState(() => _currentStep = 4);
    } else {
      setState(() => _currentStep = 2);
    }
  }

  Future<void> _handleCreateTeam() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isGeneratingCode = true;
    });

    try {
      // Force creation of the household if it was skipped or deleted
      final authService = ref.read(authServiceProvider);
      await authService.ensureHouseholdExists();

      final householdRepo = ref.read(householdRepositoryProvider);
      final result = await householdRepo.generateInvitationCode();
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
              _currentStep = 3; // Solo avanzar si tuvimos éxito
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
      final householdRepo = ref.read(householdRepositoryProvider);
      await householdRepo.joinHousehold(code);

      // Invalida proveedores para que MainScreen/HomeScreen vean el nuevo hogar
      ref.invalidate(householdIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(userBalanceProvider);
      ref.invalidate(householdMembersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Te has unido con éxito! 🎉 Ahora personaliza tus tareas.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isJoining = false;
          _currentStep = 4;
        });
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
    if (_selectedTemplateIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una tarea')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _templateService.cloneTemplates(_selectedTemplateIds.toList());

      // Invalida proveedores aquí también para el flujo de creación
      ref.invalidate(householdIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(userBalanceProvider);
      ref.invalidate(householdMembersProvider);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setup_completed', true);
      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _copyCode() {
    if (_myInviteCode == null) return;
    Clipboard.setData(ClipboardData(text: _myInviteCode!));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Código copiado al portapapeles! 📋'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    if (_myInviteCode == null) return;
    final text =
        '¡Hola! Únete a nuestro hogar en HomeSync.\n\nDescarga la app e ingresa este código: *$_myInviteCode*\n\n🏡 Organizemos nuestro hogar juntos.';
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: AppTheme.backgroundGradientBox,
        child: Stack(
          children: [
            // Background decor
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentTeal.withValues(alpha: 0.05),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildProgressIndicator(),
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
                        0 => _buildWelcomeStep(),
                        1 => _buildModeSelection(),
                        2 => _buildTeamOptions(),
                        3 => _buildInviteCodeStep(),
                        4 => _buildTaskSelection(),
                        _ => _buildWelcomeStep(),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textMuted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 0: Welcome ────────────────────────────────────────────────────────

  Widget _buildWelcomeStep() {
    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Profile/Logo Hero
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(44),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: const Center(
              child: Text('🏡', style: TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 64),

          // Premium Glass Welcome Card
          GlassContainer(
            borderRadius: 32,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Estamos felices de tenerte aquí. HomeSync te ayudará a organizar tu hogar de forma inteligente y divertida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          _buildPrimaryButton(
            text: 'Comenzar Configuración',
            onPressed: () {
              HapticFeedback.heavyImpact();
              setState(() => _currentStep = 1);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Te tomará menos de 1 minuto',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── Step 0: Mode selection ────────────────────────────────────────────────

  Widget _buildModeSelection() {
    return Padding(
      key: const ValueKey('mode'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeading(
            '¡Comencemos!',
            '¿Cómo vas a organizar tu hogar?',
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _modes.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildPremiumModeCard(_modes[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton(
            text: 'Continuar',
            onPressed: _selectedMode != null ? _onModeSelected : null,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                ref.read(signOutUseCaseProvider).execute();
              },
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPremiumModeCard(Map<String, dynamic> mode) {
    final isSelected = _selectedMode == mode['id'];
    final gradient = mode['gradient'] as List<Color>;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedMode = mode['id'] as String);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          mode['icon'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode['name'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mode['desc'] as String,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 28,
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

  // ── Step 1: Create or Join ────────────────────────────────────────────────

  Widget _buildTeamOptions() {
    return Padding(
      key: const ValueKey('team'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeading(
            'Conecta tu hogar',
            '¿Quieres crear un nuevo equipo o unirte a uno?',
          ),
          const SizedBox(height: 32),
          _buildOptionTile(
            icon: Icons.add_home_work_rounded,
            title: 'Crear nuevo hogar',
            desc: 'Genera un código para invitar a tu pareja o familia.',
            isSelected: _createNew,
            onTap: () => setState(() {
              _createNew = true;
              _joinError = null;
            }),
          ),
          const SizedBox(height: 16),
          _buildOptionTile(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Tengo un código',
            desc: 'Ingresa el código que te compartieron para unirte.',
            isSelected: !_createNew,
            onTap: () => setState(() {
              _createNew = false;
              _joinError = null;
            }),
          ),
          const Spacer(),
          if (!_createNew) ...[
            _buildJoinInput(),
            const SizedBox(height: 24),
          ],
          if (_isJoining)
            const Center(child: CircularProgressIndicator())
          else
            _buildPrimaryButton(
              text: _createNew ? 'Crear mi hogar' : 'Unirme ahora',
              onPressed: _createNew ? _handleCreateTeam : _handleJoinTeam,
            ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentStep = 1),
              child: const Text('Volver atrás'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedPress(
      onTap: () {
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinInput() {
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
          const Text(
            'Ingresa el código',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              letterSpacing: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
            maxLength: 6,
            onChanged: (_) => setState(() => _joinError = null),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'ABCDEF',
              hintStyle: TextStyle(
                letterSpacing: 8,
                color: AppColors.textMuted.withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              errorText: _joinError,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  // ── Step 2: Show invite code ──────────────────────────

  Widget _buildInviteCodeStep() {
    return Padding(
      key: const ValueKey('invite'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeading(
            '¡Hogar creado!',
            'Invita a quien quieras compartiendo este código.',
          ),
          const SizedBox(height: 40),

          // Premium Code Card
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AspectRatio(
                aspectRatio: 1.6,
                child: Container(
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Icon(
                            Icons.home_rounded,
                            size: 150,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CÓDIGO DE INVITACIÓN',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                ),
                              ),
                              if (_isGeneratingCode)
                                const CircularProgressIndicator(
                                    color: Colors.white)
                              else
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _myInviteCode ?? '------',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 8,
                                    ),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _shareViaWhatsApp,
                                    icon: const Icon(Icons.send_rounded,
                                        size: 18),
                                    label: const Text('WhatsApp',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      elevation: 0,
                                      minimumSize: const Size(120,
                                          48), // Overrides global infinite width
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filledTonal(
                                    onPressed: _copyCode,
                                    icon: const Icon(Icons.copy_rounded),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white24,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
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

          const SizedBox(height: 40),
          _buildInfoBox(
            'El código es válido por 7 días. Tu pareja solo tiene que ingresarlo al registrarse para compartir el hogar contigo.',
          ),

          const Spacer(),
          _buildPrimaryButton(
            text: 'Ir a seleccionar tareas',
            onPressed: () => setState(() => _currentStep = 4),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 3: Task selection ────────────────────────────────────────────────

  Widget _buildTaskSelection() {
    if (_isLoadingTemplates) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      key: const ValueKey('tasks'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeading(
                'Personaliza tu hogar',
                'Elige las tareas iniciales. Hemos seleccionado algunas por ti.',
              ),
              const SizedBox(height: 16),
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: templates.map((t) => _buildTaskChip(t)).toList(),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: _buildPrimaryButton(
              text: '¡Terminar configuración!',
              isLoading: _isSaving,
              onPressed:
                  _selectedTemplateIds.isNotEmpty ? _saveAndComplete : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskChip(TaskTemplate template) {
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
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              template.title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  // ── Shared UI Components ────────────────────────────────────────────────

  Widget _buildHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                text,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  Widget _buildInfoBox(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homesync_client/core/widgets/homesync_logo.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String _familyStructure = 'mixed';
  String _familyRole = 'Adulto responsable';

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
      'icon': '??',
      'desc': 'Para convivir y organizar gastos de a dos',
      'gradient': [const Color(0xFF6B8E85), const Color(0xFF84A59D)],
    },
    {
      'id': 'family',
      'name': 'Familia',
      'icon': '???????????',
      'desc': 'Toda la familia participa',
      'gradient': [const Color(0xFFEE652B), const Color(0xFFFF8A65)],
    },
    {
      'id': 'friends',
      'name': 'Convivencia',
      'icon': '??',
      'desc': 'Compartimos piso, depto o roommates',
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
    },
    {
      'id': 'solo',
      'name': 'Solo yo',
      'icon': '??',
      'desc': 'Mis tareas personales',
      'gradient': [const Color(0xFF9575CD), const Color(0xFFB39DDB)],
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
    _familyHouseholdNameController.dispose();
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
    if (rawName.isEmpty) return 'Mi familia';

    final firstName = rawName.split(' ').first.trim();
    return '$firstName y familia';
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
      ref.invalidate(householdMembersNotifierProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Te has unido con éxito! ?? Ahora personaliza tus tareas.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isJoining = false;
          _currentStep = _selectedMode == 'solo' ? 7 : 6;
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
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId != null && _selectedMode != null) {
        await ref
            .read(householdRepositoryProvider)
            .updateHouseholdType(householdId, _selectedMode!);
      }

      // Update user profile with name and avatar
      if (!widget.isAdminPreview && _nameController.text.trim().isNotEmpty) {
        final profileResult =
            await ref.read(authRepositoryProvider).updateProfile(
                  fullName: _nameController.text.trim(),
                  avatarUrl: _selectedAvatar,
                );
        profileResult.fold(
          (failure) => throw Exception(failure.message),
          (_) {},
        );
      }

      await _templateService.cloneTemplates(_selectedTemplateIds.toList());

      // Invalida proveedores aquí también para el flujo de creación
      ref.invalidate(householdIdProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(userBalanceProvider);
      ref.invalidate(householdMembersNotifierProvider);

      if (!widget.isAdminPreview) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('setup_completed', true);
      }
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
        content: const Text('¡Código copiado al portapapeles! ??'),
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
                      child: Column(
                        children: [
                          if (widget.isAdminPreview)
                            Container(
                              margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
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
                                  Icon(Icons.auto_fix_high_rounded,
                                      color: AppColors.primary, size: 18),
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
                                0 => _buildValuePropStep(),
                                1 => _buildWelcomeStep(),
                                2 => _buildIdentityStep(),
                                3 => _buildModeSelection(),
                                4 => _buildTeamOptions(),
                                5 => _buildInviteCodeStep(),
                                6 => _buildHouseholdSetupStep(),
                                7 => _buildTaskSelection(),
                                _ => _buildValuePropStep(),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= activeStep;
          final isCurrent = index == activeStep;

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

  // -- Step 0: Value Proposition --------------------------------------------

  Widget _buildValuePropStep() {
    const features = [
      _FeatureItem(
        emoji: '?',
        title: 'Tareas compartidas',
        desc: 'Organizá y asigná tareas del hogar. Ganá XP al completarlas.',
        color: AppColors.primary,
      ),
      _FeatureItem(
        emoji: '??',
        title: 'Gastos en equipo',
        desc: 'Registrá gastos, dividí cuentas y llevá el balance al día.',
        color: Color(0xFF22C55E),
      ),
      _FeatureItem(
        emoji: '??',
        title: 'Gamificación real',
        desc: 'Competí amistosamente, ganate rewards y subí de nivel.',
        color: AppColors.accentGold,
      ),
      _FeatureItem(
        emoji: '??',
        title: 'Lista de compras sync',
        desc: 'Tachá ítems en tiempo real desde cualquier dispositivo.',
        color: AppColors.accentTeal,
      ),
    ];

    return Padding(
      key: const ValueKey('value_prop'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Hero logo
          const Hero(
            tag: 'app_logo',
            child: HomeSyncLogo(
              size: 120,
              showShadow: true,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'HomeSync',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El hogar mejor organizado empieza aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          // Feature cards
          ...features.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 350 + (i * 80)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: _buildFeatureCard(f),
            );
          }),
          const Spacer(flex: 1),
          _buildPrimaryButton(
            text: 'Comenzar ?',
            onPressed: () {
              HapticFeedback.heavyImpact();
              setState(() => _currentStep = 1);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Te llevará menos de 2 minutos',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: feature.color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(feature.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Step 1: Welcome --------------------------------------------------------

  Widget _buildWelcomeStep() {
    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Profile/Logo Hero
          const Hero(
            tag: 'app_logo',
            child: HomeSyncLogo(
              size: 140,
              showShadow: true,
            ),
          ),
          const SizedBox(height: 64),

          // Premium Glass Welcome Card
          // Welcome card
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
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
            text: 'Configurar mi hogar',
            onPressed: () {
              HapticFeedback.heavyImpact();
              setState(() => _currentStep = 2);
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

  // -- Step 2: Identity (Name & Avatar) --------------------------------------

  Widget _buildIdentityStep() {
    return Padding(
      key: const ValueKey('identity'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeading(
              '¿Cómo te llamas?',
              'Personalizá tu perfil para que tu equipo te identifique mejor.',
            ),
            const SizedBox(height: 48),

            // Avatar Selector
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: UserAvatar.getColorForEmoji(_selectedAvatar)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _selectedAvatar,
                        style: const TextStyle(fontSize: 72),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Name Field
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Tu nombre o apodo',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(22),
              ),
              onSubmitted: (_) {
                if (_nameController.text.trim().isNotEmpty) {
                  setState(() => _currentStep = 3);
                }
              },
            ),

            const SizedBox(height: 32),

            // Emoji Picker (Simple horizontal list)
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: UserAvatar.defaultAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = UserAvatar.defaultAvatars[index];
                  final emoji = avatar['emoji'] as String;
                  final isSelected = _selectedAvatar == emoji;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedAvatar = emoji);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 48),

            _buildPrimaryButton(
              text: 'Continuar',
              onPressed: _nameController.text.trim().isEmpty
                  ? null
                  : () {
                      HapticFeedback.heavyImpact();
                      setState(() => _currentStep = 3);
                    },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // -- Step 0: Mode selection ------------------------------------------------

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
                ref.read(authControllerProvider.notifier).signOut();
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
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentStep = 2),
              child: Text(
                '? Ver características de la app',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
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

  // -- Step 1: Create or Join ------------------------------------------------

  Widget _buildTeamOptions() {
    return Padding(
      key: const ValueKey('team_options'),
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
            desc: 'Genera un código para invitar a los miembros de tu hogar.',
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
              onPressed: () => setState(() => _currentStep = 3),
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

  // -- Step 2: Show invite code --------------------------

  // -- Step 2: Show invite code --------------------------

  Widget _buildInviteCodeStep() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeading(
                _selectedMode == 'family' ? 'Familia creada' : 'Hogar creado',
                _selectedMode == 'family'
                    ? 'Comparte este codigo con quienes formen parte del hogar.'
                    : 'Invita a quien quieras compartiendo este codigo.',
              ),
              const SizedBox(height: 40),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'CODIGO DE INVITACION',
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
                                      child: Text(
                                        _myInviteCode ?? '------',
                                        style: const TextStyle(
                                          color: Colors.white,
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
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryButton(
                      text: 'Copiar',
                      icon: Icons.copy_rounded,
                      onTap: _copyCode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSecondaryButton(
                      text: 'Compartir',
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
          child: _buildPrimaryButton(
            text: 'Continuar',
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
          child: const Text('Volver'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  double _tempRatio = 0.5;

  Widget _buildHouseholdSetupStep() {
    if (_selectedMode == 'family') {
      return _buildFamilySetupStep();
    }
    return _buildSplitStep();
  }

  Widget _buildFamilySetupStep() {
    return Padding(
      key: const ValueKey('family_setup'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeading(
            'Base del hogar familiar',
            'Antes de empezar, definamos como se organiza esta familia.',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFamilyPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nombre del hogar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _familyHouseholdNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'Ej: Casa de los Gomez',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFamilyPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de hogar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildFamilyChoiceChip(
                              label: 'Solo adultos',
                              selected: _familyStructure == 'adults',
                              onTap: () => setState(() {
                                _familyStructure = 'adults';
                              }),
                            ),
                            _buildFamilyChoiceChip(
                              label: 'Adultos y chicos',
                              selected: _familyStructure == 'mixed',
                              onTap: () => setState(() {
                                _familyStructure = 'mixed';
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _familyStructure == 'adults'
                              ? 'Ideal para hogares con adultos que comparten tareas y gastos.'
                              : 'Pensado para familias donde tambien participan chicos o hay responsables del hogar.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFamilyPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu rol visible',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            'Adulto responsable',
                            'Madre',
                            'Padre',
                            'Tutor/a',
                          ].map((role) {
                            return _buildFamilyChoiceChip(
                              label: role,
                              selected: _familyRole == role,
                              onTap: () => setState(() {
                                _familyRole = role;
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
          _buildPrimaryButton(
            text: 'Guardar y Continuar',
            onPressed: _saveFamilySetup,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentStep = 7),
              child: const Text('Configurar luego'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFamilyPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }

  Widget _buildFamilyChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _saveFamilySetup() async {
    final householdId = ref.read(householdIdProvider).valueOrNull;
    final currentUserId = ref.read(currentUserIdProvider);
    final householdName = _familyHouseholdNameController.text.trim();

    try {
      if (householdId != null && householdName.isNotEmpty) {
        await Supabase.instance.client
            .from('households')
            .update({'name': householdName}).eq('id', householdId);
        ref.invalidate(currentHouseholdProvider);
      }

      if (currentUserId != null && _familyRole.trim().isNotEmpty) {
        await ref
            .read(householdRepositoryProvider)
            .updateMemberDisplayRole(currentUserId, _familyRole);
        ref.invalidate(householdMembersNotifierProvider);
      }
    } catch (_) {
      // Best effort setup. The family can still continue onboarding.
    }

    if (mounted) {
      setState(() => _currentStep = 7);
    }
  }

  Widget _buildSplitStep() {
    return Padding(
      key: const ValueKey('split'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeading(
            'División de Gastos',
            'Configuremos la base para dividir gastos en ${_selectedMode == 'couple' ? 'pareja' : 'convivencia'}.',
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Text('??', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedMode == 'couple'
                                ? 'Pueden cambiar esto luego en configuracion. Por defecto usamos 50/50.'
                                : 'Pueden cambiar esto luego en configuracion. Por defecto usamos equidad (50/50).',
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(_selectedMode == 'couple' ? 'VOS : PAREJA' : 'VOS : OTROS',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${(_tempRatio * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary)),
                      const Text(' / ',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w300)),
                      Text('${(100 - (_tempRatio * 100)).toInt()}%',
                          style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.error)),
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
                  const SizedBox(height: 40),
                  _buildStrategyTip(
                      'Igualitario (50/50)',
                      _selectedMode == 'couple'
                          ? '?? Ideal para ingresos similares.'
                          : '?? Ideal para ingresos similares o gastos divididos por igual.',
                      _tempRatio == 0.5),
                  _buildStrategyTip('Proporcional',
                      '?? Ajustado a lo que cada uno gana.', _tempRatio != 0.5),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton(
            text: 'Guardar y Continuar',
            onPressed: () async {
              try {
                final householdId = ref.read(householdIdProvider).valueOrNull;
                if (householdId != null) {
                  await ref
                      .read(householdRepositoryProvider)
                      .updateDefaultSplitRatio(householdId, _tempRatio);
                }
              } catch (e) {
                // Ignore error
              }
              setState(() => _currentStep = 7);
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentStep = 7),
              child: const Text('Configurar luego'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStrategyTip(String title, String desc, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: active ? AppColors.primary : AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: active ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.primary : null)),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Step 3: Task selection ------------------------------------------------

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
                _selectedMode == 'family'
                    ? 'Primeras tareas para la familia'
                    : 'Personaliza tu hogar',
                _selectedMode == 'family'
                    ? 'Elige tareas iniciales para coordinar el hogar desde el primer dia.'
                    : 'Elige las tareas iniciales. Hemos seleccionado algunas por ti.',
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

  // -- Shared UI Components ------------------------------------------------

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

  Widget _buildSecondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// -- Data model for value prop features --------------------------------------

class _FeatureItem {
  final String emoji;
  final String title;
  final String desc;
  final Color color;

  const _FeatureItem({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
  });
}


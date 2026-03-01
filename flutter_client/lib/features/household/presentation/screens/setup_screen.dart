import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SetupScreen({required this.onComplete, super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Steps: 0=mode, 1=teamOptions, 2=creating(code display), 3=taskSelection
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

  final SupabaseRpcService _rpc = SupabaseRpcService();

  final List<Map<String, dynamic>> _modes = [
    {
      'id': 'couple',
      'name': 'Pareja',
      'icon': '💑',
      'desc': 'Compartimos el hogar en pareja'
    },
    {
      'id': 'family',
      'name': 'Familia',
      'icon': '👨‍👩‍👧‍👦',
      'desc': 'Toda la familia participa'
    },
    {
      'id': 'roommates',
      'name': 'Compañeros',
      'icon': '🏠',
      'desc': 'Compartimos piso o apartamento'
    },
    {
      'id': 'solo',
      'name': 'Solo yo',
      'icon': '👤',
      'desc': 'Gestiono mis tareas personales'
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
      setState(() => _isLoadingTemplates = false);
    }
  }

  // ── Step handlers ──────────────────────────────────────────────────────────

  void _onModeSelected() {
    if (_selectedMode == 'solo') {
      setState(() => _currentStep = 3); // go straight to TaskModel selection
    } else {
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _handleCreateTeam() async {
    setState(() {
      _isGeneratingCode = true;
      _currentStep = 2;
    });

    try {
      final code = await _rpc.generateInvitationCode();
      setState(() {
        _myInviteCode = code;
        _isGeneratingCode = false;
      });
    } catch (e) {
      // Code generation failed; still allow continuing
      setState(() => _isGeneratingCode = false);
    }
  }

  Future<void> _handleJoinTeam() async {
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
      await _rpc.joinHousehold(code);

      // Mark setup done and update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setup_completed', true);

      if (mounted) widget.onComplete();
    } catch (e) {
      setState(() {
        _isJoining = false;
        _joinError = e.toString().replaceFirst('Exception: ', '');
      });
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setup_completed', true);

      if (mounted) widget.onComplete();
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _copyCode() {
    if (_myInviteCode == null) return;
    Clipboard.setData(ClipboardData(text: _myInviteCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Código copiado'), backgroundColor: AppColors.success),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: switch (_currentStep) {
            0 => _buildModeSelection(),
            1 => _buildTeamOptions(),
            2 => _buildInviteCodeStep(),
            3 => _buildTaskSelection(),
            _ => _buildModeSelection(),
          },
        ),
      ),
    );
  }

  // ── Step 0: Mode selection ────────────────────────────────────────────────

  Widget _buildModeSelection() {
    return Padding(
      key: const ValueKey('mode'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('🏠', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 24),
          const Text(
            '¿Cómo vas a usar\nla app?',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elegí la opción que mejor se adapte a tu situación',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: _modes.map(_buildModeCard).toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMode != null ? _onModeSelected : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(Map<String, dynamic> mode) {
    final isSelected = _selectedMode == mode['id'];

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode['id'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(mode['icon'] as String,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode['name'] as String,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mode['desc'] as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 26),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Create or Join ────────────────────────────────────────────────

  Widget _buildTeamOptions() {
    return Padding(
      key: const ValueKey('team'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Conectá tu hogar',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Querés crear un nuevo hogar o unirte a uno existente?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          _buildOptionCard(
            icon: Icons.add_home_rounded,
            title: 'Crear nuevo hogar',
            desc: 'Generás un código para invitar a tu pareja/familia',
            isSelected: _createNew,
            onTap: () => setState(() {
              _createNew = true;
              _joinError = null;
            }),
          ),
          const SizedBox(height: 14),
          _buildOptionCard(
            icon: Icons.group_add_rounded,
            title: 'Unirme con código',
            desc: 'Ingresá el código que te compartió tu pareja',
            isSelected: !_createNew,
            onTap: () => setState(() {
              _createNew = false;
              _joinError = null;
            }),
          ),
          if (!_createNew) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
              maxLength: 6,
              onChanged: (_) => setState(() => _joinError = null),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'ABC123',
                hintStyle:
                    const TextStyle(letterSpacing: 6, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorText: _joinError,
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
          const Spacer(),
          if (_isJoining)
            const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createNew ? _handleCreateTeam : _handleJoinTeam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _createNew ? 'Crear mi hogar' : 'Unirme ahora',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Center(
                child: Text('Volver',
                    style: TextStyle(color: AppColors.textSecondary))),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Show invite code (for "create" path) ──────────────────────────

  Widget _buildInviteCodeStep() {
    return Padding(
      key: const ValueKey('invite'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Hogar creado!',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compartí este código con tu pareja para que se una',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),

          // Code display card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.04)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: _isGeneratingCode
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : Column(
                    children: [
                      const Text(
                        'Tu código de invitación',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _myInviteCode ?? '------',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _copyCode,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copiar código'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.accent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'El código es válido por 7 días. Tu pareja lo ingresa en la app al crear su cuenta.',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 3),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continuar →',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: TaskModel selection ────────────────────────────────────────────────

  Widget _buildTaskSelection() {
    if (_isLoadingTemplates) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      key: const ValueKey('tasks'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTaskHeader(),
        Expanded(child: _buildTemplateList()),
        _buildTaskFooter(),
      ],
    );
  }

  Widget _buildTaskHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('✨', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Elegí tus tareas',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          const Text(
            'Seleccioná las tareas habituales de tu hogar. Podés agregar más después.',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final templates = _templatesByCategory[category.id] ?? [];

        if (templates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Row(
                children: [
                  Text(category.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    category.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            ...templates.map(_buildTemplateItem),
          ],
        );
      },
    );
  }

  Widget _buildTemplateItem(TaskTemplate template) {
    final isSelected = _selectedTemplateIds.contains(template.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.07)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.inputBorder,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(template.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _rewardBadge(
                      '⭐ ${template.xpReward}', AppColors.accent),
                  const SizedBox(width: 6),
                  _rewardBadge(
                      '🪙 ${template.coinReward}', AppColors.success),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rewardBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildTaskFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isSaving ? null : () => widget.onComplete(),
                child: const Text('Omitir',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAndComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Comenzar (${_selectedTemplateIds.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

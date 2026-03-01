import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({required this.onComplete, super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TemplateService _templateService = TemplateService();
  final Set<String> _selectedTemplateIds = {};

  List<Category> _categories = [];
  Map<String, List<TaskTemplate>> _templatesByCategory = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
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
        _selectedCategory = categories.isNotEmpty ? categories.first.id : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleTemplate(String templateId) {
    setState(() {
      if (_selectedTemplateIds.contains(templateId)) {
        _selectedTemplateIds.remove(templateId);
      } else {
        _selectedTemplateIds.add(templateId);
      }
    });
  }

  Future<void> _saveAndContinue() async {
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
      await prefs.setBool('onboarding_completed', true);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Container(
              decoration: AppTheme.backgroundGradientBox,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    _buildCategorySelector(),
                    Expanded(child: _buildTemplateGrid()),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTitleSection() {
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
            child: const Text('👋', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Hola!',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comencemos configurando algunas tareas comunes para tu hogar.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.inputBorder),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                cat.name,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateGrid() {
    final templates = _templatesByCategory[_selectedCategory] ?? [];
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = _selectedTemplateIds.contains(template.id);
        return GestureDetector(
          onTap: () => _toggleTemplate(template.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(template.icon ?? '📋',
                          style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          template.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.accent, size: 14),
                          const SizedBox(width: 4),
                          Text('${template.xpReward}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => widget.onComplete(),
                child: const Text('Omitir'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAndContinue,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Empezar (${_selectedTemplateIds.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

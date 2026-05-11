import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class EditTaskSheet extends ConsumerStatefulWidget {
  final TaskModel task;

  const EditTaskSheet({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _xpController;
  late TextEditingController _coinController;
  final ScrollController _categoryScrollController = ScrollController();
  String? _selectedCategory;
  bool _isLoading = false;
  bool _didAutoScrollCategory = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _xpController =
        TextEditingController(text: widget.task.xpReward.toString());
    _coinController =
        TextEditingController(text: widget.task.coinReward.toString());
    _selectedCategory = widget.task.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _xpController.dispose();
    _coinController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).editTaskSnackNameRequired,
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final changedCatalogIdentity = title != widget.task.title ||
          _selectedCategory != widget.task.category;
      await ref.read(tasksProvider.notifier).editTask(widget.task.id, {
        'title': title,
        'category': _selectedCategory,
        'xp_reward': int.tryParse(_xpController.text) ?? 0,
        'coin_reward': int.tryParse(_coinController.text) ?? 0,
        if (changedCatalogIdentity) ...{
          'source_template_id': null,
          'title_key': null,
        },
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonErrorWithDetails(e.toString()),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final theme = context.theme;
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.accentRed,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).editTaskDeleteTitle,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: theme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Se va a eliminar "${widget.task.title}" y no se puede deshacer.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).commonCancel,
                        style: TextStyle(
                          color: theme.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.accentRed.withValues(alpha: 0.86),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).editTaskDeleteConfirm,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(tasksProvider.notifier).deleteTask(widget.task);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonErrorWithDetails(e.toString()),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeTaskFromEdit() async {
    final currentUserId = ref.read(currentUserIdProvider);
    final members = ref.read(householdMembersProvider).valueOrNull ?? const [];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChildView = currentMember?.isChild ?? false;

    setState(() => _isLoading = true);
    try {
      if (isChildView) {
        await ref
            .read(tasksProvider.notifier)
            .submitTaskForApproval(widget.task);
      } else {
        await ref.read(tasksProvider.notifier).completeTask(widget.task);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isChildView
                  ? AppLocalizations.of(context).editTaskSnackSentForReview
                  : AppLocalizations.of(context).tasksSnackCompleted,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonErrorWithDetails(e.toString()),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = context.theme;
    final currentCategories = categoriesAsync.maybeWhen(
      data: (list) => list
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'icon': c.icon,
              'color': c.color,
              'translationKey': c.translationKey,
            },
          )
          .toList(),
      orElse: () => <Map<String, dynamic>>[],
    );

    if (!_didAutoScrollCategory && currentCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didAutoScrollCategory) return;
        _scrollToSelectedCategory(currentCategories);
      });
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: theme.border.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  22,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 26),
                    _buildSectionLabel(
                      AppLocalizations.of(context).editTaskSectionDetailEyebrow,
                    ),
                    const SizedBox(height: 10),
                    _buildInputCard(
                      theme,
                      icon: Icons.edit_note_rounded,
                      child: TextField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .editTaskFieldNameHint,
                          hintStyle: TextStyle(
                            color: theme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isCollapsed: true,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildSectionLabel(
                      AppLocalizations.of(context)
                          .editTaskSectionCategoryEyebrow,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 64,
                      child: ListView(
                        controller: _categoryScrollController,
                        scrollDirection: Axis.horizontal,
                        children: currentCategories.map((cat) {
                          final isSelected = _selectedCategory == cat['id'];
                          final color =
                              AppColors.fromHex(cat['color'] ?? '#94A3B8');

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat['id']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              constraints: const BoxConstraints(minWidth: 112),
                              margin: const EdgeInsets.only(right: 14),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withValues(alpha: 0.10)
                                    : theme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? color.withValues(alpha: 0.22)
                                      : theme.border.withValues(alpha: 0.86),
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : theme.cardShadow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withValues(alpha: 0.10)
                                          : const Color(0xFFF8FAFC),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      CategoryMapping.getCategoryMaterialIcon(
                                        cat['name'],
                                      ),
                                      color: color,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      localizedTaskCatalogText(
                                        AppLocalizations.of(context),
                                        cat['translationKey'] as String?,
                                        cat['name']! as String,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w700,
                                        color: isSelected
                                            ? color
                                            : theme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildSectionLabel(
                      AppLocalizations.of(context).editTaskSectionRewardEyebrow,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputCard(
                            theme,
                            icon: Icons.star_rounded,
                            iconColor: AppColors.accentGold,
                            child: TextField(
                              controller: _xpController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'XP',
                                hintStyle: TextStyle(
                                  color: theme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                isCollapsed: true,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildInputCard(
                            theme,
                            icon: Icons.monetization_on_rounded,
                            iconColor: AppColors.sage,
                            child: TextField(
                              controller: _coinController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)
                                    .createTaskFieldCoinsLabel,
                                hintStyle: TextStyle(
                                  color: theme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                isCollapsed: true,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
              decoration: BoxDecoration(
                color: theme.background.withValues(alpha: 0.98),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).commonCancel,
                        style: TextStyle(
                          color: theme.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.13),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)
                                    .editTaskSaveChanges,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
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

  Widget _buildHeader(AppThemeColors theme) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final members = ref.watch(householdMembersProvider).valueOrNull ?? const [];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChildView = currentMember?.isChild ?? false;
    final canComplete = widget.task.isPending;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.edit_outlined,
            color: theme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).editTaskHeaderTitle,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).editTaskHeaderSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              if (canComplete) ...[
                TextButton.icon(
                  onPressed: _isLoading ? null : _completeTaskFromEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  icon: Icon(
                    isChildView ? Icons.send_rounded : Icons.check_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isChildView
                        ? AppLocalizations.of(context)
                            .editTaskSubmitForReviewButton
                        : AppLocalizations.of(context).editTaskCompleteButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextButton.icon(
                onPressed: _isLoading ? null : _deleteTask,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: AppColors.accentRed.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.accentRed.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(
                  AppLocalizations.of(context).editTaskDeleteTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).commonClose,
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          splashRadius: 22,
          icon: Icon(
            Icons.close_rounded,
            color: theme.textMuted.withValues(alpha: 0.82),
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.15,
      ),
    );
  }

  Widget _buildInputCard(
    AppThemeColors theme, {
    required Widget child,
    required IconData icon,
    Color? iconColor,
  }) {
    final resolvedColor = iconColor ?? theme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.9),
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: resolvedColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: resolvedColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  void _scrollToSelectedCategory(List<Map<String, dynamic>> categories) {
    final selectedIndex =
        categories.indexWhere((cat) => cat['id'] == _selectedCategory);
    _didAutoScrollCategory = true;

    if (selectedIndex <= 0 || !_categoryScrollController.hasClients) {
      return;
    }

    const itemWidthEstimate = 126.0;
    final targetOffset = (selectedIndex * itemWidthEstimate) - 24;
    final maxOffset = _categoryScrollController.position.maxScrollExtent;

    _categoryScrollController.animateTo(
      targetOffset.clamp(0.0, maxOffset),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }
}

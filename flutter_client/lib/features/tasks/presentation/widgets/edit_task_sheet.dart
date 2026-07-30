import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

const int _maxTaskXpReward = 50;
const int _maxTaskCoinReward = 5;

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

    final isCouple =
        ref.read(householdCapabilitiesProvider).type == HouseholdType.couple;
    final xpReward = isCouple ? 0 : int.tryParse(_xpController.text);
    final coinReward = isCouple ? 0 : int.tryParse(_coinController.text);
    if (xpReward == null ||
        coinReward == null ||
        xpReward < 0 ||
        xpReward > _maxTaskXpReward ||
        coinReward < 0 ||
        coinReward > _maxTaskCoinReward) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).createTaskValidationRewardRange,
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
        'xp_reward': xpReward,
        'coin_reward': coinReward,
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
                      borderRadius: BorderRadius.circular(AppRadii.md),
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
                      style: AppTypography.sectionTitle.copyWith(
                        fontSize: 21,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context).editTaskDeleteBody(
                  widget.task.title,
                ),
                style: AppTypography.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).commonCancel,
                        style: AppTypography.cardTitle.copyWith(
                          color: theme.textMuted,
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
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).editTaskDeleteConfirm,
                        style: AppTypography.cardTitle,
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
    final members = ref.read(householdMembersProvider).value ?? const [];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final approvalMode =
        ref.read(currentHouseholdProvider).value?.taskApprovalMode;
    final requiresApprovalSubmission = ref.read(taskApprovalEnabledProvider) &&
        (currentMember?.needsSubmissionApproval(approvalMode) ?? false);

    setState(() => _isLoading = true);
    try {
      if (requiresApprovalSubmission) {
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
              requiresApprovalSubmission
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
    final showGamification =
        ref.watch(householdCapabilitiesProvider).type != HouseholdType.couple;
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
                borderRadius: BorderRadius.circular(AppRadii.pill),
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
                        style: AppTypography.cardTitle.copyWith(
                          color: theme.textPrimary,
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
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xl),
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
                    if (showGamification) ...[
                      const SizedBox(height: 22),
                      _buildSectionLabel(
                        AppLocalizations.of(context)
                            .editTaskSectionRewardEyebrow,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputCard(
                              theme,
                              icon: Icons.star_rounded,
                              iconColor: AppColors.xpGold,
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
                                style: AppTypography.cardTitle.copyWith(
                                  color: theme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildInputCard(
                              theme,
                              icon: Icons.monetization_on_rounded,
                              iconColor: AppColors.coinGreen,
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
                                style: AppTypography.cardTitle.copyWith(
                                  color: theme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).commonCancel,
                        style: AppTypography.cardTitle.copyWith(
                          color: theme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
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
                            borderRadius: BorderRadius.circular(AppRadii.lg),
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
                                style: AppTypography.cardTitle,
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
    final members = ref.watch(householdMembersProvider).value ?? const [];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final approvalMode =
        ref.watch(currentHouseholdProvider).value?.taskApprovalMode;
    final requiresApprovalSubmission = ref.watch(taskApprovalEnabledProvider) &&
        (currentMember?.needsSubmissionApproval(approvalMode) ?? false);
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
                style: AppTypography.sectionTitle.copyWith(
                  fontSize: 21,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).editTaskHeaderSubtitle,
                style: AppTypography.caption.copyWith(
                  fontSize: 13,
                  height: 1.35,
                  color: theme.textSecondary,
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
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  icon: Icon(
                    requiresApprovalSubmission
                        ? Icons.send_rounded
                        : Icons.check_rounded,
                    size: 18,
                  ),
                  label: Text(
                    requiresApprovalSubmission
                        ? AppLocalizations.of(context)
                            .editTaskSubmitForReviewButton
                        : AppLocalizations.of(context).editTaskCompleteButton,
                    style: AppTypography.bodyStrong.copyWith(
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
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    side: BorderSide(
                      color: AppColors.accentRed.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(
                  AppLocalizations.of(context).editTaskDeleteTitle,
                  style: AppTypography.bodyStrong.copyWith(
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
      style: AppTypography.eyebrow.copyWith(
        fontSize: 12,
        color: AppColors.textMuted,
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

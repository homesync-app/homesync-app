import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

import 'task_creation_result.dart';

String? _readString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

Map<String, dynamic>? _readStringKeyedMap(Object? value) {
  if (value is! Map) return null;
  return <String, dynamic>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

Map<String, dynamic>? _normalizeMember(Map<String, dynamic> member) {
  final userId = _readString(member['user_id']);
  if (userId == null) return null;
  final user = _readStringKeyedMap(member['users']);
  return <String, dynamic>{
    ...member,
    'user_id': userId,
    if (user != null) 'users': user,
  };
}

const int _maxTaskXpReward = 50;
const int _maxTaskCoinReward = 5;

class CreateTaskDialog extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>>? members;

  const CreateTaskDialog({super.key, this.members});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _xpController = TextEditingController();
  final _coinController = TextEditingController();

  String? _selectedCategory;
  String _selectedDifficulty = 'medium';
  String? _selectedMemberId;

  /// Sprint 3 Modo Padres: pool de miembros entre los que rota la tarea.
  /// Solo se usa cuando la recurrencia esta seteada y el usuario tiene Modo
  /// Padres activo. Si esta vacio o tiene 1 solo miembro, no hay rotacion.
  final Set<String> _rotationPool = <String>{};
  String? _selectedRecurrence;
  String _customRecurrenceMode = 'weekdays';
  final Set<int> _selectedWeekdays = {};
  int _recurrenceInterval = 1;
  final Set<int> _selectedMonthDays = {};
  bool _customRewards = false;
  bool _isLoading = false;
  bool _showSuccessState = false;
  bool _membersLoading = false;
  bool _membersLoadFailed = false;
  List<Map<String, dynamic>> _members = [];

  // Difficulty/recurrence display names are looked up by id at render time
  // via [_difficultyName] / [_recurrenceName] so they follow the active locale.
  final List<Map<String, dynamic>> _difficulties = [
    {'id': 'easy', 'xp': 5, 'coins': 1},
    {'id': 'medium', 'xp': 10, 'coins': 1},
    {'id': 'hard', 'xp': 20, 'coins': 2},
  ];

  final List<Map<String, String>> _recurrenceOptions = [
    {'id': 'daily'},
    {'id': 'weekly'},
    {'id': 'monthly'},
  ];

  String _difficultyName(AppLocalizations t, String id) {
    switch (id) {
      case 'easy':
        return t.createTaskDifficultyEasy;
      case 'hard':
        return t.createTaskDifficultyHard;
      default:
        return t.createTaskDifficultyMedium;
    }
  }

  String _recurrenceName(AppLocalizations t, String id) {
    switch (id) {
      case 'daily':
        return t.createTaskRecurrenceDaily;
      case 'weekly':
        return t.createTaskRecurrenceWeekly;
      case 'monthly':
        return t.createTaskRecurrenceMonthly;
      default:
        return id;
    }
  }

  Map<String, dynamic> get _currentDifficulty => _difficulties.firstWhere(
        (difficulty) => difficulty['id'] == _selectedDifficulty,
        orElse: () => _difficulties[1],
      );

  @override
  void initState() {
    super.initState();
    if (widget.members != null && widget.members!.isNotEmpty) {
      _members = widget.members!
          .map(_normalizeMember)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    } else {
      _loadMembers();
    }
    _loadDefaultCategory();
    _updateRewardControllers();
  }

  void _updateRewardControllers() {
    final difficulty = _currentDifficulty;
    _xpController.text = difficulty['xp'].toString();
    _coinController.text = difficulty['coins'].toString();
  }

  Future<void> _loadMembers() async {
    if (mounted) {
      setState(() {
        _membersLoading = true;
        _membersLoadFailed = false;
      });
    }
    try {
      final members = await ref.read(householdMembersProvider.future);
      if (!mounted) return;
      setState(() {
        _members = members
            .map((member) => _normalizeMember(member.toMap()))
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
        _membersLoading = false;
      });
    } catch (error, stackTrace) {
      log.e(
        'CreateTaskDialog failed to load members',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _membersLoading = false;
        _membersLoadFailed = true;
      });
    }
  }

  Future<void> _loadDefaultCategory() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      if (!mounted || categories.isEmpty || _selectedCategory != null) return;
      setState(() => _selectedCategory = categories.first.id);
    } catch (error, stackTrace) {
      log.e(
        'CreateTaskDialog failed to load default task category',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String? _validateCustomRecurrence() {
    if (_selectedRecurrence != 'custom') return null;

    final t = AppLocalizations.of(context);
    switch (_customRecurrenceMode) {
      case 'weekdays':
        if (_selectedWeekdays.isEmpty) {
          return t.createTaskValidationCustomDays;
        }
        break;
      case 'month_days':
        if (_selectedMonthDays.isEmpty) {
          return t.createTaskValidationCustomMonthDates;
        }
        break;
      case 'interval':
        if (_recurrenceInterval < 1) {
          return t.createTaskValidationInterval;
        }
        break;
    }

    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).createTaskSnackCategoryNotReady,
          ),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    final recurrenceError = _validateCustomRecurrence();
    if (recurrenceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recurrenceError),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final tasks = ref.read(tasksProvider).value ?? [];
    final isDuplicate = tasks.any((task) {
      final sameTitle = task.title.toLowerCase().trim() == title.toLowerCase();
      final sameCategory = task.category == _selectedCategory;
      final sameAssignee = task.assignedTo == _selectedMemberId;
      return task.isActive && sameTitle && sameCategory && sameAssignee;
    });

    if (isDuplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).createTaskSnackDuplicate,
            ),
            backgroundColor: AppColors.accentOrange,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Sprint 3 Modo Padres: si hay pool valido (recurrente + 2+ miembros)
      // arrancamos asignando al primero del pool y delegamos la rotacion al
      // server (advance_task_rotation) en cada completion.
      final List<String>? rotationPoolList =
          (_selectedRecurrence != null && _rotationPool.length >= 2)
              ? _rotationPool.toList()
              : null;
      final assignedTo =
          rotationPoolList != null ? rotationPoolList.first : _selectedMemberId;
      final isCouple =
          ref.read(householdCapabilitiesProvider).type == HouseholdType.couple;

      await ref.read(tasksProvider.notifier).createTask({
        'title': title,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'xpReward': isCouple ? 0 : int.tryParse(_xpController.text) ?? 10,
        'coinReward': isCouple ? 0 : int.tryParse(_coinController.text) ?? 1,
        'assignedTo': assignedTo,
        'recurrenceType': _selectedRecurrence,
        'recurrenceInterval': _recurrenceInterval,
        'recurrenceWeekdays':
            _selectedRecurrence == 'custom' ? _selectedWeekdays.toList() : null,
        'recurrenceMonthDays': _selectedRecurrence == 'custom'
            ? _selectedMonthDays.toList()
            : null,
        'rotationPool': rotationPoolList,
      });

      if (!mounted) return;
      AppHaptics.success();
      setState(() => _showSuccessState = true);
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (mounted) {
        Navigator.of(context).pop(
          TaskCreationResult(title: title, category: _selectedCategory!),
        );
      }
    } catch (error, stackTrace) {
      log.e(
        'Create task failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showSuccessState = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final showGamification =
        ref.watch(householdCapabilitiesProvider).type != HouseholdType.couple;
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;
    final availableHeight = media.size.height -
        media.padding.top -
        media.padding.bottom -
        keyboardInset -
        48;
    final maxDialogHeight = availableHeight.clamp(320.0, 640.0);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <CategoryModel>[],
    );

    final currentCategoryId =
        _selectedCategory ?? (categories.isNotEmpty ? categories.first.id : '');

    return Dialog(
      backgroundColor: theme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.modal),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: theme.surfaceContainer,
            labelStyle: TextStyle(color: theme.textSecondary),
            hintStyle: TextStyle(color: theme.textMuted),
            prefixIconColor: theme.textSecondary,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: theme.border),
            ),
          ),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: maxDialogHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.16),
                          ),
                        ),
                        child: const Icon(
                          Icons.add_task_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .createTaskHeaderTitle,
                              style: AppTypography.sectionTitle.copyWith(
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            AppLocalizations.of(context)
                                .createTaskSectionDetailEyebrow,
                            AppLocalizations.of(context)
                                .createTaskSectionDetailTitle,
                            AppLocalizations.of(context)
                                .createTaskSectionDetailSubtitle,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)
                                  .createTaskFieldTitleLabel,
                              prefixIcon: const Icon(Icons.edit_note_rounded),
                            ),
                            validator: (value) {
                              final title = value?.trim() ?? '';
                              if (title.isEmpty) {
                                return AppLocalizations.of(context)
                                    .createTaskValidationTitleRequired;
                              }
                              if (title.length < 3) {
                                return 'Usa al menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)
                                  .createTaskFieldNotesLabel,
                              hintText:
                                  'ej: "usar el limpiapisos azul", "revisar el filtro tambien"',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                                child: Icon(Icons.notes_rounded),
                              ),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildSectionHeader(
                            AppLocalizations.of(context)
                                .createTaskSectionCategoryEyebrow,
                            AppLocalizations.of(context)
                                .createTaskSectionCategoryTitle,
                            AppLocalizations.of(context)
                                .createTaskSectionCategorySubtitle,
                          ),
                          const SizedBox(height: 10),
                          categoriesAsync.when(
                            data: (_) => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Row(
                                children: categories.map((category) {
                                  final isSelected =
                                      currentCategoryId == category.id;
                                  final color =
                                      AppColors.fromHex(category.color);
                                  final categoryLabel =
                                      localizedTaskCategoryName(
                                    AppLocalizations.of(context),
                                    category,
                                  );
                                  return _buildAccessibleSelector(
                                    label: categoryLabel,
                                    selected: isSelected,
                                    onTap: () => setState(
                                      () => _selectedCategory = category.id,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.pill),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: AppSpacing.md,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? color.withValues(
                                                      alpha: 0.15,
                                                    )
                                                  : theme.surfaceContainer,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? color
                                                    : theme.border,
                                                width: isSelected ? 2.5 : 1.5,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: color.withValues(
                                                          alpha: 0.2,
                                                        ),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                CategoryMapping
                                                    .getCategoryMaterialIcon(
                                                  category.id,
                                                ),
                                                color: isSelected
                                                    ? color
                                                    : color.withValues(
                                                        alpha: 0.8,
                                                      ),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            categoryLabel,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isSelected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? color
                                                  : theme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            loading: () => const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: AppSpacing.md),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (error, stackTrace) => AppErrorState(
                              message: AppLocalizations.of(context).commonError,
                              onRetry: () {
                                ref.invalidate(categoriesProvider);
                                _loadDefaultCategory();
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSectionHeader(
                            AppLocalizations.of(context)
                                .createTaskSectionFrequencyEyebrow,
                            AppLocalizations.of(context)
                                .createTaskSectionFrequencyTitle,
                            AppLocalizations.of(context)
                                .createTaskSectionFrequencySubtitle,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFrequencyChip(
                                AppLocalizations.of(context)
                                    .createTaskRecurrenceNone,
                                null,
                              ),
                              ..._recurrenceOptions.map(
                                (recurrence) => _buildFrequencyChip(
                                  _recurrenceName(
                                    AppLocalizations.of(context),
                                    recurrence['id']!,
                                  ),
                                  recurrence['id'],
                                ),
                              ),
                              _buildFrequencyChip(
                                AppLocalizations.of(context)
                                    .createTaskRecurrenceCustom,
                                'custom',
                              ),
                            ],
                          ),
                          if (_selectedRecurrence == 'custom') ...[
                            const SizedBox(height: 16),
                            _buildCustomRecurrenceMenu(),
                          ],
                          const SizedBox(height: 20),
                          _buildSectionHeader(
                            AppLocalizations.of(context)
                                .createTaskSectionAssigneeEyebrow,
                            AppLocalizations.of(context)
                                .createTaskSectionAssigneeTitle,
                            AppLocalizations.of(context)
                                .createTaskSectionAssigneeSubtitle,
                          ),
                          const SizedBox(height: 10),
                          if (_membersLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else if (_membersLoadFailed)
                            AppErrorState(
                              message: AppLocalizations.of(context).commonError,
                              onRetry: _loadMembers,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildAssigneeChip(
                                  AppLocalizations.of(context)
                                      .createTaskAssigneeAnyone,
                                  null,
                                  'C',
                                ),
                                ..._members.expand<Widget>((member) {
                                  final userId = _readString(member['user_id']);
                                  if (userId == null) return const <Widget>[];
                                  final user =
                                      _readStringKeyedMap(member['users']);
                                  final name = _readString(
                                        user?['full_name'],
                                      ) ??
                                      _readString(user?['email']) ??
                                      AppLocalizations.of(context)
                                          .settingsHouseholdMemberFallbackName;
                                  final initial =
                                      name.substring(0, 1).toUpperCase();
                                  return <Widget>[
                                    _buildAssigneeChip(
                                      name,
                                      userId,
                                      initial,
                                    ),
                                  ];
                                }),
                              ],
                            ),
                          const SizedBox(height: 20),
                          _buildRotationSection(),
                          _buildSectionHeader(
                            showGamification
                                ? AppLocalizations.of(context)
                                    .createTaskSectionValueEyebrow
                                : AppLocalizations.of(context)
                                    .coupleSpaceTaskEffortEyebrow,
                            showGamification
                                ? AppLocalizations.of(context)
                                    .createTaskSectionValueTitle
                                : AppLocalizations.of(context)
                                    .coupleSpaceTaskEffortTitle,
                            showGamification
                                ? AppLocalizations.of(context)
                                    .createTaskSectionValueSubtitle
                                : AppLocalizations.of(context)
                                    .coupleSpaceTaskEffortSubtitle,
                          ),
                          const SizedBox(height: 10),
                          _buildDifficultySection(),
                          if (showGamification) ...[
                            const SizedBox(height: 16),
                            _buildRewardsSection(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).commonCancel,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.14),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: AnimatedPress(
                            scale: _isLoading ? 1 : 0.97,
                            onTap: _isLoading ? null : _handleSubmit,
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                disabledBackgroundColor: AppColors.textPrimary,
                                disabledForegroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.lg),
                                ),
                                elevation: 0,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOutBack,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _isLoading
                                    ? const SizedBox(
                                        key: ValueKey('loading'),
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : _showSuccessState
                                        ? Row(
                                            key: const ValueKey('success'),
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .createTaskSnackCreated,
                                                style: AppTypography.cardTitle
                                                    .copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            key: const ValueKey('idle'),
                                            AppLocalizations.of(context)
                                                .createTaskCreateButton,
                                            style: AppTypography.cardTitle
                                                .copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String eyebrow, String title, String subtitle) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: AppTypography.eyebrow.copyWith(
            color: AppColors.primary.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibleSelector({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
    required Widget child,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          excludeFromSemantics: true,
          child: child,
        ),
      ),
    );
  }

  Widget _buildFrequencyChip(String label, String? value) {
    final theme = context.theme;
    final isSelected = _selectedRecurrence == value;
    return _buildAccessibleSelector(
      label: label,
      selected: isSelected,
      onTap: () => setState(() {
        _selectedRecurrence = value;
        if (value == 'custom' &&
            _selectedWeekdays.isEmpty &&
            _selectedMonthDays.isEmpty) {
          _selectedWeekdays.add(DateTime.now().weekday);
        }
      }),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGold.withValues(alpha: 0.15)
              : theme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isSelected ? AppColors.accentGold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.accentGold : theme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRecurrenceMenu() {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final t = AppLocalizations.of(context);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCustomModeTab(
                    t.createTaskCustomTabWeekdays,
                    'weekdays',
                  ),
                  _buildCustomModeTab(
                    t.createTaskCustomTabInterval,
                    'interval',
                  ),
                  _buildCustomModeTab(
                    t.createTaskCustomTabMonthDays,
                    'month_days',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (_customRecurrenceMode == 'weekdays') _buildWeekdaySelector(),
          if (_customRecurrenceMode == 'interval') _buildIntervalSelector(),
          if (_customRecurrenceMode == 'month_days') _buildMonthDaySelector(),
        ],
      ),
    );
  }

  Widget _buildCustomModeTab(String label, String mode) {
    final isSelected = _customRecurrenceMode == mode;
    return _buildAccessibleSelector(
      label: label,
      selected: isSelected,
      onTap: () => setState(() => _customRecurrenceMode = mode),
      borderRadius: BorderRadius.circular(AppRadii.xs),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: 24,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final days = [
      t.createTaskWeekdayMonday,
      t.createTaskWeekdayTuesday,
      t.createTaskWeekdayWednesday,
      t.createTaskWeekdayThursday,
      t.createTaskWeekdayFriday,
      t.createTaskWeekdaySaturday,
      t.createTaskWeekdaySunday,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = _selectedWeekdays.contains(dayNum);
        return _buildAccessibleSelector(
          label: days[index],
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedWeekdays.remove(dayNum);
              } else {
                _selectedWeekdays.add(dayNum);
              }
            });
          },
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : theme.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : theme.border,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIntervalSelector() {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.createTaskCustomRepeatEvery,
          style: TextStyle(color: theme.textSecondary),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: t.createTaskCustomDecreaseTooltip,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.remove,
                  size: 20,
                  color: theme.textSecondary,
                ),
                onPressed: () {
                  if (_recurrenceInterval > 1) {
                    setState(() => _recurrenceInterval--);
                  }
                },
              ),
              Container(
                alignment: Alignment.center,
                width: 30,
                child: Text(
                  _recurrenceInterval.toString(),
                  style: AppTypography.cardTitle.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: t.createTaskCustomIncreaseTooltip,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.add,
                  size: 20,
                  color: theme.textSecondary,
                ),
                onPressed: () {
                  if (_recurrenceInterval < 365) {
                    setState(() => _recurrenceInterval++);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'dias',
          style: TextStyle(color: theme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMonthDaySelector() {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      children: [
        Text(
          t.createTaskCustomMonthDaysHelp,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(31, (index) {
            final day = index + 1;
            final isSelected = _selectedMonthDays.contains(day);
            return _buildAccessibleSelector(
              label: day.toString(),
              selected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedMonthDays.remove(day);
                  } else {
                    _selectedMonthDays.add(day);
                  }
                });
              },
              borderRadius: BorderRadius.circular(AppRadii.xs),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen
                      : theme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                  border: Border.all(
                    color: isSelected ? AppColors.accentGreen : theme.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : theme.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Sprint 3 Modo Padres: selector de pool de rotacion. Solo se muestra
  /// cuando la tarea es recurrente y el usuario tiene Modo Padres disponible
  /// (admin de family con premium). Si el flag no esta, devolvemos un
  /// SizedBox.shrink y la seccion no ocupa lugar.
  Widget _buildRotationSection() {
    if (_selectedRecurrence == null) return const SizedBox.shrink();
    final theme = context.theme;
    final available = ref.watch(parentModeAvailableProvider);
    if (!available) return const SizedBox.shrink();
    if (_members.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          AppLocalizations.of(context).createTaskSectionRotationEyebrow,
          AppLocalizations.of(context).createTaskSectionRotationTitle,
          AppLocalizations.of(context).createTaskSectionRotationSubtitle,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _members.map((member) {
            final id = _readString(member['user_id']);
            if (id == null) return const SizedBox.shrink();
            final user = _readStringKeyedMap(member['users']);
            final name = _readString(user?['full_name']) ??
                _readString(user?['email']) ??
                AppLocalizations.of(context)
                    .settingsHouseholdMemberFallbackName;
            final initial = name.substring(0, 1).toUpperCase();
            final selected = _rotationPool.contains(id);
            return _buildAccessibleSelector(
              label: name.toString(),
              selected: selected,
              onTap: () => setState(() {
                if (selected) {
                  _rotationPool.remove(id);
                } else {
                  _rotationPool.add(id);
                }
              }),
              borderRadius: BorderRadius.circular(AppRadii.modal),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentBlue.withValues(alpha: 0.12)
                      : theme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadii.modal),
                  border: Border.all(
                    color: selected ? AppColors.accentBlue : theme.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: selected
                          ? AppColors.accentBlue
                          : const Color(0xFFCBD5E1),
                      child: Text(
                        initial,
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name.toString(),
                      style: AppTypography.caption.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.accentBlue
                            : theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_rotationPool.length == 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              AppLocalizations.of(context).createTaskRotationMinimumPeople,
              style: AppTypography.caption.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.accentOrange,
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAssigneeChip(String name, String? id, String initial) {
    final theme = context.theme;
    final isSelected = _selectedMemberId == id;
    return _buildAccessibleSelector(
      label: name,
      selected: isSelected,
      onTap: () => setState(() => _selectedMemberId = id),
      borderRadius: BorderRadius.circular(AppRadii.modal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.modal),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
              child: Text(
                initial,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name.split(' ')[0],
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    final theme = context.theme;
    final showGamification =
        ref.watch(householdCapabilitiesProvider).type != HouseholdType.couple;
    return Row(
      children: _difficulties.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDifficulty = difficulty['id'] as String;
                if (!_customRewards) {
                  _updateRewardControllers();
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: difficulty != _difficulties.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : theme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _difficultyName(
                      AppLocalizations.of(context),
                      difficulty['id'] as String,
                    ),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : theme.textPrimary,
                    ),
                  ),
                  if (showGamification) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${difficulty['xp']} XP / ${difficulty['coins']}',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : theme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 11,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.coinGreen,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRewardsSection() {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).createTaskRewardsTitle,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _customRewards = !_customRewards;
                  if (!_customRewards) {
                    _updateRewardControllers();
                  }
                }),
                child: Row(
                  children: [
                    Icon(
                      _customRewards
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color:
                          _customRewards ? AppColors.primary : theme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).createTaskCustomizeRewards,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _customRewards
                            ? AppColors.primary
                            : theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _xpController,
                  enabled: _customRewards,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'XP',
                    prefixIcon: Icon(
                      Icons.star_rounded,
                      color: AppColors.xpGold,
                      size: 20,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: TextStyle(
                    color: _customRewards ? theme.textPrimary : theme.textMuted,
                  ),
                  validator: (value) {
                    if (!_customRewards) return null;
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null) {
                      return AppLocalizations.of(context)
                          .createTaskValidationNumberRequired;
                    }
                    if (parsed < 0 || parsed > _maxTaskXpReward) {
                      return AppLocalizations.of(context)
                          .createTaskValidationRewardRange;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _coinController,
                  enabled: _customRewards,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).createTaskFieldCoinsLabel,
                    prefixIcon: const Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.coinGreen,
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: TextStyle(
                    color: _customRewards ? theme.textPrimary : theme.textMuted,
                  ),
                  validator: (value) {
                    if (!_customRewards) return null;
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null) {
                      return AppLocalizations.of(context)
                          .createTaskValidationNumberRequired;
                    }
                    if (parsed < 0 || parsed > _maxTaskCoinReward) {
                      return AppLocalizations.of(context)
                          .createTaskValidationRewardRange;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

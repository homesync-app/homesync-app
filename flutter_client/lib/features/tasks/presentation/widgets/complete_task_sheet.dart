import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import '../../../household/data/repositories/supabase_household_repository.dart';
import '../../data/repositories/supabase_task_repository.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/core/services/logger_service.dart';

class CompleteTaskSheet extends ConsumerStatefulWidget {
  final VoidCallback onTasksCompleted;

  const CompleteTaskSheet({
    super.key,
    required this.onTasksCompleted,
  });

  @override
  ConsumerState<CompleteTaskSheet> createState() => _CompleteTaskSheetState();
}

class _CompleteTaskSheetState extends ConsumerState<CompleteTaskSheet> {
  final Set<String> _selectedTaskIds = {};
  final Set<String> _selectedMemberIds = {};
  final Set<String> _selectedCategories = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<TaskModel> _allTasks = [];
  List<Map<String, dynamic>> _members = [];

  DateTime _customDate = DateTime.now();
  bool _isRightNow = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadData();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      _selectedMemberIds.add(currentUserId);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) return;

      final taskRepo = ref.read(taskRepositoryProvider);
      final result = await taskRepo.getTasks(householdId, limit: 200);

      // In direct-completion flow we show only tasks that can be completed now.
      _allTasks = result.getOrElse((_) => []).where((t) => t.isActive).toList();

      final householdRepo = ref.read(householdRepositoryProvider);
      final membersResult = await householdRepo.getHouseholdMembersRaw();
      _members = membersResult.getOrElse((failure) {
        log.e('Error loading members: ${failure.message}');
        return [];
      });
    } catch (e) {
      log.e('Error loading data for task sheet: $e', error: e);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleTask(TaskModel task) {
    final taskId = task.id;
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  Future<void> _submitCompletedTasks() async {
    if (_selectedTaskIds.isEmpty || _selectedMemberIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final selectedTasks =
          _allTasks.where((t) => _selectedTaskIds.contains(t.id)).toList();

      int totalXp = 0;
      int totalCoins = 0;

      for (final id in _selectedTaskIds) {
        final t = selectedTasks.firstWhere((task) => task.id == id);
        totalXp += t.xpReward;
        totalCoins += t.coinReward;
      }

      final currentUserId = ref.read(currentUserIdProvider);
      final onlyMe =
          _selectedMemberIds.length == 1 && _selectedMemberIds.contains(currentUserId);

      for (var task in selectedTasks) {
        await ref
            .read(tasksProvider.notifier)
            .completeTask(task, userIds: _selectedMemberIds.toList());

        if (!_isRightNow) {
          await Supabase.instance.client
              .from('tasks')
              .update({'completed_at': _customDate.toIso8601String()}).eq(
                  'id', task.id);
        }
      }

      if (mounted) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
        Navigator.pop(context); // Pop the sheet first

        final String verb = onlyMe ? "Ganaste" : "Ganaron";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⭐ $verb $totalXp XP y $totalCoins Coins!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );

        widget.onTasksCompleted();
      }
    } catch (e) {
      log.e('Error completing tasks: $e', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Future<void> _selectCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_customDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (timePicked != null) {
        setState(() {
          _customDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
          _isRightNow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch categories
    final categoriesAsync = ref.watch(categoriesProvider);
    final List<CategoryModel> categories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => [],
    );

    // Apply filters
    final filteredTasks = _allTasks.where((task) {
      final taskCatNorm = AppColors.normaliseCategory(task.category);
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(taskCatNorm)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    final tasksToShow = filteredTasks;

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.86,
            child: _buildBody(tasksToShow, categories),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.accentGold,
              AppColors.success,
              AppColors.accentBlue,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(List<TaskModel> tasks, List<CategoryModel> categories) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 22),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.task_alt_rounded,
                              color: AppColors.primary, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Completar tareas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Marcá lo que ya hicieron y asigná el mérito en un solo paso.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(
                      bottom: _selectedTaskIds.isEmpty || _isLoading ? 24 : 12,
                    ),
                    children: [
                      _buildSectionHeader(Icons.people_alt_rounded,
                          '¿Quién lo hizo?', 'Selecciona quiénes ayudaron'),
                      _buildMembersSelection(),
                      const SizedBox(height: 32),
                      _buildSectionHeader(Icons.schedule_rounded, '¿Cuándo?',
                          'Elige el momento de finalización'),
                      _buildDateSelection(),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                          Icons.layers_rounded,
                          'Seleccionar Tareas',
                          'Busca y selecciona lo terminado'),
                      _buildCategoryAndSearch(categories),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: _buildGroupedTasksInFull(tasks, categories),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedTaskIds.isNotEmpty && !_isLoading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.98),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitCompletedTasks,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTaskIds.length == 1
                                    ? 'Completar 1 tarea'
                                    : 'Completar ${_selectedTaskIds.length} tareas',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSelection() {
    return SizedBox(
      height: 116,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          final userId = member['user_id'] as String;
          final nameStr = member['users']?['full_name'] as String? ?? 'Miembro';
          final avatarUrl = member['users']?['avatar_url'] as String?;
          final isSelected = _selectedMemberIds.contains(userId);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isSelected) {
                  _selectedMemberIds.remove(userId);
                } else {
                  _selectedMemberIds.add(userId);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isSelected ? 3.0 : 0.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: CustomUserAvatar(
                      name: nameStr.split(' ').first,
                      avatarUrl: avatarUrl,
                      radius: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nameStr.split(' ')[0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildDateOptionCard(
              title: 'Ahora',
              icon: Icons.bolt_rounded,
              isSelected: _isRightNow,
              onTap: () => setState(() => _isRightNow = true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateOptionCard(
              title: !_isRightNow
                  ? DateFormat('d/M HH:mm').format(_customDate)
                  : 'Antes',
              icon: Icons.calendar_today_rounded,
              isSelected: !_isRightNow,
              onTap: _selectCustomDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEAEFF5),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                size: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAndSearch(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Buscar tarea...',
                hintStyle: TextStyle(
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.8)),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 22, color: Color(0xFF64748B)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: Builder(builder: (context) {
            final activeCats = _allTasks
                .map((t) => AppColors.normaliseCategory(t.category))
                .toSet();
            final visibleCats = categories
                .where((c) =>
                    activeCats.contains(AppColors.normaliseCategory(c.id)))
                .toList();

            return ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildCategoryChip(null, 'Todas', const Color(0xFF64748B)),
                ...visibleCats.map((c) => _buildCategoryChip(
                    c.id, c.name, AppColors.fromHex(c.color))),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String? id, String name, Color color) {
    final normId = id != null ? AppColors.normaliseCategory(id) : null;
    final isSelected = normId == null
        ? _selectedCategories.isEmpty
        : _selectedCategories.contains(normId);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (normId == null) {
            _selectedCategories.clear();
          } else {
            if (_selectedCategories.contains(normId)) {
              _selectedCategories.remove(normId);
            } else {
              _selectedCategories.add(normId);
            }
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected ? Colors.white : color,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedTasksInFull(
      List<TaskModel> tasks, List<CategoryModel> categories) {
    if (tasks.isEmpty) {
      return [
        const Center(
            child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No hay tareas disponibles')))
      ];
    }

    final catLookup = <String, CategoryModel>{};
    for (final c in categories) {
      final norm = AppColors.normaliseCategory(c.id);
      if (!catLookup.containsKey(norm)) catLookup[norm] = c;
    }

    final grouped = <String, List<TaskModel>>{};
    for (final t in tasks) {
      final normCat = AppColors.normaliseCategory(t.category);
      (grouped[normCat] ??= []).add(t);
    }

    final displayCats = grouped.keys.toList();
    displayCats.sort((a, b) {
      final orderA = catLookup[a]?.sortOrder ?? 99;
      final orderB = catLookup[b]?.sortOrder ?? 99;
      return orderA.compareTo(orderB);
    });

    final widgets = <Widget>[];
    for (final normCat in displayCats) {
      final catTasks = grouped[normCat]!;
      final catInfo = catLookup[normCat] ??
          CategoryModel(
              id: normCat,
              name:
                  normCat.substring(0, 1).toUpperCase() + normCat.substring(1),
              icon: '🏠',
              color: '#94A3B8');

      widgets.add(_buildCategoryDivider(
        icon: AppColors.getCategoryMaterialIcon(normCat),
        title: catInfo.name,
        color: AppColors.fromHex(catInfo.color),
      ));

      widgets.addAll(catTasks.map(
          (t) => _buildTaskSelectionItem(t, AppColors.fromHex(catInfo.color))));
    }

    return widgets;
  }

  Widget _buildCategoryDivider(
      {required IconData icon, required String title, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Divider(color: color.withValues(alpha: 0.1), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildTaskSelectionItem(TaskModel task, Color catColor) {
    final isSelected = _selectedTaskIds.contains(task.id);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _toggleTask(task);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (task.xpReward > 0)
              Text(
                '${task.xpReward} XP',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}




import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class CompleteTaskSheet extends StatefulWidget {
  final SupabaseRpcService rpc;
  final VoidCallback onTasksCompleted;

  const CompleteTaskSheet({
    super.key,
    required this.rpc,
    required this.onTasksCompleted,
  });

  @override
  State<CompleteTaskSheet> createState() => _CompleteTaskSheetState();
}

class _CompleteTaskSheetState extends State<CompleteTaskSheet> {
  bool _isLoading = true;
  List<dynamic> _allTasks = [];
  List<Map<String, dynamic>> _members = [];

  // Selections
  List<String> _selectedMemberIds = [];
  bool _isRightNow = true;
  DateTime _customDate = DateTime.now();
  String? _selectedCategory;
  String _searchQuery = '';
  final Set<String> _selectedTaskIds = {};
  final bool _isSearchExpanded = false;

  // Confetti
  late ConfettiController _confettiController;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'id': 'cleaning', 'icon': '🧹'},
    {'id': 'kitchen', 'icon': '🍳'},
    {'id': 'bedroom', 'icon': '🛏️'},
    {'id': 'bathroom', 'icon': '🚿'},
    {'id': 'pets', 'icon': '🐾'},
    {'id': 'outdoor', 'icon': '🌿'},
    {'id': 'general', 'icon': '🏠'},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadData();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      _selectedMemberIds = [currentUser.id];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await widget.rpc.getTasks();
      _allTasks = tasks
          .where((t) => t['status'] == 'active' || t['status'] == 'assigned')
          .toList();

      final members = await widget.rpc.getHouseholdMembers();
      _members = List<Map<String, dynamic>>.from(members);
    } catch (e) {
      debugPrint('Error loading data for TaskModel sheet: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
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

  void _toggleMember(String memberId) {
    setState(() {
      if (_selectedMemberIds.contains(memberId)) {
        if (_selectedMemberIds.length > 1) {
          // Prevents unselecting the last member
          _selectedMemberIds.remove(memberId);
        }
      } else {
        _selectedMemberIds.add(memberId);
      }
    });
  }

  void _toggleTask(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  Future<void> _submitCompletedTasks() async {
    if (_selectedTaskIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final selectedTasks =
          _allTasks.where((t) => _selectedTaskIds.contains(t['id']));

      int totalXp = 0;
      int totalCoins = 0;

      for (var task in selectedTasks) {
        // Complete the TaskModel transaction
        final result = await widget.rpc.completeTaskTransaction(
          taskId: task['id'],
          taskTitle: task['title'],
          xpReward: task['xp_reward'] ?? 0,
          coinReward: task['coin_reward'] ?? 0,
          householdId: task['household_id'],
        );

        // Optionally update the completed_at date to _customDate if NOT right now
        // And conditionally credit all selected members if multi-selection applies
        // NOTE: Our current RPC assigns it to the caller, but we'll use a backend update
        // to adjust dates or shared points if advanced features are needed.

        final data = result['data'] ?? result;
        totalXp += (data['xp_earned'] ?? 0) as int;
        totalCoins += (data['coins_earned'] ?? 0) as int;

        if (!_isRightNow && data['transaction_id'] != null) {
          // Adjust completion date via direct update
          await Supabase.instance.client
              .from('tasks')
              .update({'completed_at': _customDate.toIso8601String()}).eq(
                  'id', task['id']);
        }
      }

      if (mounted) {
        // 🎉 Confetti + haptic!
        _confettiController.play();
        HapticFeedback.heavyImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('¡Ganaron $totalXp XP y $totalCoins coins!'),
              ],
            ),
            backgroundColor: AppColors.accentTeal,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        widget.onTasksCompleted();
      }
    } catch (e) {
      debugPrint('Error completing tasks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _allTasks.where((task) {
      if (_selectedCategory != null && task['category'] != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final title = (task['title'] as String).toLowerCase();
        if (!title.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildBody(filteredTasks),
          // Confetti burst from top-center
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            maxBlastForce: 25,
            minBlastForce: 10,
            emissionFrequency: 0.04,
            colors: const [
              AppColors.primary,
              AppColors.accentGold,
              AppColors.accentTeal,
              AppColors.accentGreen,
              Color(0xFFFF6B9D),
            ],
            gravity: 0.3,
          ),
        ],
      ),
      bottomSheet: _selectedTaskIds.isEmpty || _isLoading
          ? const SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitCompletedTasks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _selectedTaskIds.length == 1
                        ? 'Seleccionar tarea'
                        : 'Seleccionar tareas',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(List<dynamic> filteredTasks) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentGold))
          : Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    children: [
                      _buildSectionHeader(Icons.people_rounded, 'Miembros',
                          'Miembros que hicieron la tarea o ayudaron'),
                      _buildMembersSelection(),
                      const SizedBox(height: 24),

                      _buildSectionHeader(Icons.calendar_today_rounded, 'Fecha',
                          'Cuándo se hizo la tarea (dentro de la semana actual)'),
                      _buildDateSelection(),
                      const SizedBox(height: 24),

                      _buildSectionHeader(Icons.assignment_turned_in_rounded,
                          'Tareas', 'Tareas que se completaron'),
                      _buildCategoryAndSearch(),

                      const SizedBox(height: 16),
                      if (filteredTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                              child: Text('No hay tareas para esta selección.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary))),
                        )
                      else
                        ...filteredTasks.map((t) => _buildTaskItem(t)).toList(),

                      const SizedBox(height: 100), // padding for bottom button
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13, 
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSelection() {
    return SizedBox(
      height: 105, // Increased height for breathing room and preventing overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          final userId = member['user_id'];
          final nameStr = member['users']?['full_name'] as String? ?? 'Miembro';
          final avatarUrl = member['users']?['avatar_url'] as String?;
          final isSelected = _selectedMemberIds.contains(userId);

          return GestureDetector(
            onTap: () => _toggleMember(userId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: isSelected ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        ) : null,
                        child: CustomUserAvatar(
                          name: nameStr.isNotEmpty ? nameStr.split(' ').first : '...',
                          avatarUrl: avatarUrl,
                          radius: 28,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                            ),
                            child: const Icon(Icons.check,
                                size: 14, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nameStr.split(' ')[0],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
            child: GestureDetector(
              onTap: () => setState(() => _isRightNow = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _isRightNow ? AppColors.accentGold : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _isRightNow
                          ? AppColors.accentGold
                          : Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Ahora mismo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _isRightNow ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _selectCustomDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !_isRightNow ? AppColors.accentGold : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: !_isRightNow
                          ? AppColors.accentGold
                          : Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  !_isRightNow
                      ? DateFormat('d MMM HH:mm').format(_customDate)
                      : 'Antes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color:
                        !_isRightNow ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Buscar tarea...',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              prefixIcon:
                  Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...categories.map(
                          (c) => _buildCategoryCircle(c['id'], c['icon']!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5), width: 1),
                ),
                child: Icon(Icons.sort_rounded,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCircle(String? id, String iconOrLabel) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () => setState(() {
        if (_selectedCategory == id) {
          _selectedCategory = null; // deselect
        } else {
          _selectedCategory = id;
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.accentGold : Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          iconOrLabel,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildTaskItem(dynamic task) {
    final bool isSelected = _selectedTaskIds.contains(task['id']);
    final int xp = task['xp_reward'] ?? 0;

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          onTap: () => _toggleTask(task['id']),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accentGold : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                width: isSelected ? 8 : 2,
              ),
              color: isSelected ? AppColors.accentGold : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          title: Text(
            task['title'] ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color:
                  isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+ $xp',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.accentGold,
              ),
            ),
          ),
        ),
        Divider(
            height: 1,
            indent: 72,
            endIndent: 24,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      ],
    );
  }
}

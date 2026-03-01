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

  // Categories are derived dynamically from tasks once loaded
  // (no hardcoded list — they match the actual DB values)

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
    // Build visibleCategories from actual TaskModel data, deduplicated by canonical name
    final Map<String, int> catCount = {};
    for (var t in _allTasks) {
      final rawCat = t['category']?.toString() ?? 'general';
      final normCat = AppColors.normaliseCategory(rawCat); // unify living_room, sala, etc.
      catCount[normCat] = (catCount[normCat] ?? 0) + 1;
    }
    // Sort by count descending so most-used appear first
    final visibleCategories = catCount.keys.toList()
      ..sort((a, b) => catCount[b]!.compareTo(catCount[a]!));

    // Apply filters
    final filteredTasks = _allTasks.where((task) {
      final taskCat = AppColors.normaliseCategory(task['category']?.toString());
      if (_selectedCategory != null && taskCat != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final title = (task['title'] as String? ?? '').toLowerCase();
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
          _buildBody(filteredTasks, visibleCategories),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitCompletedTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(
                      _selectedTaskIds.length == 1
                          ? 'Completar 1 tarea'
                          : 'Completar ${_selectedTaskIds.length} tareas',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(List<dynamic> filteredTasks, List<String> visibleCategories) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, -5),
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
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Completar Tarea',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 140),
                    children: [
                      _buildSectionHeader(Icons.people_alt_rounded, '¿Quién lo hizo?', 'Selecciona quienes ayudaron'),
                      _buildMembersSelection(),
                      const SizedBox(height: 32),

                      _buildSectionHeader(Icons.schedule_rounded, '¿Cuándo?', 'Elige el momento de finalización'),
                      _buildDateSelection(),
                      const SizedBox(height: 32),

                      _buildSectionHeader(Icons.fact_check_rounded, '¿Qué tareas?', 'Busca las tareas completadas'),
                      _buildCategoryAndSearch(visibleCategories),
                      const SizedBox(height: 24),

                      if (filteredTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                  Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
                                  SizedBox(height: 12),
                                  Text(
                                    'No encontramos tareas as\u00ED.',
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                              ],
                            )
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: filteredTasks.map((t) => _buildTaskItem(t)).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
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
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
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
      height: 125,
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
            onTap: () {
              HapticFeedback.selectionClick();
              _toggleMember(userId);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(isSelected ? 4.0 : 0.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ] : [],
                        ),
                        child: CustomUserAvatar(
                          name: nameStr.split(' ').first,
                          avatarUrl: avatarUrl,
                          radius: 30,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.check, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nameStr.split(' ')[0],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      letterSpacing: -0.2,
                      color: isSelected ? AppColors.primary : const Color(0xFF64748B),
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
               title: 'Ahora Mismo',
               icon: Icons.flash_on_rounded,
               isSelected: _isRightNow,
               onTap: () => setState(() => _isRightNow = true),
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: _buildDateOptionCard(
               title: !_isRightNow ? DateFormat('d MMM HH:mm').format(_customDate) : 'Otro Momento',
               icon: Icons.calendar_month_rounded,
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
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 2.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : const Color(0xFF94A3B8), 
              size: 26,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: -0.4,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAndSearch(List<String> visibleCategories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Buscar tarea...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          if (visibleCategories.isNotEmpty) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: visibleCategories.map((c) => _buildCategoryCircle(c)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryCircle(String id) {
    final isSelected = _selectedCategory == id;
    final color = AppColors.getCategoryColor(id);
    final icon = AppColors.getCategoryMaterialIcon(id);

    return GestureDetector(
      onTap: () => setState(() {
        if (_selectedCategory == id) {
          _selectedCategory = null;
        } else {
          _selectedCategory = id;
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isSelected ? color : const Color(0xFF94A3B8),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildTaskItem(dynamic task) {
    final bool isSelected = _selectedTaskIds.contains(task['id']);
    final int xp = task['xp_reward'] ?? 0;
    final int coins = task['coin_reward'] ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _toggleTask(task['id']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ] : [],
              ),
              child: isSelected 
                  ? const Icon(Icons.check_rounded, size: 20, color: Colors.white) 
                  : null,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'] ?? '',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected ? AppColors.primary : const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (coins > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, size: 14, color: AppColors.accentGold),
                        const SizedBox(width: 4),
                        Text(
                          '$coins coins',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+$xp XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.accentTeal,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

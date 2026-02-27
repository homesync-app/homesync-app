import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'user_avatar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TaskDetailSheet — Opens from activity history tap
// • Task author → can UNDO the completion (resets to pending)
// • Partner → can add an OBJECTION comment
// No banners, no forced dialogs.
// ─────────────────────────────────────────────────────────────────────────────

class TaskDetailSheet extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final VoidCallback? onChanged;

  const TaskDetailSheet({super.key, required this.taskData, this.onChanged});

  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> taskData, {
    VoidCallback? onChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(taskData: taskData, onChanged: onChanged),
    );
  }

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  bool _isLoading = false;
  bool _showObjectionInput = false;
  final _objectionCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _objectionCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _taskId => widget.taskData['id'] as String? ?? '';
  String get _status => widget.taskData['status'] as String? ?? 'pending_verification';
  String get _title => widget.taskData['title'] as String? ?? '';
  String get _category => widget.taskData['category'] as String? ?? 'general';
  int get _xpReward => (widget.taskData['xp_reward'] as num?)?.toInt() ?? 0;
  int get _coinReward => (widget.taskData['coin_reward'] as num?)?.toInt() ?? 0;
  String? get _objectionReason => widget.taskData['objection_reason'] as String?;

  Map? get _completedUser => widget.taskData['completed_user'] as Map?;
  String get _completedByName =>
      (_completedUser?['full_name'] as String?) ?? 'Alguien';
  String? get _completedByAvatar => _completedUser?['avatar_url'] as String?;
  String? get _completedById => _completedUser?['id'] as String?;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';
  bool get _isAuthor => _completedById == _currentUserId;

  String? get _objectedById => widget.taskData['objected_by'] as String?;
  bool get _iObjected => _objectedById == _currentUserId;

  // ── Label helpers (friendly language) ──────────────────────────────────────

  (String label, Color color, String emoji) get _statusInfo {
    return switch (_status) {
      'pending_verification' || 'verified' => ('Completada', AppColors.accentTeal, '✅'),
      'objected' => ('En disputa', AppColors.accentRed, '⚠️'),
      _ => ('Pendiente', AppColors.textMuted, '📋'),
    };
  }


  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _undoTask() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('tasks').update({
        'status': 'pending',
        'completed_by': null,
        'completed_at': null,
        'objection_reason': null,
        'objected_by': null,
        'objected_at': null,
      }).eq('id', _taskId);

      widget.onChanged?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('No se pudo deshacer: $e', AppColors.error);
      }
    }
  }

  Future<void> _submitObjection() async {
    final reason = _objectionCtrl.text.trim();
    if (reason.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('tasks').update({
        'status': 'objected',
        'objection_reason': reason,
        'objected_by': _currentUserId,
        'objected_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', _taskId);

      widget.onChanged?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('No se pudo enviar: $e', AppColors.error);
      }
    }
  }

  Future<void> _undoObjection() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('tasks').update({
        'status': 'verified',
        'objection_reason': null,
        'objected_by': null,
        'objected_at': null,
      }).eq('id', _taskId);

      widget.onChanged?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('No se pudo quitar la objeción: $e', AppColors.error);
      }
    }
  }


  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, statusEmoji) = _statusInfo;
    final completedAt = widget.taskData['completed_at'];
    final dateStr = completedAt != null
        ? DateFormat('d MMM · HH:mm', 'es')
            .format(DateTime.parse(completedAt as String).toLocal())
        : null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 60),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // ── Header: icon + title ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.getCategoryColor(_category)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          AppColors.categoryIcons[_category] ?? '📋',
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$statusEmoji  $statusLabel',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Info row ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Who completed it
                      Expanded(
                        child: Column(
                          children: [
                            CustomUserAvatar(
                                name: _completedByName,
                                avatarUrl: _completedByAvatar,
                                radius: 20),
                            const SizedBox(height: 8),
                            Text(
                              _completedByName.split(' ').first,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              'Completó la tarea',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                          width: 1,
                          height: 60,
                          color: Theme.of(context).dividerColor),
                      // XP reward
                      Expanded(
                        child: Column(
                          children: [
                            const Text('⭐',
                                style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text('+$_xpReward XP',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.accentTeal)),
                            if (_coinReward > 0)
                              Text('+$_coinReward 🪙',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                          width: 1,
                          height: 60,
                          color: Theme.of(context).dividerColor),
                      // When
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 28,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(height: 4),
                            Text(
                              dateStr ?? '—',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Objection reason (if exists) ───────────────────────────
              if (_objectionReason != null && _objectionReason!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('💬', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          const Text(
                            'Comentario',
                            style: TextStyle(
                              color: AppColors.accentRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          _objectionReason!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Objection input ────────────────────────────────────────
              if (_showObjectionInput)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué querés comentar?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _objectionCtrl,
                        focusNode: _focusNode,
                        maxLines: 3,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText:
                              'Ej: Faltó limpiar debajo del mueble...',
                          hintStyle:
                              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitObjection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentRed,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Text('Enviar comentario',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Action buttons ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: _buildActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // The author can undo their own completed task
    if (_isAuthor &&
        (_status == 'pending_verification' || _status == 'verified')) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _undoTask,
          icon: const Icon(Icons.undo_rounded, size: 18),
          label: const Text('Deshacer',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            side: BorderSide(
                color: Theme.of(context).dividerColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    // If it's already objected, and I AM the one who objected, I can undo it
    if (_status == 'objected' && _iObjected) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _undoObjection,
          icon: const Icon(Icons.undo_rounded, size: 18),
          label: const Text('Quitar comentario',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentTeal,
            side: const BorderSide(color: AppColors.accentTeal, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    // The partner can comment/object on pending/verified tasks (not already objected)
    if (!_isAuthor && _status != 'objected') {
      if (!_showObjectionInput) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() => _showObjectionInput = true);
              Future.delayed(const Duration(milliseconds: 100),
                  () => _focusNode.requestFocus());
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Objetar / Comentar',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side:
                  const BorderSide(color: AppColors.accentRed, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        );
      }
    }


    // Already objected or no actions available
    return const SizedBox.shrink();
  }
}

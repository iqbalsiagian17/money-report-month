import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/routes.dart';
import '../../../models/todo.dart';
import '../../../providers/todo_provider.dart';

class TodoStatusCard extends StatelessWidget {
  const TodoStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        final pendingTodos = provider.pendingTodos;
        final totalCount = provider.totalCount;
        final completedCount = provider.completedCount;

        // Jika tidak ada pending = jangan tampilkan apa-apa
        if (pendingTodos.isEmpty) {
          return const SizedBox.shrink();
        }

        return _ActiveTodoCard(
          isDark: Theme.of(context).brightness == Brightness.dark,
          pendingTodos: pendingTodos,
          completedCount: completedCount,
          totalCount: totalCount,
          provider: provider,
        );
      },
    );
  }
}

// ==================== EMPTY STATE ====================
class _EmptyTodoCard extends StatelessWidget {
  final bool isDark;

  const _EmptyTodoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.grey[800]!
              : const Color(0xFF1A1A2E).withOpacity(0.06),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF1A1A2E).withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Color(0xFFE91E63),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada tugas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Buat tugas untuk mengatur aktivitasmu',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'Buat Tugas',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRoutes.todo);
            },
          ),
        ],
      ),
    );
  }
}

// ==================== ALL COMPLETED STATE ====================
class _AllCompletedCard extends StatelessWidget {
  final bool isDark;
  final int completedCount;

  const _AllCompletedCard({
    required this.isDark,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semua Selesai!  🎉',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completedCount tugas telah diselesaikan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'Lihat Semua',
            backgroundColor: const Color(0xFF4CAF50),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRoutes.todo);
            },
          ),
        ],
      ),
    );
  }
}

// ==================== ACTIVE TODO CARD ====================
class _ActiveTodoCard extends StatelessWidget {
  final bool isDark;
  final List<Todo> pendingTodos;
  final int completedCount;
  final int totalCount;
  final TodoProvider provider;

  const _ActiveTodoCard({
    required this.isDark,
    required this.pendingTodos,
    required this.completedCount,
    required this.totalCount,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil maksimal 3 todo untuk ditampilkan
    final displayTodos = pendingTodos.take(3).toList();
    final remainingCount = pendingTodos.length - displayTodos.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.grey[800]!
              : const Color(0xFF1A1A2E).withOpacity(0.06),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF1A1A2E).withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Color(0xFFE91E63),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To-Do List',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pendingTodos.length} tugas belum selesai',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Progress indicator
              _MiniProgressRing(
                progress: progress,
                completedCount: completedCount,
                totalCount: totalCount,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE91E63),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Todo items
          ...displayTodos.asMap().entries.map((entry) {
            return _MiniTodoItem(
              todo: entry.value,
              isDark: isDark,
              onToggle: () {
                HapticFeedback.lightImpact();
                provider.toggleTodo(entry.value);
              },
            );
          }),

          // Show more indicator
          if (remainingCount > 0) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, AppRoutes.todo);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+$remainingCount tugas lainnya',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFFE91E63),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action button
          _ActionButton(
            label: 'Lihat Semua',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRoutes.todo);
            },
          ),
        ],
      ),
    );
  }
}

// ==================== MINI PROGRESS RING ====================
class _MiniProgressRing extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final bool isDark;

  const _MiniProgressRing({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.5,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE91E63),
            ),
          ),
          Text(
            '$completedCount/$totalCount',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MINI TODO ITEM ====================
class _MiniTodoItem extends StatefulWidget {
  final Todo todo;
  final bool isDark;
  final VoidCallback onToggle;

  const _MiniTodoItem({
    required this.todo,
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<_MiniTodoItem> createState() => _MiniTodoItemState();
}

class _MiniTodoItemState extends State<_MiniTodoItem> {
  bool _isPressed = false;

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == tomorrow) {
      return 'Besok';
    } else if (dateOnly.isBefore(today)) {
      return 'Terlambat';
    } else {
      return DateFormat('dd MMM', 'id').format(date);
    }
  }

  Color _getDueDateColor(DateTime? date) {
    if (date == null) return Colors.grey;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isBefore(today)) {
      return Colors.red;
    } else if (dateOnly == today) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDueDate = widget.todo.dueDate != null;
    final hasReminder = widget.todo.hasReminder;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onToggle();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.grey[850] : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isDark
                ? Colors.grey[700]!
                : Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            _MiniCheckbox(onTap: widget.onToggle),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.todo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  if (hasDueDate || hasReminder) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (hasDueDate) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: _getDueDateColor(widget.todo.dueDate),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(widget.todo.dueDate),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getDueDateColor(widget.todo.dueDate),
                            ),
                          ),
                        ],
                        if (hasDueDate && hasReminder) const SizedBox(width: 8),
                        if (hasReminder)
                          Icon(
                            Icons.notifications_active_rounded,
                            size: 12,
                            color: const Color(0xFFE91E63),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MINI CHECKBOX ====================
class _MiniCheckbox extends StatefulWidget {
  final VoidCallback onTap;

  const _MiniCheckbox({required this.onTap});

  @override
  State<_MiniCheckbox> createState() => _MiniCheckboxState();
}

class _MiniCheckboxState extends State<_MiniCheckbox> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.85 : 1.0),
        transformAlignment: Alignment.center,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ==================== ACTION BUTTON ====================
class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? const Color(0xFFE91E63);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_rounded,
              size: 18,
              color: bgColor,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: bgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

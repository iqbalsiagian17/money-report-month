import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_report_monthly/models/todo.dart';
import 'package:money_report_monthly/providers/todo_provider.dart';
import 'package:money_report_monthly/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:provider/provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showAddTodoSheet(BuildContext context, TodoProvider provider) {
    final textController = TextEditingController();
    DateTime? selectedDate;
    DateTime? selectedReminder;

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Tambah To-Do',
      subtitle: 'Buat tugas baru untuk diingat',
      submitText: 'Tambah',
      builder: (context, setState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          children: [
            // Title field
            TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                labelText: 'Judul tugas',
                hintText: 'Contoh: Bayar tagihan listrik',
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : const Color(0xFF1A1A2E),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Due date picker
            _DatePickerTile(
              icon: Icons.calendar_today_rounded,
              label: 'Tanggal jatuh tempo',
              value: selectedDate,
              isDark: isDark,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                    // Reset reminder if due date changes
                    if (selectedReminder != null &&
                        selectedReminder!
                            .isAfter(date.add(const Duration(days: 1)))) {
                      selectedReminder = null;
                    }
                  });
                }
              },
              onClear: () {
                setState(() {
                  selectedDate = null;
                  selectedReminder = null;
                });
              },
            ),

            const SizedBox(height: 12),

            // Reminder picker
            _ReminderPickerTile(
              selectedReminder: selectedReminder,
              selectedDate: selectedDate,
              isDark: isDark,
              onTap: () async {
                final result = await _showReminderPicker(
                  context,
                  initialDateTime: selectedReminder,
                  dueDate: selectedDate,
                );
                if (result != null) {
                  setState(() {
                    selectedReminder = result;
                  });
                }
              },
              onClear: () {
                setState(() {
                  selectedReminder = null;
                });
              },
            ),
          ],
        );
      },
      onSubmit: () async {
        if (textController.text.trim().isEmpty) {
          _showError(context, 'Judul tidak boleh kosong');
          return null;
        }

        await provider.addTodo(
          textController.text.trim(),
          dueDate: selectedDate,
          reminderTime: selectedReminder,
        );
        HapticFeedback.lightImpact();
        return true;
      },
    );
  }

  void _showEditTodoSheet(
      BuildContext context, TodoProvider provider, Todo todo) {
    final textController = TextEditingController(text: todo.title);
    DateTime? selectedDate = todo.dueDate;
    DateTime? selectedReminder = todo.reminderTime;
    bool clearReminder = false;

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Edit To-Do',
      subtitle: 'Ubah detail tugas',
      submitText: 'Simpan',
      builder: (context, setState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          children: [
            // Title field
            TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                labelText: 'Judul tugas',
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : const Color(0xFF1A1A2E),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Due date picker
            _DatePickerTile(
              icon: Icons.calendar_today_rounded,
              label: 'Tanggal jatuh tempo',
              value: selectedDate,
              isDark: isDark,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
              onClear: () {
                setState(() {
                  selectedDate = null;
                });
              },
            ),

            const SizedBox(height: 12),

            // Reminder picker
            _ReminderPickerTile(
              selectedReminder: selectedReminder,
              selectedDate: selectedDate,
              isDark: isDark,
              onTap: () async {
                final result = await _showReminderPicker(
                  context,
                  initialDateTime: selectedReminder,
                  dueDate: selectedDate,
                );
                if (result != null) {
                  setState(() {
                    selectedReminder = result;
                    clearReminder = false;
                  });
                }
              },
              onClear: () {
                setState(() {
                  selectedReminder = null;
                  clearReminder = true;
                });
              },
            ),
          ],
        );
      },
      onSubmit: () async {
        if (textController.text.trim().isEmpty) {
          _showError(context, 'Judul tidak boleh kosong');
          return null;
        }

        await provider.updateTodo(
          todo,
          title: textController.text.trim(),
          dueDate: selectedDate,
          reminderTime: selectedReminder,
          clearReminder: clearReminder,
        );
        HapticFeedback.lightImpact();
        return true;
      },
    );
  }

  Future<DateTime?> _showReminderPicker(
    BuildContext context, {
    DateTime? initialDateTime,
    DateTime? dueDate,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Quick options
    final now = DateTime.now();
    final options = <Map<String, dynamic>>[
      {
        'label': '15 menit lagi',
        'time': now.add(const Duration(minutes: 15)),
      },
      {
        'label': '30 menit lagi',
        'time': now.add(const Duration(minutes: 30)),
      },
      {
        'label': '1 jam lagi',
        'time': now.add(const Duration(hours: 1)),
      },
      {
        'label': 'Besok pagi (08:00)',
        'time': DateTime(now.year, now.month, now.day + 1, 8, 0),
      },
    ];

    // Add due date option if available
    if (dueDate != null) {
      final dueDateMorning =
          DateTime(dueDate.year, dueDate.month, dueDate.day, 8, 0);
      if (dueDateMorning.isAfter(now)) {
        options.insert(0, {
          'label': 'Hari H pagi (08:00)',
          'time': dueDateMorning,
        });
      }
    }

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // ⬅️ WAJIB biar gak overflow
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Atur Pengingat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Pilih waktu untuk diingatkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick options
                  ...options.map((option) {
                    final time = option['time'] as DateTime;
                    final isValid = time.isAfter(now);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: _QuickReminderOption(
                        label: option['label'] as String,
                        time: time,
                        isEnabled: isValid,
                        isDark: isDark,
                        onTap:
                            isValid ? () => Navigator.pop(context, time) : null,
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CustomTimeButton(
                      isDark: isDark,
                      onTap: () async {
                        Navigator.pop(context);

                        final date = await showDatePicker(
                          context: context,
                          initialDate: initialDateTime ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );

                        if (date != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              initialDateTime ?? DateTime.now(),
                            ),
                          );

                          if (time != null) {
                            final selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );

                            if (selectedDateTime.isAfter(DateTime.now()) &&
                                context.mounted) {
                              Navigator.pop(context, selectedDateTime);
                            }
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, TodoProvider provider, Todo todo) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Tugas? ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          content: Text(
            'Tugas "${todo.title}" akan dihapus permanen.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTodo(todo);
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCompletedDialog(BuildContext context, TodoProvider provider) {
    HapticFeedback.mediumImpact();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Semua Selesai?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          content: Text(
            'Semua tugas yang sudah selesai akan dihapus permanen.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.clearCompleted();
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<TodoProvider>();

    final pendingTodos = provider.pendingTodos;
    final completedTodos = provider.completedTodos;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -20 * (1 - _headerAnimation.value)),
                    child: Opacity(
                      opacity: _headerAnimation.value.clamp(0.0, 1.0),
                      child: _buildHeader(context, isDark, provider),
                    ),
                  );
                },
              ),

              // Content
              Expanded(
                child: AnimatedBuilder(
                  animation: _contentAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _contentAnimation.value.clamp(0.0, 1.0),
                      child: provider.todos.isEmpty
                          ? _buildEmptyState(context, isDark, provider)
                          : _buildTodoList(
                              context,
                              isDark,
                              provider,
                              pendingTodos,
                              completedTodos,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _contentAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _contentAnimation.value.clamp(0.0, 1.0),
              child: _buildFAB(context, provider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, TodoProvider provider) {
    final completedCount = provider.completedCount;
    final totalCount = provider.totalCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          _BackButton(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            isDark: isDark,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To-Do List',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                if (totalCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount dari $totalCount selesai',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (totalCount > 0)
            _buildProgressRing(completedCount, totalCount, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressRing(int completed, int total, bool isDark) {
    final progress = total > 0 ? completed / total : 0.0;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE91E63),
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, TodoProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFFE91E63).withOpacity(0.15)
                    : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 48,
                color: Color(0xFFE91E63),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada tugas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan tugas baru untuk\nmemulai produktivitasmu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _AddTodoButton(
              onTap: () => _showAddTodoSheet(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList(
    BuildContext context,
    bool isDark,
    TodoProvider provider,
    List<Todo> pendingTodos,
    List<Todo> completedTodos,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        // Pending todos
        if (pendingTodos.isNotEmpty) ...[
          _buildSectionHeader('Belum selesai', pendingTodos.length, isDark),
          const SizedBox(height: 12),
          ...pendingTodos.asMap().entries.map((entry) {
            return _TodoItem(
              todo: entry.value,
              index: entry.key,
              isDark: isDark,
              onToggle: () {
                HapticFeedback.lightImpact();
                provider.toggleTodo(entry.value);
              },
              onEdit: () => _showEditTodoSheet(context, provider, entry.value),
              onDelete: () =>
                  _showDeleteConfirmation(context, provider, entry.value),
            );
          }),
        ],

        // Completed todos
        if (completedTodos.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('Selesai', completedTodos.length, isDark),
              if (completedTodos.length > 1)
                GestureDetector(
                  onTap: () => _showClearCompletedDialog(context, provider),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Hapus semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...completedTodos.asMap().entries.map((entry) {
            return _TodoItem(
              todo: entry.value,
              index: entry.key,
              isDark: isDark,
              onToggle: () {
                HapticFeedback.lightImpact();
                provider.toggleTodo(entry.value);
              },
              onEdit: () => _showEditTodoSheet(context, provider, entry.value),
              onDelete: () =>
                  _showDeleteConfirmation(context, provider, entry.value),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isDark) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context, TodoProvider provider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAddTodoSheet(context, provider);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63),
              Color(0xFFD81B60),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E63).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _DatePickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? value;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DatePickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null
                    ? DateFormat('dd MMMM yyyy', 'id').format(value!)
                    : '$label (opsional)',
                style: TextStyle(
                  fontSize: 15,
                  color: value != null
                      ? (isDark ? Colors.white : const Color(0xFF1A1A2E))
                      : Colors.grey[500],
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    color: Colors.grey[400], size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReminderPickerTile extends StatelessWidget {
  final DateTime? selectedReminder;
  final DateTime? selectedDate;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _ReminderPickerTile({
    required this.selectedReminder,
    required this.selectedDate,
    required this.isDark,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasReminder = selectedReminder != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasReminder
              ? const Color(0xFFE91E63).withOpacity(isDark ? 0.15 : 0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: hasReminder
              ? Border.all(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              hasReminder
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: hasReminder ? const Color(0xFFE91E63) : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasReminder
                        ? 'Pengingat aktif'
                        : 'Tambah pengingat (opsional)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          hasReminder ? FontWeight.w600 : FontWeight.normal,
                      color: hasReminder
                          ? const Color(0xFFE91E63)
                          : Colors.grey[500],
                    ),
                  ),
                  if (hasReminder) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm', 'id')
                          .format(selectedReminder!),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasReminder)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    color: Colors.grey[400], size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickReminderOption extends StatelessWidget {
  final String label;
  final DateTime time;
  final bool isEnabled;
  final bool isDark;
  final VoidCallback? onTap;

  const _QuickReminderOption({
    required this.label,
    required this.time,
    required this.isEnabled,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isDark ? Colors.grey[850] : Colors.grey[100])
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 18,
              color: isEnabled ? const Color(0xFFE91E63) : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isEnabled
                      ? (isDark ? Colors.white : const Color(0xFF1A1A2E))
                      : Colors.grey[400],
                ),
              ),
            ),
            Text(
              DateFormat('HH:mm').format(time),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTimeButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _CustomTimeButton({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_calendar_rounded,
              size: 18,
              color: Color(0xFFE91E63),
            ),
            SizedBox(width: 8),
            Text(
              'Pilih waktu custom',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MAIN WIDGETS ====================

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _BackButton({
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
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
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDark
                ? Colors.grey[700]!
                : const Color(0xFF1A1A2E).withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: widget.isDark
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF1A1A2E).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: widget.isDark
              ? Colors.white
              : const Color(0xFF1A1A2E).withOpacity(0.7),
          size: 20,
        ),
      ),
    );
  }
}

class _AddTodoButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddTodoButton({required this.onTap});

  @override
  State<_AddTodoButton> createState() => _AddTodoButtonState();
}

class _AddTodoButtonState extends State<_AddTodoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63),
              Color(0xFFD81B60),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E63).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Tambah Tugas',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoItem extends StatefulWidget {
  final Todo todo;
  final int index;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TodoItem({
    required this.todo,
    required this.index,
    required this.isDark,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<_TodoItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  String _formatReminderTime(DateTime? time) {
    if (time == null) return '';
    return DateFormat('dd MMM, HH:mm', 'id').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todo.isCompleted;
    final hasDueDate = widget.todo.dueDate != null;
    final hasReminder =
        widget.todo.hasReminder && widget.todo.reminderTime != null;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - _animation.value), 0),
          child: Opacity(
            opacity: _animation.value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onToggle,
              onLongPress: widget.onEdit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
                transformAlignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? (isCompleted
                          ? Colors.grey[900]
                          : const Color(0xFF1E1E1E))
                      : (isCompleted ? Colors.grey[50] : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.grey[800]!
                        : (isCompleted
                            ? Colors.grey[200]!
                            : const Color(0xFF1A1A2E).withOpacity(0.08)),
                    width: 1,
                  ),
                  boxShadow: widget.isDark || isCompleted
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF1A1A2E).withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _CustomCheckbox(
                        isChecked: isCompleted,
                        onTap: widget.onToggle,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.todo.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isCompleted
                                  ? Colors.grey[400]
                                  : (widget.isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E)),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: Colors.grey[400],
                            ),
                          ),

                          // Due date & Reminder badges
                          if ((hasDueDate || hasReminder) && !isCompleted) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                // Due date badge
                                if (hasDueDate)
                                  _InfoBadge(
                                    icon: Icons.calendar_today_rounded,
                                    label: _formatDueDate(widget.todo.dueDate),
                                    color:
                                        _getDueDateColor(widget.todo.dueDate),
                                    isDark: widget.isDark,
                                  ),

                                // Reminder badge
                                if (hasReminder)
                                  _InfoBadge(
                                    icon: Icons.notifications_active_rounded,
                                    label: _formatReminderTime(
                                        widget.todo.reminderTime),
                                    color: const Color(0xFFE91E63),
                                    isDark: widget.isDark,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Delete button
                    _DeleteButton(
                      onTap: widget.onDelete,
                      isDark: widget.isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCheckbox extends StatefulWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const _CustomCheckbox({
    required this.isChecked,
    required this.onTap,
  });

  @override
  State<_CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<_CustomCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward().then((_) => _controller.reverse());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: widget.isChecked
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isChecked
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: widget.isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _DeleteButton({
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.red.withOpacity(0.15)
              : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red[400],
          size: 18,
        ),
      ),
    );
  }
}

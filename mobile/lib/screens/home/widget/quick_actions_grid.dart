import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/quick_action_provider.dart';
import '../../../models/quick_action_item.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<QuickActionProvider>(
      builder: (context, provider, _) {
        final actions = provider.activeActions;

        if (actions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? null
                : Border.all(
                    color: const Color(0xFF1A1A2E).withOpacity(0.06),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan tombol edit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Akses Cepat',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditSheet(context, provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grid items
              _buildGrid(actions, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<QuickActionItem> actions, bool isDark) {
    // Calculate rows
    final rows = (actions.length / 4).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * 4;
        final endIndex = (startIndex + 4).clamp(0, actions.length);
        final rowItems = actions.sublist(startIndex, endIndex);

        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 16 : 0),
          child: Row(
            children: [
              ...rowItems.map((action) => Expanded(
                    child: _QuickActionItem(action: action, isDark: isDark),
                  )),
              // Fill remaining slots with empty space
              ...List.generate(
                4 - rowItems.length,
                (_) => const Expanded(child: SizedBox()),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showEditSheet(BuildContext context, QuickActionProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditQuickActionsSheet(provider: provider),
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  final QuickActionItem action;
  final bool isDark;

  const _QuickActionItem({
    required this.action,
    required this.isDark,
  });

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  bool _isPressed = false;

  Color get _bgColor {
    final color = widget.action.color;
    return widget.isDark
        ? color.withOpacity(0.15)
        : Color.lerp(color, Colors.white, 0.85)!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, widget.action.route);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: widget.action.color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                widget.action.icon,
                color: widget.action.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: widget.isDark
                    ? Colors.grey[300]
                    : const Color(0xFF1A1A2E).withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EDIT SHEET
// ============================================
class _EditQuickActionsSheet extends StatelessWidget {
  final QuickActionProvider provider;

  const _EditQuickActionsSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Akses Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showResetConfirm(context),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          // ✅ Gunakan Consumer untuk reactive updates
          Flexible(
            child: Consumer<QuickActionProvider>(
              builder: (context, provider, _) {
                final actions = provider.availableActions;

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: actions.length,
                  itemBuilder: (context, index) {
                    final action = actions[index];

                    return _EditActionItem(
                      key: ValueKey(action.id),
                      action: action,
                      isActive: action.isVisible,
                      isDark: isDark,
                      onToggle: () => provider.toggleVisibility(action.id),
                    );
                  },
                );
              },
            ),
          ),

          // Close button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Selesai'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset ke Default?'),
        content: const Text(
          'Semua pengaturan akses cepat akan dikembalikan ke default.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetToDefault();
              Navigator.pop(context);
              Navigator.pop(context); // Close edit sheet juga
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _EditActionItem extends StatelessWidget {
  final QuickActionItem action;
  final bool isActive;
  final bool isDark;
  final VoidCallback onToggle;

  const _EditActionItem({
    super.key,
    required this.action,
    required this.isActive,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: action.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(action.icon, color: action.color, size: 22),
        ),
        title: Text(
          action.label.replaceAll('\n', ' '),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: Switch(
          value: isActive,
          onChanged: (_) => onToggle(),
          activeColor: Theme.of(context).primaryColor,
        ),
        onTap: onToggle,
      ),
    );
  }
}

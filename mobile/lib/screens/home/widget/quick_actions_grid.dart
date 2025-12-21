import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/routes.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Dompet',
        route: AppRoutes.wallets,
        bgColor: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF2196F3),
      ),
      _QuickAction(
        icon: Icons.savings_rounded,
        label: 'Tabungan',
        route: AppRoutes.savings,
        bgColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF4CAF50),
      ),
      _QuickAction(
        icon: Icons.checklist_rounded,
        label: 'To-Do',
        route: AppRoutes.todo,
        bgColor: const Color(0xFFFCE4EC),
        iconColor: const Color(0xFFE91E63),
      ),
      _QuickAction(
        icon: Icons.repeat_rounded,
        label: 'Rutin',
        route: AppRoutes.recurring,
        bgColor: const Color(0xFFF3E5F5),
        iconColor: const Color(0xFF9C27B0),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return _QuickActionItem(action: action, isDark: isDark);
        }).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final Color bgColor;
  final Color iconColor;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.bgColor,
    required this.iconColor,
  });
}

class _QuickActionItem extends StatefulWidget {
  final _QuickAction action;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? widget.action.iconColor.withOpacity(0.15)
                    : widget.action.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.action.icon,
                color: widget.action.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.action.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? Colors.grey[300]
                    : const Color(0xFF1A1A2E).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        color: const Color(0xFF2196F3),
      ),
      _QuickAction(
        icon: Icons.savings_rounded,
        label: 'Tabungan',
        route: AppRoutes.savings,
        color: const Color(0xFF4CAF50),
      ),
      _QuickAction(
        icon: Icons.speed_rounded,
        label: 'Limit',
        route: AppRoutes.limitSettings,
        color: const Color(0xFFFF9800),
      ),
      _QuickAction(
        icon: Icons.repeat_rounded,
        label: 'Rutin',
        route: AppRoutes.recurring,
        color: const Color(0xFF9C27B0),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
  final Color color;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
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
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color:
                    widget.action.color.withOpacity(widget.isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.action.icon,
                color: widget.action.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.action.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

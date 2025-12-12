import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============ BANKING STYLE BOTTOM NAV (Like Jago, Blu, Jenius) ============
class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onFabTap;
  final List<BottomNavItem> items;
  final Color? activeColor;
  final bool showFab;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onFabTap,
    required this.items,
    this.activeColor,
    this.showFab = true,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Set initial active state
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.activeColor ?? Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left items
              ...List.generate(
                widget.showFab ? 2 : widget.items.length ~/ 2,
                (index) => _buildNavItem(index, primaryColor, isDark),
              ),

              // Center FAB
              if (widget.showFab) _buildCenterFab(primaryColor),

              // Right items
              if (widget.showFab)
                ...List.generate(
                  2,
                  (index) => _buildNavItem(index + 2, primaryColor, isDark),
                ),
              if (!widget.showFab)
                ...List.generate(
                  widget.items.length - widget.items.length ~/ 2,
                  (index) => _buildNavItem(
                      index + widget.items.length ~/ 2, primaryColor, isDark),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, Color primaryColor, bool isDark) {
    if (index >= widget.items.length) return const SizedBox();

    final item = widget.items[index];
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animated container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.all(isActive ? 10 : 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? primaryColor.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: isActive ? 24 : 22,
                    color: isActive
                        ? primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 4),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isActive ? 11 : 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    letterSpacing: 0.2,
                  ),
                  child: Text(item.label),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCenterFab(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onFabTap?.call();
      },
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.compare_arrows_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

//
// ============ NAV ITEM MODEL ============
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

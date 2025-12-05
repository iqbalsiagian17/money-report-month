import 'package:flutter/material.dart';
import 'dart:ui';

// ============ PRIMARY BUTTON (Modern Gradient) ============
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool useGradient;
  final List<Color>? gradientColors;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.useGradient = true,
    this.gradientColors,
    this.height = 56,
    this.width,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.backgroundColor ?? Theme.of(context).primaryColor;
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    if (widget.isOutlined) {
      return _buildOutlinedButton(primaryColor, radius);
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : _onTapDown,
        onTapUp: widget.isLoading ? null : _onTapUp,
        onTapCancel: widget.isLoading ? null : _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: widget.useGradient
                ? LinearGradient(
                    colors: widget.gradientColors ??
                        [
                          primaryColor,
                          primaryColor
                              .withBlue((primaryColor.blue + 40).clamp(0, 255)),
                        ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.useGradient ? null : primaryColor,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(_isPressed ? 0.2 : 0.4),
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(0, _isPressed ? 4 : 8),
                spreadRadius: _isPressed ? 0 : 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: null, // Handled by GestureDetector
              child: Center(
                child: _buildChild(widget.textColor ?? Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(Color color, BorderRadius radius) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : _onTapDown,
        onTapUp: widget.isLoading ? null : _onTapUp,
        onTapCancel: widget.isLoading ? null : _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color, width: 2),
            color: _isPressed ? color.withOpacity(0.1) : Colors.transparent,
          ),
          child: Center(
            child: _buildChild(color),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 22, color: color),
          const SizedBox(width: 10),
          Text(
            widget.text,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ============ GLASSMORPHISM BUTTON ============
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final double? width;
  final Color? color;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 56,
    this.width,
    this.color,
    this.isLoading = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ NEUMORPHISM BUTTON ============
class NeumorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final bool isLoading;

  const NeumorphicButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 56,
    this.width,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E8E8));
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.shade400,
                    offset: const Offset(6, 6),
                    blurRadius: 15,
                  ),
                  BoxShadow(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    offset: const Offset(-6, -6),
                    blurRadius: 15,
                  ),
                ],
        ),
        child: Container(
          decoration: _isPressed
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.black.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ]
                        : [
                            Colors.grey.shade300,
                            Colors.white,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
              : null,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: primaryColor, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ============ FLOATING ACTION BUTTON MODERN ============
class ModernFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? label;
  final bool mini;
  final bool useGradient;
  final List<Color>? gradientColors;

  const ModernFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.label,
    this.mini = false,
    this.useGradient = true,
    this.gradientColors,
  });

  @override
  State<ModernFAB> createState() => _ModernFABState();
}

class _ModernFABState extends State<ModernFAB>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.backgroundColor ?? Theme.of(context).primaryColor;
    final size = widget.mini ? 48.0 : 64.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: size,
          padding: widget.label != null
              ? const EdgeInsets.symmetric(horizontal: 20)
              : null,
          width: widget.label != null ? null : size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
            gradient: widget.useGradient
                ? LinearGradient(
                    colors: widget.gradientColors ??
                        [
                          primaryColor,
                          primaryColor
                              .withBlue((primaryColor.blue + 50).clamp(0, 255)),
                        ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.useGradient ? null : primaryColor,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor ?? Colors.white,
                size: widget.mini ? 24 : 28,
              ),
              if (widget.label != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: widget.iconColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============ ICON BUTTON MODERN ============
class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool hasShadow;
  final bool useGradient;
  final List<Color>? gradientColors;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.hasShadow = true,
    this.useGradient = false,
    this.gradientColors,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.backgroundColor ?? Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.useGradient
                ? LinearGradient(
                    colors: widget.gradientColors ??
                        [
                          primaryColor,
                          primaryColor
                              .withBlue((primaryColor.blue + 40).clamp(0, 255)),
                        ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.useGradient
                ? null
                : (widget.backgroundColor ?? primaryColor.withOpacity(0.1)),
            boxShadow: widget.hasShadow
                ? [
                    BoxShadow(
                      color: widget.useGradient
                          ? primaryColor.withOpacity(0.4)
                          : (isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2)),
                      blurRadius: _isPressed ? 8 : 16,
                      offset: Offset(0, _isPressed ? 2 : 6),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor ??
                (widget.useGradient ? Colors.white : primaryColor),
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}

// ============ SOCIAL BUTTON ============
class SocialButton extends StatefulWidget {
  final String text;
  final String iconPath; // SVG or asset path
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? iconData; // Alternative to iconPath
  final Color? iconColor;

  const SocialButton({
    super.key,
    required this.text,
    this.iconPath = '',
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.iconData,
    this.iconColor,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF2D2D2D) : Colors.white);
    final fgColor =
        widget.textColor ?? (isDark ? Colors.white : Colors.black87);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.iconData != null) ...[
                Icon(
                  widget.iconData,
                  size: 24,
                  color: widget.iconColor ?? fgColor,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ CHIP BUTTON ============
class ChipButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? selectedColor;

  const ChipButton({
    super.key,
    required this.text,
    this.isSelected = false,
    required this.onPressed,
    this.icon,
    this.selectedColor,
  });

  @override
  State<ChipButton> createState() => _ChipButtonState();
}

class _ChipButtonState extends State<ChipButton> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.selectedColor ?? Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? primaryColor
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(30),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey.shade600),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.text,
              style: TextStyle(
                color: widget.isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
                fontSize: 14,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ ANIMATED ICON BUTTON ============
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final bool isActive;
  final VoidCallback onPressed;
  final Color? color;
  final Color? activeColor;
  final double size;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.activeIcon,
    this.isActive = false,
    required this.onPressed,
    this.color,
    this.activeColor,
    this.size = 28,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final inactiveColor = widget.color ?? Colors.grey;
    final activeColor = widget.activeColor ?? primaryColor;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.isActive
                    ? (widget.activeIcon ?? widget.icon)
                    : widget.icon,
                size: widget.size,
                color: widget.isActive ? activeColor : inactiveColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

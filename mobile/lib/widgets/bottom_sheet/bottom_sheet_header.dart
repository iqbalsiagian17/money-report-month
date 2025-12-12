import 'package:flutter/material.dart';

class BottomSheetHandle extends StatelessWidget {
  final Color? color;
  final double width;
  final double height;
  final EdgeInsets margin;

  const BottomSheetHandle({
    super.key,
    this.color,
    this.width = 40,
    this.height = 4,
    this.margin = const EdgeInsets.only(top: 12, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[400],
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

class BottomSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets padding;

  const BottomSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showCloseButton = false,
    this.onClose,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(24, 8, 24, 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showCloseButton)
            IconButton(
              onPressed: onClose ?? () => Navigator.pop(context),
              icon: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}

class BottomSheetIconHeader extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Color iconColor;
  final Color? iconBackgroundColor;

  const BottomSheetIconHeader({
    super.key,
    required this.title,
    this.message,
    required this.icon,
    required this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: iconBackgroundColor ?? iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: iconColor, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../bottom_sheet_header.dart';
import '../bottom_sheet_action.dart';

class ConfirmBottomSheet extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isDanger;

  const ConfirmBottomSheet({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText = 'Ya, Lanjutkan',
    this.cancelText = 'Batal',
    this.confirmColor,
    this.icon,
    this.iconColor,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ?? (isDanger ? Colors.red : Colors.orange);
    final effectiveConfirmColor = confirmColor ??
        (isDanger ? Colors.red : Theme.of(context).primaryColor);
    final effectiveIcon = icon ??
        (isDanger ? Icons.delete_forever_rounded : Icons.help_outline_rounded);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: 16),

          // Icon & Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BottomSheetIconHeader(
              title: title,
              message: message,
              icon: effectiveIcon,
              iconColor: effectiveIconColor,
            ),
          ),

          // Custom content
          if (content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: content!,
            ),

          // Actions
          BottomSheetActions(
            primaryText: confirmText,
            secondaryText: cancelText,
            primaryColor: effectiveConfirmColor,
            onPrimary: () => Navigator.pop(context, true),
            onSecondary: () => Navigator.pop(context, false),
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
          ),
        ],
      ),
    );
  }
}

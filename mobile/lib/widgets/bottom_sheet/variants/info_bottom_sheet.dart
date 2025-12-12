import 'package:flutter/material.dart';
import '../bottom_sheet_header.dart';
import '../bottom_sheet_action.dart';

enum InfoType { info, success, error, warning }

class InfoBottomSheet extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String buttonText;
  final IconData? icon;
  final Color? iconColor;
  final InfoType type;

  const InfoBottomSheet({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.buttonText = 'Mengerti',
    this.icon,
    this.iconColor,
    this.type = InfoType.info,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeConfig = _getTypeConfig();

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
              icon: icon ?? typeConfig.icon,
              iconColor: iconColor ?? typeConfig.color,
            ),
          ),

          // Custom content
          if (content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: content!,
            ),

          // Action
          BottomSheetActions(
            primaryText: buttonText,
            primaryColor: iconColor ?? typeConfig.color,
            showSecondary: false,
            onPrimary: () => Navigator.pop(context),
            direction: Axis.vertical,
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
          ),
        ],
      ),
    );
  }

  _TypeConfig _getTypeConfig() {
    switch (type) {
      case InfoType.success:
        return _TypeConfig(Icons.check_circle_rounded, Colors.green);
      case InfoType.error:
        return _TypeConfig(Icons.error_rounded, Colors.red);
      case InfoType.warning:
        return _TypeConfig(Icons.warning_rounded, Colors.orange);
      case InfoType.info:
      default:
        return _TypeConfig(Icons.info_rounded, Colors.blue);
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  _TypeConfig(this.icon, this.color);
}

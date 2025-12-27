import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SnackType {
  success,
  error,
  warning,
  info,
}

class SnackHelper {
  SnackHelper._();

  /// Show success snackbar
  static void success(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackType.success,
      duration: duration,
      action: action,
    );
  }

  /// Show error snackbar
  static void error(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      title: title ?? 'Error',
      type: SnackType.error,
      duration: duration,
      action: action,
    );
  }

  /// Show warning snackbar
  static void warning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackType.warning,
      duration: duration,
      action: action,
    );
  }

  /// Show info snackbar
  static void info(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackType.info,
      duration: duration,
      action: action,
    );
  }

  /// Show custom snackbar
  static void custom(
    BuildContext context, {
    required String message,
    String? title,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showCustom(
      context,
      message: message,
      title: title,
      icon: icon,
      color: color,
      duration: duration,
      action: action,
    );
  }

  /// Show loading snackbar (doesn't auto dismiss)
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> loading(
    BuildContext context,
    String message,
  ) {
    HapticFeedback.lightImpact();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      duration: const Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.all(16),
      dismissDirection: DismissDirection.none,
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Hide current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Clear all snackbars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // ================= PRIVATE METHODS =================

  static void _show(
    BuildContext context, {
    required String message,
    String? title,
    required SnackType type,
    required Duration duration,
    SnackBarAction? action,
  }) {
    HapticFeedback.lightImpact();

    final config = _getTypeConfig(type);

    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              config.icon,
              color: config.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontWeight:
                        title != null ? FontWeight.w400 : FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      dismissDirection: DismissDirection.horizontal,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void _showCustom(
    BuildContext context, {
    required String message,
    String? title,
    required IconData icon,
    required Color color,
    required Duration duration,
    SnackBarAction? action,
  }) {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontWeight:
                        title != null ? FontWeight.w400 : FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      dismissDirection: DismissDirection.horizontal,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static _SnackTypeConfig _getTypeConfig(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackTypeConfig(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF4CAF50),
        );
      case SnackType.error:
        return _SnackTypeConfig(
          icon: Icons.error_rounded,
          color: const Color(0xFFE53935),
        );
      case SnackType.warning:
        return _SnackTypeConfig(
          icon: Icons.warning_rounded,
          color: Colors.orange,
        );
      case SnackType.info:
        return _SnackTypeConfig(
          icon: Icons.info_rounded,
          color: const Color(0xFF2196F3),
        );
    }
  }
}

// ================= HELPER CLASSES =================

class _SnackTypeConfig {
  final IconData icon;
  final Color color;

  _SnackTypeConfig({
    required this.icon,
    required this.color,
  });
}

// ================= EXTENSION FOR EASIER ACCESS =================

extension SnackHelperExtension on BuildContext {
  void showSuccessSnack(String message, {String? title}) {
    SnackHelper.success(this, message, title: title);
  }

  void showErrorSnack(String message, {String? title}) {
    SnackHelper.error(this, message, title: title);
  }

  void showWarningSnack(String message, {String? title}) {
    SnackHelper.warning(this, message, title: title);
  }

  void showInfoSnack(String message, {String? title}) {
    SnackHelper.info(this, message, title: title);
  }

  void hideSnack() {
    SnackHelper.hide(this);
  }
}

import 'package:flutter/material.dart';
import 'bottom_sheet_header.dart';
import 'bottom_sheet_action.dart';
import 'variants/form_bottom_sheet.dart';
import 'variants/confirm_bottom_sheet.dart';
import 'variants/info_bottom_sheet.dart';
import 'variants/options_bottom_sheet.dart';


class AppBottomSheet {
  AppBottomSheet._();

  // ============ SHOW CONFIRM ============
  /// Menampilkan bottom sheet konfirmasi (Ya/Tidak)
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String confirmText = 'Ya, Lanjutkan',
    String cancelText = 'Batal',
    Color? confirmColor,
    IconData? icon,
    Color? iconColor,
    bool isDanger = false,
    bool barrierDismissible = true,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: barrierDismissible,
      isScrollControlled: true,
      builder: (context) => ConfirmBottomSheet(
        title: title,
        message: message,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
        iconColor: iconColor,
        isDanger: isDanger,
      ),
    );
  }

  // ============ SHOW INFO ============
  /// Menampilkan bottom sheet informasi
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String buttonText = 'Mengerti',
    IconData? icon,
    Color? iconColor,
    InfoType type = InfoType.info,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => InfoBottomSheet(
        title: title,
        message: message,
        content: content,
        buttonText: buttonText,
        icon: icon,
        iconColor: iconColor,
        type: type,
      ),
    );
  }

  // ============ SHOW SUCCESS ============
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String buttonText = 'Selesai',
  }) {
    return showInfo(
      context: context,
      title: title,
      message: message,
      content: content,
      buttonText: buttonText,
      type: InfoType.success,
    );
  }

  // ============ SHOW ERROR ============
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String buttonText = 'Tutup',
  }) {
    return showInfo(
      context: context,
      title: title,
      message: message,
      content: content,
      buttonText: buttonText,
      type: InfoType.error,
    );
  }

  // ============ SHOW WARNING ============
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String buttonText = 'Mengerti',
  }) {
    return showInfo(
      context: context,
      title: title,
      message: message,
      content: content,
      buttonText: buttonText,
      type: InfoType.warning,
    );
  }

  // ============ SHOW OPTIONS ============
  /// Menampilkan bottom sheet pilihan/menu
  static Future<T?> showOptions<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<BottomSheetOption<T>> options,
    bool showDivider = true,
    bool dismissOnSelect = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OptionsBottomSheet<T>(
        title: title,
        subtitle: subtitle,
        options: options,
        showDivider: showDivider,
        dismissOnSelect: dismissOnSelect,
      ),
    );
  }

  // ============ SHOW FORM ============
  /// Menampilkan bottom sheet dengan form
  static Future<T?> showForm<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget Function(BuildContext context, StateSetter setState)
        builder,
    required Future<T?> Function() onSubmit,
    String submitText = 'Simpan',
    String? cancelText,
    bool validateOnSubmit = true,
    GlobalKey<FormState>? formKey,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      isScrollControlled: true,
      builder: (context) => FormBottomSheet<T>(
        title: title,
        subtitle: subtitle,
        builder: builder,
        onSubmit: onSubmit,
        submitText: submitText,
        cancelText: cancelText,
        validateOnSubmit: validateOnSubmit,
        formKey: formKey,
      ),
    );
  }

  // ============ SHOW CUSTOM ============
  /// Menampilkan bottom sheet custom
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    bool showHandle = true,
    bool showCloseButton = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    double? maxHeight,
    EdgeInsets? padding,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      builder: (context) => _CustomBottomSheetWrapper(
        title: title,
        subtitle: subtitle,
        showHandle: showHandle,
        showCloseButton: showCloseButton,
        maxHeight: maxHeight,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }

  // ============ SHOW LOADING ============
  /// Menampilkan bottom sheet loading
  static Future<T?> showLoading<T>({
    required BuildContext context,
    String message = 'Mohon tunggu...',
    bool isDismissible = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: false,
      builder: (context) => _LoadingBottomSheet(message: message),
    );
  }

  // ============ SHOW INPUT ============
  /// Menampilkan bottom sheet input sederhana
  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? subtitle,
    String? initialValue,
    String? hintText,
    String? labelText,
    String submitText = 'Simpan',
    String cancelText = 'Batal',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return showForm<String>(
      context: context,
      title: title,
      subtitle: subtitle,
      formKey: formKey,
      submitText: submitText,
      cancelText: cancelText,
      builder: (context, setState) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
        ),
        validator: validator,
      ),
      onSubmit: () async {
        if (formKey.currentState?.validate() ?? false) {
          return controller.text;
        }
        return null;
      },
    );
  }
}

// ============ CUSTOM WRAPPER ============
class _CustomBottomSheetWrapper extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final bool showHandle;
  final bool showCloseButton;
  final double? maxHeight;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const _CustomBottomSheetWrapper({
    this.title,
    this.subtitle,
    required this.child,
    this.showHandle = true,
    this.showCloseButton = false,
    this.maxHeight,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? const Color(0xFF1A1A1A) : Colors.white),
        borderRadius: borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle) const BottomSheetHandle(),
            if (title != null || showCloseButton)
              BottomSheetHeader(
                title: title ?? '',
                subtitle: subtitle,
                showCloseButton: showCloseButton,
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ LOADING BOTTOM SHEET ============
class _LoadingBottomSheet extends StatelessWidget {
  final String message;

  const _LoadingBottomSheet({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

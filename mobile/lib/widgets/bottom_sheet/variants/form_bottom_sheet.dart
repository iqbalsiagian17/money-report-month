import 'package:flutter/material.dart';
import '../bottom_sheet_header.dart';
import '../bottom_sheet_action.dart';

class FormBottomSheet<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget Function(BuildContext context, StateSetter setState) builder;
  final Future<T?> Function() onSubmit;
  final String submitText;
  final String? cancelText;
  final bool validateOnSubmit;
  final GlobalKey<FormState>? formKey;

  const FormBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.builder,
    required this.onSubmit,
    this.submitText = 'Simpan',
    this.cancelText,
    this.validateOnSubmit = true,
    this.formKey,
  });

  @override
  State<FormBottomSheet<T>> createState() => _FormBottomSheetState<T>();
}

class _FormBottomSheetState<T> extends State<FormBottomSheet<T>> {
  late GlobalKey<FormState> _formKey;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  Future<void> _handleSubmit() async {
    if (widget.validateOnSubmit &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.onSubmit();
      if (mounted && result != null) {
        Navigator.pop(context, result);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            BottomSheetHeader(
              title: widget.title,
              subtitle: widget.subtitle,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: StatefulBuilder(
                    builder: (context, setState) =>
                        widget.builder(context, setState),
                  ),
                ),
              ),
            ),
            BottomSheetActions(
              primaryText: widget.submitText,
              secondaryText: widget.cancelText ?? 'Batal',
              isLoading: _isLoading,
              onPrimary: _handleSubmit,
              onSecondary: () => Navigator.pop(context),
              padding: EdgeInsets.fromLTRB(
                  24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
            ),
          ],
        ),
      ),
    );
  }
}

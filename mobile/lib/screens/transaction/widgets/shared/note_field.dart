import 'package:flutter/material.dart';

class NoteField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;

  const NoteField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: 'Catatan',
        hintText: hintText ?? 'Contoh: Makan siang, Bensin motor',
        prefixIcon: const Icon(Icons.edit_note_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

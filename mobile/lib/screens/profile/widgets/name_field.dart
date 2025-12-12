import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;

  const NameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Kamu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Masukkan nama kamu',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}

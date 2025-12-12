import 'package:flutter/material.dart';
import '../../../../providers/theme_provider.dart';

class ColorPickerDialog extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ColorPickerDialog({
    super.key,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Warna Tema'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: themeProvider.availableColors.map((color) {
          final isSelected = color.value == themeProvider.primaryColor.value;
          return _ColorItem(
            color: color,
            isSelected: isSelected,
            onTap: () {
              themeProvider.setPrimaryColor(color);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ColorItem extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorItem({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}

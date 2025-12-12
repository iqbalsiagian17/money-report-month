import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onChanged;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  static const List<Color> availableColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFFFF8E8E), // Light Red
    Color(0xFFFFB347), // Orange
    Color(0xFFFFE66D), // Yellow
    Color(0xFF98D8C8), // Mint
    Color(0xFF4ECDC4), // Teal
    Color(0xFF95E1D3), // Light Teal
    Color(0xFF85C1E9), // Light Blue
    Color(0xFF5DADE2), // Blue
    Color(0xFFAED6F1), // Sky Blue
    Color(0xFFBB8FCE), // Purple
    Color(0xFFDDA0DD), // Plum
    Color(0xFFF1948A), // Salmon
    Color(0xFFD5DBDB), // Grey
    Color(0xFF7DCEA0), // Green
    Color(0xFF82E0AA), // Light Green
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pilih Warna',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = selectedColor.value == color.value;

              return GestureDetector(
                onTap: () => onChanged(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: _getContrastColor(color),
                          size: 16,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Menentukan warna kontras untuk icon check
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

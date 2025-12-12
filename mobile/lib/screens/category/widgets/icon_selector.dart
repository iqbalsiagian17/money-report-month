import 'package:flutter/material.dart';

class IconSelector extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onChanged;

  const IconSelector({
    super.key,
    required this.selectedIcon,
    required this.onChanged,
  });

  static const List<String> availableIcons = [
    '📦',
    '🛒',
    '🍔',
    '🍿',
    '🍕',
    '☕',
    '🚗',
    '🚌',
    '✈️',
    '🏠',
    '💡',
    '📱',
    '💊',
    '🏥',
    '🎮',
    '🎬',
    '🎵',
    '📚',
    '👕',
    '👟',
    '💄',
    '💅',
    '🐕',
    '🐈',
    '💼',
    '🎁',
    '💰',
    '💳',
    '🏦',
    '📈',
    '❤️',
    '🙏',
    '🎓',
    '🏋️',
    '⚽',
    '🎨',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pilih Ikon',
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
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final icon = availableIcons[index];
              final isSelected = selectedIcon == icon;

              return GestureDetector(
                onTap: () => onChanged(icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

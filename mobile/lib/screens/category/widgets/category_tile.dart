import 'package:flutter/material.dart';
import '../../../models/category.dart';
import 'category_options.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;

  const CategoryTile({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = Color(category.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CategoryOptions.show(context, category),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildIcon(categoryColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildSubtitle(categoryColor),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color categoryColor) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withOpacity(0.25),
            categoryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          category.icon,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }

  Widget _buildSubtitle(Color categoryColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: categoryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: category.isDefault
                ? Colors.blue.withOpacity(0.1)
                : Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            category.isDefault ? 'Default' : 'Custom',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: category.isDefault ? Colors.blue : Colors.purple,
            ),
          ),
        ),
      ],
    );
  }
}

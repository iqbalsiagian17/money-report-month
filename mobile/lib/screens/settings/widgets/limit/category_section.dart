import 'package:flutter/material.dart';
import '../../../../models/category.dart';

class LimitCategorySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> selectedCategoryIds;
  final List<CategoryModel> allCategories;
  final Function(String categoryId, bool isSelected) onCategoryToggle;
  final bool isDark;

  const LimitCategorySection({
    super. key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selectedCategoryIds,
    required this.allCategories,
    required this.onCategoryToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ?  const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCategoryChips(),
          if (selectedCategoryIds.isEmpty) ...[
            const SizedBox(height: 12),
            _buildWarning(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors. black87,
              ),
            ),
          ],
        ),
        const SizedBox(height:  4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allCategories.map((category) {
        final isSelected = selectedCategoryIds.contains(category.id);
        return _CategoryChip(
          category: category,
          isSelected: isSelected,
          color: color,
          isDark: isDark,
          onTap: () => onCategoryToggle(category.id, ! isSelected),
        );
      }).toList(),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pilih minimal 1 kategori',
              style: TextStyle(fontSize: 12, color: Colors. orange[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? color
                    :  (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width:  4),
              Icon(Icons.check_circle, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
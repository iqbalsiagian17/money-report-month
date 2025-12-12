import 'package:flutter/material.dart';
import '../../../../providers/category_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../models/category.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategoryId;
  final CategoryProvider categoryProvider;
  final UserProvider userProvider;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.categoryProvider,
    required this.userProvider,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = categoryProvider.expenseCategories;

    if (categories.isEmpty) {
      return _buildEmptyWarning();
    }

    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Kategori',
        prefixIcon: const Icon(Icons.category_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: categories.map((category) {
        final limitType = userProvider.getLimitTypeForCategory(category.id);
        return DropdownMenuItem<String>(
          value: category.id,
          child: _CategoryItem(
            icon: category.icon,
            name: category.name,
            limitType: limitType,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Pilih kategori' : null,
    );
  }

  Widget _buildEmptyWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada kategori.  Tambahkan di Settings > Kelola Kategori',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String icon;
  final String name;
  final String limitType;

  const _CategoryItem({
    required this.icon,
    required this.name,
    required this.limitType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Text(name),
        if (limitType != 'none') ...[
          const SizedBox(width: 8),
          _LimitBadge(limitType: limitType),
        ],
      ],
    );
  }
}

class _LimitBadge extends StatelessWidget {
  final String limitType;

  const _LimitBadge({required this.limitType});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (limitType) {
      case 'daily':
        color = Colors.blue;
        text = 'Harian';
        break;
      case 'weekend':
        color = Colors.purple;
        text = 'Weekend';
        break;
      case 'unlimited':
        color = Colors.green;
        text = 'Bebas';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

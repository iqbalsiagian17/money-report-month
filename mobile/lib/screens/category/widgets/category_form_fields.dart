import 'package:flutter/material.dart';
import 'icon_selector.dart';

// ================= CATEGORY NAME FIELD =================
class CategoryNameField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;
  final String? selectedIcon;
  final Color? iconColor;

  const CategoryNameField({
    super.key,
    required this.controller,
    this.onChanged,
    this.selectedIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        labelText: 'Nama Kategori',
        hintText: 'Contoh: Skincare, Laundry',
        prefixIcon: Icon(
          IconSelector.getIconData(selectedIcon),
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama kategori tidak boleh kosong';
        }
        return null;
      },
    );
  }
}

// ================= CATEGORY PREVIEW =================
class CategoryPreview extends StatelessWidget {
  final String name;
  final String icon;
  final Color color;

  const CategoryPreview({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconData = IconSelector.getIconData(icon);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              iconData,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Nama Kategori' : name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: name.isEmpty
                        ? Colors.grey[500]
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Preview',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Preview badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.visibility_rounded,
              color: color,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CATEGORY DELETE PREVIEW =================
class CategoryDeletePreview extends StatelessWidget {
  final String name;
  final String icon;
  final Color color;

  const CategoryDeletePreview({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconData = IconSelector.getIconData(icon);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Akan dihapus permanen',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.delete_forever_rounded,
            color: Colors.red[400],
            size: 24,
          ),
        ],
      ),
    );
  }
}

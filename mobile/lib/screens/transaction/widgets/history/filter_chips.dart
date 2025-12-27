import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  const TransactionFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChipItem(
            value: 'all',
            label: 'Semua',
            icon: Icons.list_rounded,
            isSelected: selectedFilter == 'all',
            onSelected: () {
              HapticFeedback.lightImpact();
              onChanged('all');
            },
          ),
          const SizedBox(width: 10),
          _FilterChipItem(
            value: 'income',
            label: 'Pemasukan',
            icon: Icons.arrow_downward_rounded,
            color: Colors.green,
            isSelected: selectedFilter == 'income',
            onSelected: () {
              HapticFeedback.lightImpact();
              onChanged('income');
            },
          ),
          const SizedBox(width: 10),
          _FilterChipItem(
            value: 'expense',
            label: 'Pengeluaran',
            icon: Icons.arrow_upward_rounded,
            color: Colors.red,
            isSelected: selectedFilter == 'expense',
            onSelected: () {
              HapticFeedback.lightImpact();
              onChanged('expense');
            },
          ),
          const SizedBox(width: 10),
          _FilterChipItem(
            value: 'transfer',
            label: 'Transfer',
            icon: Icons.swap_horiz_rounded,
            color: Colors.blue,
            isSelected: selectedFilter == 'transfer',
            onSelected: () {
              HapticFeedback.lightImpact();
              onChanged('transfer');
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChipItem({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.15)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: !isDark && !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? chipColor
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? chipColor
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

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
            isSelected: selectedFilter == 'all',
            onSelected: () => onChanged('all'),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            value: 'income',
            label: 'Pemasukan',
            isSelected: selectedFilter == 'income',
            onSelected: () => onChanged('income'),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            value: 'expense',
            label: 'Pengeluaran',
            isSelected: selectedFilter == 'expense',
            onSelected: () => onChanged('expense'),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChipItem({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

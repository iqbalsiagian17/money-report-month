import 'package:flutter/material.dart';

class IncomeSourceDropdown extends StatelessWidget {
  final String selectedSource;
  final ValueChanged<String?> onChanged;

  const IncomeSourceDropdown({
    super.key,
    required this.selectedSource,
    required this.onChanged,
  });

  static const List<String> incomeSources = [
    'Gaji',
    'Bonus',
    'Hadiah',
    'Usaha',
    'Investasi',
    'Pinjaman',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: selectedSource,
      decoration: InputDecoration(
        labelText: 'Sumber Pemasukan',
        prefixIcon: const Icon(Icons.source_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: incomeSources.map((source) {
        return DropdownMenuItem(
          value: source,
          child: Row(
            children: [
              Text(_getSourceIcon(source),
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(source),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  String _getSourceIcon(String source) {
    switch (source) {
      case 'Gaji':
        return '💼';
      case 'Bonus':
        return '🎁';
      case 'Hadiah':
        return '🎉';
      case 'Usaha':
        return '🏪';
      case 'Investasi':
        return '📈';
      case 'Pinjaman':
        return '🤝';
      default:
        return '💰';
    }
  }
}

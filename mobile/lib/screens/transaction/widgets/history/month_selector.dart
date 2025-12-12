import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onChanged(DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
              ));
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              onChanged(DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              ));
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

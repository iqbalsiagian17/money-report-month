import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';

class DayOfWeekChart extends StatelessWidget {
  final TransactionProvider txProvider;

  const DayOfWeekChart({
    super.key,
    required this.txProvider,
  });

  // Format ringkas untuk angka besar
  String _formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 100000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseByDay = txProvider.expenseByDayOfWeek;
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    final maxValue = expenseByDay.values.isEmpty
        ? 100.0
        : expenseByDay.values.reduce((a, b) => a > b ? a : b);

    // Find the day with max expense
    int maxDay = 1;
    double maxAmount = 0;
    expenseByDay.forEach((day, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        maxDay = day;
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          Row(
            children: [
              Icon(
                Icons.calendar_view_week_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pengeluaran per Hari',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (maxAmount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Paling boros:  ${days[maxDay - 1]} (${_formatCompact(maxAmount)})',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final dayIndex = index + 1;
            final value = expenseByDay[dayIndex] ?? 0;
            final percentage = maxValue > 0 ? value / maxValue : 0.0;
            final isMax = dayIndex == maxDay && maxAmount > 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isMax
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isMax ? FontWeight.bold : FontWeight.normal,
                        color: isMax ? Colors.orange : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage.clamp(0.0, 1.0),
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isMax
                                    ? [Colors.orange, Colors.deepOrange]
                                    : [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.7)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 6),
                            child: percentage > 0.35
                                ? FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _formatCompact(value),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (percentage <= 0.35 && value > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        _formatCompact(value),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

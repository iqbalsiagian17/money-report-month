import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeExpenseChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseChart({
    super.key,
    required this.income,
    required this.expense,
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
    final total = income + expense;

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
                Icons.pie_chart_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pemasukan vs Pengeluaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (total == 0)
            const SizedBox(
              height: 200,
              child: Center(child: Text('Belum ada data')),
            )
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: total * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label =
                            groupIndex == 0 ? 'Pemasukan' : 'Pengeluaran';
                        return BarTooltipItem(
                          '$label\n${_formatCompact(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Pemasukan',
                                    style: TextStyle(fontSize: 11)),
                              );
                            case 1:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Pengeluaran',
                                    style: TextStyle(fontSize: 11)),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: income,
                          color: Colors.green,
                          width: 50,
                          borderRadius: BorderRadius.circular(8),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: total * 1.2,
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: expense,
                          color: Colors.red,
                          width: 50,
                          borderRadius: BorderRadius.circular(8),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: total * 1.2,
                            color: Colors.red.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _Legend(
                  color: Colors.green,
                  label: 'Pemasukan',
                  value: _formatCompact(income),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: _Legend(
                  color: Colors.red,
                  label: 'Pengeluaran',
                  value: _formatCompact(expense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

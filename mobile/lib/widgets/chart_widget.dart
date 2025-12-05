import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpenseBarChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = (income > expense ? income : expense) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY : 100,
        barTouchData: BarTouchData(enabled: false),
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
                      child: Text('Pemasukan', style: TextStyle(fontSize: 12)),
                    );
                  case 1:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child:
                          Text('Pengeluaran', style: TextStyle(fontSize: 12)),
                    );
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                width: 32,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expense,
                color: Colors.red,
                width: 32,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;

  const CategoryPieChart({
    super.key,
    required this.data,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Belum ada data'));
    }

    final sections = data.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        color: colors[entry.key] ?? Colors.grey,
        title: '',
        radius: 50,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}

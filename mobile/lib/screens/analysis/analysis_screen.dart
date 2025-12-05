import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Keuangan'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, txProvider, categoryProvider, _) {
          final thisWeekExpense = txProvider.thisWeekExpense;
          final lastWeekExpense = txProvider.lastWeekExpense;
          final weekDiff = thisWeekExpense - lastWeekExpense;
          final weekDiffPercent = lastWeekExpense > 0
              ? ((weekDiff / lastWeekExpense) * 100).round()
              : 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Weekly Comparison
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perbandingan Mingguan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWeekCard(
                            'Minggu Ini',
                            currencyFormat.format(thisWeekExpense),
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildWeekCard(
                            'Minggu Lalu',
                            currencyFormat.format(lastWeekExpense),
                            Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: weekDiff > 0
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            weekDiff > 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: weekDiff > 0 ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            weekDiff > 0
                                ? 'Pengeluaran naik $weekDiffPercent% dari minggu lalu'
                                : 'Pengeluaran turun ${weekDiffPercent.abs()}% dari minggu lalu',
                            style: TextStyle(
                              color: weekDiff > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Income vs Expense Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pemasukan vs Pengeluaran',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildIncomeExpenseChart(txProvider),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegend('Pemasukan', Colors.green),
                        const SizedBox(width: 24),
                        _buildLegend('Pengeluaran', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengeluaran per Kategori',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child:
                          _buildCategoryPieChart(txProvider, categoryProvider),
                    ),
                    const SizedBox(height: 16),
                    ..._buildCategoryList(
                        txProvider, categoryProvider, currencyFormat),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Most Expensive Day
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hari Paling Boros',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    _buildDayOfWeekChart(txProvider),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeekCard(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildIncomeExpenseChart(TransactionProvider provider) {
    final income = provider.thisMonthIncome;
    final expense = provider.thisMonthExpense;
    final total = income + expense;

    if (total == 0) {
      return const Center(child: Text('Belum ada data'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: total > 0 ? total * 1.2 : 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Pemasukan',
                        style: TextStyle(fontSize: 12));
                  case 1:
                    return const Text('Pengeluaran',
                        style: TextStyle(fontSize: 12));
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
                width: 40,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expense,
                color: Colors.red,
                width: 40,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(
      TransactionProvider txProvider, CategoryProvider categoryProvider) {
    final expenseByCategory = txProvider.expenseByCategory;

    if (expenseByCategory.isEmpty) {
      return const Center(child: Text('Belum ada data'));
    }

    final sections = expenseByCategory.entries.map((entry) {
      final category = categoryProvider.getById(entry.key);
      return PieChartSectionData(
        value: entry.value,
        color: Color(category?.colorValue ?? 0xFF888888),
        title: '',
        radius: 60,
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

  List<Widget> _buildCategoryList(
    TransactionProvider txProvider,
    CategoryProvider categoryProvider,
    NumberFormat format,
  ) {
    final expenseByCategory = txProvider.expenseByCategory;
    final sorted = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((entry) {
      final category = categoryProvider.getById(entry.key);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    Color(category?.colorValue ?? 0xFF888888).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(category?.icon ?? '📦'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(category?.name ?? 'Lainnya'),
            ),
            Text(
              format.format(entry.value),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDayOfWeekChart(TransactionProvider provider) {
    final expenseByDay = provider.expenseByDayOfWeek;
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    final maxValue = expenseByDay.values.isEmpty
        ? 100.0
        : expenseByDay.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final value = expenseByDay[dayIndex] ?? 0;
        final percentage = maxValue > 0 ? value / maxValue : 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(days[index], style: const TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage.toDouble(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: percentage == 1 ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

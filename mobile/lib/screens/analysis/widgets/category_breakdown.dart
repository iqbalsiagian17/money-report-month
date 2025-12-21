import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';

class CategoryBreakdown extends StatelessWidget {
  final TransactionProvider txProvider;
  final CategoryProvider categoryProvider;

  const CategoryBreakdown({
    super.key,
    required this.txProvider,
    required this.categoryProvider,
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
    final expenseByCategory = txProvider.expenseByCategory;

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
                Icons.donut_large_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pengeluaran per Kategori',
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
          if (expenseByCategory.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(child: Text('Belum ada data')),
            )
          else ...[
            SizedBox(
              height: 200,
              child: _buildPieChart(expenseByCategory),
            ),
            const SizedBox(height: 20),
            ..._buildCategoryList(expenseByCategory, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> expenseByCategory) {
    final total = expenseByCategory.values.fold<double>(0, (a, b) => a + b);

    final sections = expenseByCategory.entries.map((entry) {
      final category = categoryProvider.getById(entry.key);
      final percentage = total > 0 ? (entry.value / total * 100) : 0;

      return PieChartSectionData(
        value: entry.value,
        color: Color(category?.colorValue ?? 0xFF888888),
        title: percentage > 5 ? '${percentage.round()}%' : '',
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }

  List<Widget> _buildCategoryList(
    Map<String, double> expenseByCategory,
    bool isDark,
  ) {
    final total = expenseByCategory.values.fold<double>(0, (a, b) => a + b);
    final sorted = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((entry) {
      final category = categoryProvider.getById(entry.key);
      final percentage = total > 0 ? (entry.value / total * 100) : 0;
      final color = Color(category?.colorValue ?? 0xFF888888);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  category?.icon ?? '📦',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Lainnya',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 4,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCompact(entry.value),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}

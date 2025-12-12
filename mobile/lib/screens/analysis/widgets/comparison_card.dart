import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'period_selector.dart';

class ComparisonData {
  final double currentIncome;
  final double currentExpense;
  final double previousIncome;
  final double previousExpense;
  final String currentLabel;
  final String previousLabel;

  ComparisonData({
    required this.currentIncome,
    required this.currentExpense,
    required this.previousIncome,
    required this.previousExpense,
    required this.currentLabel,
    required this.previousLabel,
  });

  double get expenseDiff => currentExpense - previousExpense;
  double get incomeDiff => currentIncome - previousIncome;

  int get expenseDiffPercent =>
      previousExpense > 0 ? ((expenseDiff / previousExpense) * 100).round() : 0;

  int get incomeDiffPercent =>
      previousIncome > 0 ? ((incomeDiff / previousIncome) * 100).round() : 0;

  double get currentBalance => currentIncome - currentExpense;
  double get previousBalance => previousIncome - previousExpense;
}

class ComparisonCard extends StatelessWidget {
  final ComparisonData data;
  final AnalysisPeriod period;

  const ComparisonCard({
    super.key,
    required this.data,
    required this.period,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                period == AnalysisPeriod.weekly
                    ? Icons.compare_arrows_rounded
                    : Icons.calendar_month_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Perbandingan ${period == AnalysisPeriod.weekly ? "Mingguan" : "Bulanan"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current vs Previous Period Cards
          Row(
            children: [
              Expanded(
                child: _PeriodCard(
                  label: data.currentLabel,
                  income: data.currentIncome,
                  expense: data.currentExpense,
                  color: Theme.of(context).primaryColor,
                  formatCurrency: _formatCurrency,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PeriodCard(
                  label: data.previousLabel,
                  income: data.previousIncome,
                  expense: data.previousExpense,
                  color: Colors.grey,
                  formatCurrency: _formatCurrency,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expense Comparison
          _ComparisonRow(
            label: 'Pengeluaran',
            diff: data.expenseDiff,
            diffPercent: data.expenseDiffPercent,
            isExpense: true,
            formatCurrency: _formatCurrency,
          ),
          const SizedBox(height: 8),

          // Income Comparison
          _ComparisonRow(
            label: 'Pemasukan',
            diff: data.incomeDiff,
            diffPercent: data.incomeDiffPercent,
            isExpense: false,
            formatCurrency: _formatCurrency,
          ),
        ],
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final String label;
  final double income;
  final double expense;
  final Color color;
  final String Function(double) formatCurrency;
  final bool isDark;

  const _PeriodCard({
    required this.label,
    required this.income,
    required this.expense,
    required this.color,
    required this.formatCurrency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.arrow_downward_rounded,
            label: 'Masuk',
            value: formatCurrency(income),
            color: Colors.green,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.arrow_upward_rounded,
            label: 'Keluar',
            value: formatCurrency(expense),
            color: Colors.red,
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                formatCurrency(balance),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final double diff;
  final int diffPercent;
  final bool isExpense;
  final String Function(double) formatCurrency;

  const _ComparisonRow({
    required this.label,
    required this.diff,
    required this.diffPercent,
    required this.isExpense,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    // Untuk expense:  naik = buruk (merah), turun = bagus (hijau)
    // Untuk income: naik = bagus (hijau), turun = buruk (merah)
    final isPositive = diff > 0;
    final isGood = isExpense ? !isPositive : isPositive;
    final color = isGood ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    final diffText = isExpense
        ? (isPositive ? 'naik' : 'turun')
        : (isPositive ? 'naik' : 'turun');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label $diffText ${diffPercent.abs()}%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${formatCurrency(diff)}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

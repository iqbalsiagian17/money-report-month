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
      previousIncome > 0 ?  ((incomeDiff / previousIncome) * 100).round() : 0;

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

  // Format currency lengkap
  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // Format ringkas yang JELAS untuk angka besar
  String _formatCompact(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String result;

    if (absAmount >= 1000000000) {
      // Milyar
      final value = absAmount / 1000000000;
      result = '${value.toStringAsFixed(value >= 10 ? 1 : 2)}M';
    } else if (absAmount >= 1000000) {
      // Juta
      final value = absAmount / 1000000;
      result = '${value.toStringAsFixed(value >= 10 ? 1 : 2)}jt';
    } else if (absAmount >= 1000) {
      // Ribu
      final value = absAmount / 1000;
      result = '${value.toStringAsFixed(value >= 100 ? 0 : 1)}rb';
    } else {
      result = absAmount.toStringAsFixed(0);
    }

    return '${isNegative ? "-" : ""}$result';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow:  isDark
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  period == AnalysisPeriod.weekly
                      ? Icons.compare_arrows_rounded
                      : Icons.calendar_month_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perbandingan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color:  isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      period == AnalysisPeriod.weekly ? 'Mingguan' : 'Bulanan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Period Cards - Vertical Layout for better readability
          _PeriodCardExpanded(
            label: data.currentLabel,
            income: data.currentIncome,
            expense:  data.currentExpense,
            color: Theme.of(context).primaryColor,
            formatCurrency: _formatCurrency,
            formatCompact: _formatCompact,
            isDark: isDark,
            isCurrent: true,
          ),
          const SizedBox(height: 12),
          _PeriodCardExpanded(
            label: data.previousLabel,
            income: data.previousIncome,
            expense:  data.previousExpense,
            color: Colors.grey,
            formatCurrency: _formatCurrency,
            formatCompact: _formatCompact,
            isDark: isDark,
            isCurrent: false,
          ),
          const SizedBox(height:  16),

          // Comparison Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child:  Column(
              children: [
                _ComparisonRowImproved(
                  label: 'Pengeluaran',
                  diff: data.expenseDiff,
                  diffPercent: data.expenseDiffPercent,
                  isExpense: true,
                  formatCompact: _formatCompact,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _ComparisonRowImproved(
                  label: 'Pemasukan',
                  diff: data.incomeDiff,
                  diffPercent: data.incomeDiffPercent,
                  isExpense: false,
                  formatCompact: _formatCompact,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Card yang lebih lebar dan jelas
class _PeriodCardExpanded extends StatelessWidget {
  final String label;
  final double income;
  final double expense;
  final Color color;
  final String Function(double) formatCurrency;
  final String Function(double) formatCompact;
  final bool isDark;
  final bool isCurrent;

  const _PeriodCardExpanded({
    required this.label,
    required this.income,
    required this.expense,
    required this.color,
    required this.formatCurrency,
    required this.formatCompact,
    required this.isDark,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: isCurrent
            ? Border.all(color: color.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'AKTIF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height:  16),

          // Income & Expense Row
          Row(
            children:  [
              // Income
              Expanded(
                child: _AmountDisplay(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Pemasukan',
                  amount: income,
                  color: Colors.green,
                  formatCurrency: formatCurrency,
                  formatCompact: formatCompact,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              // Expense
              Expanded(
                child: _AmountDisplay(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Pengeluaran',
                  amount: expense,
                  color: Colors.red,
                  formatCurrency: formatCurrency,
                  formatCompact: formatCompact,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          // Balance
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: balance >= 0 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  balance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: balance >= 0 ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Saldo:  ',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  formatCurrency(balance),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Display amount dengan format yang jelas
class _AmountDisplay extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final String Function(double) formatCurrency;
  final String Function(double) formatCompact;
  final bool isDark;

  const _AmountDisplay({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.formatCurrency,
    required this.formatCompact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Amount dengan tooltip untuk nilai lengkap
        Tooltip(
          message: formatCurrency(amount),
          child: Text(
            _formatSmartAmount(amount),
            style:  TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // Format cerdas:  tampilkan angka yang pas
  String _formatSmartAmount(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(2)}M';
    } else if (amount >= 100000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(0)}jt';
    } else if (amount >= 10000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(2)}jt';
    } else if (amount >= 100000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    } else if (amount >= 10000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)}rb';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(2)}rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }
}

// Comparison row yang lebih jelas
class _ComparisonRowImproved extends StatelessWidget {
  final String label;
  final double diff;
  final int diffPercent;
  final bool isExpense;
  final String Function(double) formatCompact;
  final bool isDark;

  const _ComparisonRowImproved({
    required this.label,
    required this.diff,
    required this.diffPercent,
    required this.isExpense,
    required this.formatCompact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = diff > 0;
    final isGood = isExpense ? ! isPositive : isPositive;
    final color = diff == 0 ? Colors.grey : (isGood ? Colors.green :  Colors.red);
    
    final icon = diff == 0 
        ? Icons.remove_rounded
        : (isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);

    final statusText = diff == 0
        ?  'Sama'
        : (isPositive ? 'Naik' : 'Turun');

    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        
        // Label & Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:  TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '$statusText ${diffPercent.abs()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${isPositive && diff != 0 ? "+" : ""}${_formatDiffAmount(diff)}',
            style:  TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDiffAmount(double amount) {
    final absAmount = amount.abs();
    
    if (absAmount >= 1000000000) {
      return 'Rp ${(absAmount / 1000000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000000) {
      return 'Rp ${(absAmount / 1000000).toStringAsFixed(1)}jt';
    } else if (absAmount >= 1000) {
      return 'Rp ${(absAmount / 1000).toStringAsFixed(0)}rb';
    } else if (absAmount == 0) {
      return 'Rp 0';
    } else {
      return 'Rp ${absAmount.toStringAsFixed(0)}';
    }
  }
}
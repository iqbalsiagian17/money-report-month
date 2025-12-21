import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';

class StatisticsCard extends StatelessWidget {
  final TransactionProvider txProvider;

  const StatisticsCard({
    super.key,
    required this.txProvider,
  });

  // Format ringkas untuk angka besar
  String _formatCompact(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String result;

    if (absAmount >= 1000000000) {
      result = 'Rp ${(absAmount / 1000000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000000) {
      result = 'Rp ${(absAmount / 1000000).toStringAsFixed(1)}jt';
    } else if (absAmount >= 100000) {
      result = 'Rp ${(absAmount / 1000).toStringAsFixed(0)}rb';
    } else {
      result = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(absAmount);
    }

    return isNegative ? '-$result' : result;
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
                Icons.insights_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Statistik Bulan Ini',
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
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Total Transaksi',
                  value: '${txProvider.totalTransactionsThisMonth}',
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.calculate_rounded,
                  label: 'Rata-rata/Hari',
                  value: _formatCompact(txProvider.averageDailyExpense),
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Rata-rata/Transaksi',
                  value: _formatCompact(txProvider.averageTransactionAmount),
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Net Balance',
                  value: _formatCompact(
                      txProvider.thisMonthIncome - txProvider.thisMonthExpense),
                  color: (txProvider.thisMonthIncome -
                              txProvider.thisMonthExpense) >=
                          0
                      ? Colors.green
                      : Colors.red,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

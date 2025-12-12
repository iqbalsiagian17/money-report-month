import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../providers/user_provider.dart';
import '../../../../providers/transaction_provider.dart';

class LimitInfoCard extends StatelessWidget {
  final UserProvider userProvider;
  final TransactionProvider txProvider;

  const LimitInfoCard({
    super.key,
    required this.userProvider,
    required this.txProvider,
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
    final isWeekend = userProvider.isWeekend();
    final hasAnyLimit = userProvider.isDailyLimitEnabled || 
                        userProvider.isWeekendLimitEnabled;

    if (!hasAnyLimit) return const SizedBox. shrink();

    return Container(
      padding:  const EdgeInsets. all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black. withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isWeekend, isDark),
          const SizedBox(height: 16),
          if (userProvider.isDailyLimitEnabled)
            _LimitProgressRow(
              label: 'Limit Harian',
              icon: Icons.today,
              color: Colors.blue,
              spent: txProvider.getTodayExpenseByCategories(
                  userProvider.dailyLimitCategories),
              limit: userProvider.dailyLimit,
              isDark: isDark,
              formatCurrency: _formatCurrency,
            ),
          if (userProvider.isWeekendLimitEnabled && isWeekend) ...[
            if (userProvider.isDailyLimitEnabled) const SizedBox(height: 12),
            _LimitProgressRow(
              label: 'Limit Weekend',
              icon:  Icons.weekend,
              color:  Colors.purple,
              spent:  txProvider.getCurrentWeekendExpenseByCategories(
                  userProvider. weekendLimitCategories),
              limit: userProvider.weekendLimit,
              isDark:  isDark,
              formatCurrency: _formatCurrency,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWeekend, bool isDark) {
    return Row(
      children:  [
        Icon(Icons.info_outline_rounded,
            size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          'Status Limit Hari Ini',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:  isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (isWeekend) ...[
          const SizedBox(width: 8),
          Container(
            padding:  const EdgeInsets. symmetric(horizontal: 8, vertical: 2),
            decoration:  BoxDecoration(
              color: Colors.purple. withOpacity(0.1),
              borderRadius: BorderRadius. circular(10),
            ),
            child: const Text('🎉 Weekend', style: TextStyle(fontSize: 10)),
          ),
        ],
      ],
    );
  }
}

class _LimitProgressRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double spent;
  final double limit;
  final bool isDark;
  final String Function(double) formatCurrency;

  const _LimitProgressRow({
    required this.label,
    required this.icon,
    required this. color,
    required this.spent,
    required this.limit,
    required this.isDark,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = limit > 0 ?  (spent / limit * 100).clamp(0.0, 100.0) : 0.0;
    final remaining = (limit - spent).clamp(0.0, limit);

    Color progressColor;
    if (percentage < 50) {
      progressColor = Colors.green;
    } else if (percentage < 80) {
      progressColor = Colors. orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children:  [
            Icon(icon, size: 16, color: color),
            const SizedBox(width:  6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const Spacer(),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight. bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terpakai:  ${formatCurrency(spent)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              'Sisa: ${formatCurrency(remaining)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight. w600,
                color: remaining > 0 ? Colors.green : Colors. red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
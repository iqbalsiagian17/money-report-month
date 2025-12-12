import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/routes.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/transaction_provider.dart';

class LimitStatusCard extends StatelessWidget {
  const LimitStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Consumer2<UserProvider, TransactionProvider>(
      builder: (context, userProvider, txProvider, _) {
        final isWeekend = userProvider.isWeekend();
        final hasAnyLimit = userProvider.isDailyLimitEnabled ||
            userProvider.isWeekendLimitEnabled;

        if (!hasAnyLimit) {
          return _NoLimitCard(isDark: isDark);
        }

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.speed_rounded,
                            color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Status Limit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (isWeekend)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🎉 Weekend',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Daily Limit
              if (userProvider.isDailyLimitEnabled) ...[
                _LimitRow(
                  label: 'Harian',
                  icon: Icons.today,
                  color: Colors.blue,
                  spent: txProvider.getTodayExpenseByCategories(
                      userProvider.dailyLimitCategories),
                  limit: userProvider.dailyLimit,
                  currencyFormat: currencyFormat,
                  isDark: isDark,
                ),
              ],

              // Weekend Limit
              if (userProvider.isWeekendLimitEnabled && isWeekend) ...[
                if (userProvider.isDailyLimitEnabled)
                  const SizedBox(height: 16),
                _LimitRow(
                  label: 'Weekend',
                  icon: Icons.weekend,
                  color: Colors.purple,
                  spent: txProvider.getCurrentWeekendExpenseByCategories(
                      userProvider.weekendLimitCategories),
                  limit: userProvider.weekendLimit,
                  currencyFormat: currencyFormat,
                  isDark: isDark,
                ),
              ],

              const SizedBox(height: 16),

              // Manage Button
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.limitSettings),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tune, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Atur Limit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoLimitCard extends StatelessWidget {
  final bool isDark;

  const _NoLimitCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.speed_rounded, color: Colors.orange, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada limit aktif',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Atur limit untuk kontrol pengeluaran',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.limitSettings),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Atur Sekarang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double spent;
  final double limit;
  final NumberFormat currencyFormat;
  final bool isDark;

  const _LimitRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.spent,
    required this.limit,
    required this.currencyFormat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        limit > 0 ? (spent / limit * 100).clamp(0.0, 100.0) : 0.0;
    final remaining = (limit - spent).clamp(0.0, limit);

    Color progressColor;
    if (percentage < 50) {
      progressColor = Colors.green;
    } else if (percentage < 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              'Limit $label',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const Spacer(),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terpakai: ${currencyFormat.format(spent)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              'Sisa: ${currencyFormat.format(remaining)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: remaining > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

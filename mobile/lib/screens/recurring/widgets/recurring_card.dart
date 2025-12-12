import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/recurring_transaction.dart';
import '../../../models/wallet.dart';

class RecurringCard extends StatelessWidget {
  final RecurringTransaction recurring;
  final Wallet? wallet;
  final VoidCallback onTap;

  const RecurringCard({
    super.key,
    required this.recurring,
    required this.wallet,
    required this.onTap,
  });

  String get _recurringLabel {
    switch (recurring.recurringType) {
      case RecurringType.daily:
        return 'Setiap hari';
      case RecurringType.weekly:
        return 'Setiap minggu';
      case RecurringType.monthly:
        return 'Tanggal ${recurring.dayOfMonth}';
      case RecurringType.yearly:
        return 'Setiap tahun';
    }
  }

  IconData get _recurringIcon {
    switch (recurring.recurringType) {
      case RecurringType.daily:
        return Icons.today_rounded;
      case RecurringType.weekly:
        return Icons.view_week_rounded;
      case RecurringType.monthly:
        return Icons.calendar_month_rounded;
      case RecurringType.yearly:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = recurring.isIncome ? Colors.green : Colors.red;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                _buildIcon(color),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: _buildContent(isDark),
                ),

                // Amount & Status
                _buildAmountSection(color, currencyFormat, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        recurring.isIncome
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recurring.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(_recurringIcon, size: 13, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              _recurringLabel,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Text(
              wallet?.icon ?? '💰',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(width: 4),
            Text(
              wallet?.name ?? 'Unknown',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSection(
    Color color,
    NumberFormat format,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${recurring.isIncome ? '+' : '-'}${format.format(recurring.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        _buildStatusBadge(),
        if (recurring.nextDueDate != null) ...[
          const SizedBox(height: 4),
          _buildNextDueBadge(isDark),
        ],
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isActive = recurring.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              color: isActive ? Colors.green : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDueBadge(bool isDark) {
    final daysUntil = recurring.nextDueDate!.difference(DateTime.now()).inDays;
    final isToday = daysUntil == 0;
    final isSoon = daysUntil <= 3;

    return Text(
      isToday
          ? 'Hari ini'
          : (daysUntil < 0
              ? 'Lewat ${daysUntil.abs()} hari'
              : '$daysUntil hari lagi'),
      style: TextStyle(
        fontSize: 10,
        color: isToday || isSoon
            ? Colors.orange
            : (isDark ? Colors.grey[400] : Colors.grey[500]),
        fontWeight: isToday || isSoon ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

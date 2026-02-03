import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/debt.dart';
import 'debt_options.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;

  const DebtCard({super.key, required this.debt});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReceivable = debt.type == DebtType.receivable;
    final mainColor = isReceivable ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        DebtOptions.show(context, debt);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: debt.isOverdue
                ? Colors.orange.withOpacity(0.5)
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
            width: debt.isOverdue ? 2 : 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type badge + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Type badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isReceivable
                            ? Icons.call_received_rounded
                            : Icons.call_made_rounded,
                        size: 14,
                        color: mainColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isReceivable ? 'Piutang' : 'Hutang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),

            // Person name & amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      debt.personName.isNotEmpty
                          ? debt.personName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (debt.description != null &&
                          debt.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          debt.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(debt.remainingAmount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    if (debt.paidAmount > 0)
                      Text(
                        'dari ${_formatCurrency(debt.amount)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Progress bar (if partial)
            if (debt.status == DebtStatus.partial) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: debt.progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(mainColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Terbayar ${(debt.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],

            // Footer: Date info
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(debt.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (debt.dueDate != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: debt.isOverdue ? Colors.orange : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Jatuh tempo: ${_formatDate(debt.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: debt.isOverdue ? Colors.orange : Colors.grey[500],
                      fontWeight: debt.isOverdue ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;

    if (debt.isOverdue) {
      color = Colors.orange;
      label = 'Jatuh Tempo';
      icon = Icons.warning_amber_rounded;
    } else {
      switch (debt.status) {
        case DebtStatus.paid:
          color = Colors.green;
          label = 'Lunas';
          icon = Icons.check_circle_rounded;
          break;
        case DebtStatus.partial:
          color = Colors.blue;
          label = 'Sebagian';
          icon = Icons.timelapse_rounded;
          break;
        case DebtStatus.pending:
        color = Colors.grey;
          label = 'Pending';
          icon = Icons.schedule_rounded;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

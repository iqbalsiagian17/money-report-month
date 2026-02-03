import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DebtSummary extends StatelessWidget {
  final double totalReceivables;
  final double totalPayables;
  final int overdueCount;
  final bool isDark;

  const DebtSummary({
    super.key,
    required this.totalReceivables,
    required this.totalPayables,
    required this.overdueCount,
    required this.isDark,
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
    final net = totalReceivables - totalPayables;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2D2D2D), const Color(0xFF1E1E1E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
        ),
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
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          // Net Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                net >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: net >= 0 ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selisih',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    _formatCurrency(net.abs()),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: net >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[200]),
          const SizedBox(height: 16),

          // Receivables & Payables
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.call_received_rounded,
                  label: 'Piutang',
                  amount: totalReceivables,
                  color: Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark ? Colors.grey[700] : Colors.grey[200],
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.call_made_rounded,
                  label: 'Hutang',
                  amount: totalPayables,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          // Overdue Warning
          if (overdueCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$overdueCount jatuh tempo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/transaction.dart';
import '../../../widgets/transaction_tile.dart';

class WalletTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;

  const WalletTransactions({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            if (transactions.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${transactions.length} transaksi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          _buildEmptyState(context, isDark)
        else
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 76,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                return TransactionTile(transaction: transactions[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 28,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Transaksi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Transaksi dengan dompet ini akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

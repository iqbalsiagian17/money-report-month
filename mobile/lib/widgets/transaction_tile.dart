import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/category_provider.dart';
import '../providers/wallet_provider.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final timeFormat = DateFormat('HH:mm');

    final walletProvider = context.read<WalletProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    final wallet = walletProvider.getById(transaction.walletId);
    final category = transaction.categoryId != null
        ? categoryProvider.getById(transaction.categoryId!)
        : null;

    // ✅ Info untuk transfer
    final toWallet = transaction.toWalletId != null
        ? walletProvider.getById(transaction.toWalletId!)
        : null;

    // Tentukan tampilan berdasarkan tipe
    String title;
    String subtitle;
    Color amountColor;
    IconData typeIcon;
    String amountPrefix;

    if (transaction.type == TransactionType.transfer) {
      // ✅ Transfer: tampilkan dari → ke
      title = transaction.note ?? 'Transfer';
      subtitle = '${wallet?.name ?? "?"} → ${toWallet?.name ?? "?"}';
      amountColor = Colors.blue;
      typeIcon = Icons.swap_horiz_rounded;
      amountPrefix = '';
    } else if (transaction.type == TransactionType.income) {
      title = category?.name ?? transaction.note ?? 'Pemasukan';
      subtitle = wallet?.name ?? '';
      amountColor = Colors.green;
      typeIcon = Icons.arrow_downward_rounded;
      amountPrefix = '+';
    } else {
      title = category?.name ?? transaction.note ?? 'Pengeluaran';
      subtitle = wallet?.name ?? '';
      amountColor = Colors.red;
      typeIcon = Icons.arrow_upward_rounded;
      amountPrefix = '-';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category != null
                    ? Color(category.colorValue).withOpacity(0.2)
                    : amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: category != null
                    ? Text(category.icon, style: const TextStyle(fontSize: 20))
                    : Icon(typeIcon, color: amountColor),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeFormat.format(transaction.dateTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (category != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(category.colorValue),
                      ),
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
}

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

    final categoryProvider = context.read<CategoryProvider>();
    final walletProvider = context.read<WalletProvider>();

    final category = transaction.categoryId != null
        ? categoryProvider.getById(transaction.categoryId!)
        : null;
    final wallet = walletProvider.getById(transaction.walletId);

    final isIncome = transaction.type == TransactionType.income;

    // Tentukan warna dan icon berdasarkan tipe transaksi
    Color amountColor;
    IconData typeIcon;
    String typeLabel;

    if (isIncome) {
      amountColor = Colors.green;
      typeIcon = Icons.arrow_downward;
      typeLabel = 'Pemasukan';
    } else {
      amountColor = Colors.red;
      typeIcon = Icons.arrow_upward;
      typeLabel = 'Pengeluaran';
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
                    (transaction.note?.isNotEmpty ?? false)
                        ? transaction.note!
                        : typeLabel,
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
                          wallet?.name ?? 'Unknown',
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
                  '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/recurring_transaction.dart';
import '../../../models/wallet.dart';
import 'recurring_card.dart';

class RecurringSection extends StatelessWidget {
  final String title;
  final String icon;
  final List<RecurringTransaction> items;
  final Wallet? Function(String walletId) getWallet;
  final Function(RecurringTransaction) onItemTap;
  final Color color;

  const RecurringSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.getWallet,
    required this.onItemTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Calculate total
    final total = items.fold<double>(0, (sum, r) => sum + r.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                currencyFormat.format(total),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${items.length} transaksi rutin',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 14),

        // Cards
        ...items.map((recurring) => RecurringCard(
              recurring: recurring,
              wallet: getWallet(recurring.walletId),
              onTap: () => onItemTap(recurring),
            )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/routes.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../models/transaction.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, txProvider, categoryProvider, _) {
        final transactions = txProvider.transactions.take(5).toList();
        final currencyFormat = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.transactions),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              _EmptyTransactions(isDark: isDark)
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
                    final tx = transactions[index];
                    final category =
                        categoryProvider.getById(tx.categoryId ?? '');

                    return _TransactionTile(
                      transaction: tx,
                      categoryName: category?.name ?? 'Lainnya',
                      categoryIcon: category?.icon ?? '📦',
                      currencyFormat: currencyFormat,
                      isDark: isDark,
                      isFirst: index == 0,
                      isLast: index == transactions.length - 1,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String categoryName;
  final String categoryIcon;
  final NumberFormat currencyFormat;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _TransactionTile({
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.currencyFormat,
    required this.isDark,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor =
        isExpense ? const Color(0xFFE53935) : const Color(0xFF4CAF50);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 12,
        16,
        isLast ? 16 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(categoryIcon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (transaction.note?.isNotEmpty ?? false)
                      ? transaction.note!
                      : categoryName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM, HH:mm', 'id_ID')
                      .format(transaction.dateTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  final bool isDark;

  const _EmptyTransactions({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
            'Tekan tombol + untuk menambah',
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

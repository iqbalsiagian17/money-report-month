import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../category/widgets/icon_selector.dart';

// Import widgets
import 'widgets/history/month_selector.dart';
import 'widgets/history/filter_chips.dart';
import 'widgets/history/empty_transactions.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'all';
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Transaksi'),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        body: Column(
          children: [
            MonthSelector(
              selectedMonth: _selectedMonth,
              onChanged: (date) => setState(() => _selectedMonth = date),
            ),
            TransactionFilterChips(
              selectedFilter: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 16),

            // Summary Card
            Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                final transactions = _getFilteredTransactions(provider);
                return _MonthlySummaryCard(
                  transactions: transactions,
                  isDark: isDark,
                );
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Consumer2<TransactionProvider, CategoryProvider>(
                builder: (context, txProvider, categoryProvider, _) {
                  final transactions = _getFilteredTransactions(txProvider);
                  if (transactions.isEmpty) {
                    return const EmptyTransactions();
                  }
                  return _TransactionList(
                    transactions: transactions,
                    categoryProvider: categoryProvider,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionModel> _getFilteredTransactions(
      TransactionProvider provider) {
    var transactions = provider.transactions.where((t) {
      return t.dateTime.year == _selectedMonth.year &&
          t.dateTime.month == _selectedMonth.month;
    }).toList();

    if (_filter == 'income') {
      transactions =
          transactions.where((t) => t.type == TransactionType.income).toList();
    } else if (_filter == 'expense') {
      transactions =
          transactions.where((t) => t.type == TransactionType.expense).toList();
    } else if (_filter == 'transfer') {
      transactions = transactions
          .where((t) => t.type == TransactionType.transfer)
          .toList();
    }

    // Sort by date descending
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return transactions;
  }
}

// ============ MONTHLY SUMMARY CARD ============
class _MonthlySummaryCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isDark;

  const _MonthlySummaryCard({
    required this.transactions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
      }
    }

    final balance = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          _SummaryItem(
            icon: Icons.arrow_downward_rounded,
            label: 'Masuk',
            amount: totalIncome,
            color: Colors.green,
            isDark: isDark,
          ),
          _buildDivider(),
          _SummaryItem(
            icon: Icons.arrow_upward_rounded,
            label: 'Keluar',
            amount: totalExpense,
            color: Colors.red,
            isDark: isDark,
          ),
          _buildDivider(),
          _SummaryItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Selisih',
            amount: balance,
            color: balance >= 0 ? Colors.blue : Colors.orange,
            isDark: isDark,
            showSign: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final bool isDark;
  final bool showSign;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
    this.showSign = false,
  });

  String _formatCompact(double value) {
    final absValue = value.abs();
    String prefix = showSign ? (value >= 0 ? '+' : '-') : '';

    if (absValue >= 1000000000) {
      return '${prefix}${(absValue / 1000000000).toStringAsFixed(1)}M';
    } else if (absValue >= 1000000) {
      return '${prefix}${(absValue / 1000000).toStringAsFixed(1)}jt';
    } else if (absValue >= 1000) {
      return '${prefix}${(absValue / 1000).toStringAsFixed(0)}rb';
    }
    return '$prefix${absValue.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatCompact(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ TRANSACTION LIST ============
class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final CategoryProvider categoryProvider;

  const _TransactionList({
    required this.transactions,
    required this.categoryProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group by date
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.dateTime);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final txList = grouped[dateKey]!;
        final date = DateTime.parse(dateKey);

        return _TransactionDateGroup(
          date: date,
          transactions: txList,
          categoryProvider: categoryProvider,
          isDark: isDark,
        );
      },
    );
  }
}

class _TransactionDateGroup extends StatelessWidget {
  final DateTime date;
  final List<TransactionModel> transactions;
  final CategoryProvider categoryProvider;
  final bool isDark;

  const _TransactionDateGroup({
    required this.date,
    required this.transactions,
    required this.categoryProvider,
    required this.isDark,
  });

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Hari Ini';
    } else if (txDate == yesterday) {
      return 'Kemarin';
    }
    return DateFormat('EEEE, d MMMM', 'id_ID').format(date);
  }

  double _getDayTotal() {
    double total = 0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        total -= tx.amount;
      } else if (tx.type == TransactionType.income) {
        total += tx.amount;
      }
    }
    return total;
  }

  String _formatCompact(double value) {
    final absValue = value.abs();
    String prefix = value >= 0 ? '+' : '-';

    if (absValue >= 1000000) {
      return '${prefix}Rp${(absValue / 1000000).toStringAsFixed(1)}jt';
    } else if (absValue >= 1000) {
      return '${prefix}Rp${(absValue / 1000).toStringAsFixed(0)}rb';
    }
    return '${prefix}Rp${absValue.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final dayTotal = _getDayTotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getDateLabel(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: dayTotal >= 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatCompact(dayTotal),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: dayTotal >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Transaction Cards
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 72,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final category = categoryProvider.getById(tx.categoryId ?? '');

              return _TransactionTile(
                transaction: tx,
                categoryName: category?.name ?? 'Lainnya',
                categoryIcon: category?.icon ?? 'receipt_long',
                categoryColor:
                    category != null ? Color(category.colorValue) : Colors.grey,
                isDark: isDark,
                isFirst: index == 0,
                isLast: index == transactions.length - 1,
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _TransactionTile({
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.isDark,
    required this.isFirst,
    required this.isLast,
  });

  Color _getTransactionColor() {
    switch (transaction.type) {
      case TransactionType.income:
        return const Color(0xFF4CAF50);
      case TransactionType.expense:
        return const Color(0xFFE53935);
      case TransactionType.transfer:
        return const Color(0xFF2196F3);
    }
  }

  String _getAmountPrefix() {
    switch (transaction.type) {
      case TransactionType.income:
        return '+';
      case TransactionType.expense:
        return '-';
      case TransactionType.transfer:
        return '';
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transactionColor = _getTransactionColor();
    // Gunakan IconSelector. getIconData() untuk konsistensi
    final iconData = IconSelector.getIconData(categoryIcon);

    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        isFirst ? 14 : 10,
        14,
        isLast ? 14 : 10,
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: categoryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Transaction Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (transaction.note?.isNotEmpty ?? false)
                      ? transaction.note!
                      : categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(transaction.dateTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (transaction.type == TransactionType.transfer) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.swap_horiz_rounded,
                              size: 10,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Transfer',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${_getAmountPrefix()}${_formatCurrency(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: transactionColor,
            ),
          ),
        ],
      ),
    );
  }
}

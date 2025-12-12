import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Transaksi'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
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
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, _) {
                  final transactions = _getFilteredTransactions(provider);
                  if (transactions.isEmpty) {
                    return const EmptyTransactions();
                  }
                  return _TransactionList(transactions: transactions);
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
    }

    return transactions;
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group by date
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.dateTime);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final txList = grouped[dateKey]!;
        final date = DateTime.parse(dateKey);

        return _TransactionDateGroup(
          date: date,
          transactions: txList,
        );
      },
    );
  }
}

class _TransactionDateGroup extends StatelessWidget {
  final DateTime date;
  final List<TransactionModel> transactions;

  const _TransactionDateGroup({
    required this.date,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            DateFormat('EEEE, d MMMM', 'id_ID').format(date),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...transactions.map((tx) => TransactionTile(transaction: tx)),
      ],
    );
  }
}

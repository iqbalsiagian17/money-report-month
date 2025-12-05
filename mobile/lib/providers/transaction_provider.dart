import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final Box<TransactionModel> _box = Hive.box<TransactionModel>('transactions');

  List<TransactionModel> get transactions {
    final list = _box.values.toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<TransactionModel> getByWallet(String walletId) {
    return transactions.where((t) => t.walletId == walletId).toList();
  }

  List<TransactionModel> getByCategory(String categoryId) {
    return transactions.where((t) => t.categoryId == categoryId).toList();
  }

  List<TransactionModel> getByDateRange(DateTime start, DateTime end) {
    return transactions.where((t) {
      return t.dateTime.isAfter(start) && t.dateTime.isBefore(end);
    }).toList();
  }

  List<TransactionModel> get thisWeekTransactions {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));
    return getByDateRange(start, end);
  }

  List<TransactionModel> get lastWeekTransactions {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
            startOfThisWeek.year, startOfThisWeek.month, startOfThisWeek.day)
        .subtract(const Duration(days: 7));
    final end = start.add(const Duration(days: 7));
    return getByDateRange(start, end);
  }

  List<TransactionModel> get thisMonthTransactions {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getByDateRange(start.subtract(const Duration(seconds: 1)), end);
  }

  double get thisWeekExpense {
    return thisWeekTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get lastWeekExpense {
    return lastWeekTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get thisMonthIncome {
    return thisMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get thisMonthExpense {
    return thisMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (var t in thisMonthTransactions
        .where((t) => t.type == TransactionType.expense)) {
      final categoryId = t.categoryId ?? 'uncategorized';
      map[categoryId] = (map[categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  Map<int, double> get expenseByDayOfWeek {
    final map = <int, double>{};
    for (var t
        in transactions.where((t) => t.type == TransactionType.expense)) {
      final day = t.dateTime.weekday;
      map[day] = (map[day] ?? 0) + t.amount;
    }
    return map;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await transaction.save();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}

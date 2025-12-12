import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  late Box<TransactionModel> _box;
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  // ============ FILTER BULAN INI ============
  List<TransactionModel> get thisMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((t) {
      return t.dateTime.month == now.month && t.dateTime.year == now.year;
    }).toList();
  }

  double get thisMonthIncome {
    return thisMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double get thisMonthExpense {
    return thisMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  // ============ FILTER MINGGU INI ============
  List<TransactionModel> get thisWeekTransactions {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    return _transactions.where((t) {
      return t.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.dateTime.isBefore(end);
    }).toList();
  }

  double get thisWeekExpense {
    return thisWeekTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double get thisWeekIncome {
    return thisWeekTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  // ============ FILTER MINGGU LALU ============
  List<TransactionModel> get lastWeekTransactions {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final start = DateTime(
        startOfLastWeek.year, startOfLastWeek.month, startOfLastWeek.day);
    final end = start.add(const Duration(days: 7));

    return _transactions.where((t) {
      return t.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.dateTime.isBefore(end);
    }).toList();
  }

  double get lastWeekExpense {
    return lastWeekTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double get lastWeekIncome {
    return lastWeekTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  // ============ FILTER HARI INI ============
  double getTodayExpense() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _transactions.where((t) {
      final txDate =
          DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      return t.type == TransactionType.expense && txDate == today;
    }).fold<double>(0, (sum, t) => sum + t.amount);
  }

  double getTodayIncome() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _transactions.where((t) {
      final txDate =
          DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      return t.type == TransactionType.income && txDate == today;
    }).fold<double>(0, (sum, t) => sum + t.amount);
  }

  // ============ LIMIT HARIAN (dengan filter kategori) ============
  /// Get pengeluaran hari ini untuk kategori tertentu
  double getTodayExpenseByCategories(List<String> categoryIds) {
    if (categoryIds.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _transactions.where((t) {
      final txDate =
          DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      return t.type == TransactionType.expense &&
          txDate == today &&
          t.categoryId != null &&
          categoryIds.contains(t.categoryId);
    }).fold<double>(0, (sum, t) => sum + t.amount);
  }

  // ============ LIMIT WEEKEND (Sabtu-Minggu) ============
  /// Get pengeluaran weekend ini untuk kategori tertentu
  double getWeekendExpenseByCategories(List<String> categoryIds) {
    if (categoryIds.isEmpty) return 0;

    final now = DateTime.now();

    // Cari Sabtu minggu ini
    DateTime saturday;
    if (now.weekday == DateTime.saturday) {
      saturday = DateTime(now.year, now.month, now.day);
    } else if (now.weekday == DateTime.sunday) {
      saturday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
    } else {
      // Weekday - cari Sabtu kemarin atau Sabtu depan?
      // Kita pakai Sabtu minggu ini (yang akan datang atau sudah lewat)
      final daysUntilSaturday = DateTime.saturday - now.weekday;
      if (daysUntilSaturday > 0) {
        // Sabtu belum datang, pakai Sabtu minggu lalu
        saturday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday + 1));
      } else {
        saturday = DateTime(now.year, now.month, now.day)
            .add(Duration(days: daysUntilSaturday));
      }
    }

    final sunday = saturday.add(const Duration(days: 1));
    final mondayAfter = sunday.add(const Duration(days: 1));

    return _transactions.where((t) {
      final txDate =
          DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      return t.type == TransactionType.expense &&
          t.categoryId != null &&
          categoryIds.contains(t.categoryId) &&
          (txDate == saturday ||
              txDate == sunday ||
              (txDate.isAfter(saturday.subtract(const Duration(days: 1))) &&
                  txDate.isBefore(mondayAfter)));
    }).fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Get pengeluaran weekend saat ini (hanya jika hari ini weekend)
  double getCurrentWeekendExpenseByCategories(List<String> categoryIds) {
    if (categoryIds.isEmpty) return 0;

    final now = DateTime.now();

    // Hanya hitung jika hari ini Sabtu atau Minggu
    if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
      return 0;
    }

    // Cari Sabtu minggu ini
    DateTime saturday;
    if (now.weekday == DateTime.saturday) {
      saturday = DateTime(now.year, now.month, now.day);
    } else {
      // Minggu
      saturday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
    }

    final sunday = saturday.add(const Duration(days: 1));

    return _transactions.where((t) {
      final txDate =
          DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      return t.type == TransactionType.expense &&
          t.categoryId != null &&
          categoryIds.contains(t.categoryId) &&
          (txDate == saturday || txDate == sunday);
    }).fold<double>(0, (sum, t) => sum + t.amount);
  }

  // ============ ANALISIS ============
  Map<String, double> get expenseByCategory {
    final Map<String, double> result = {};

    for (final tx in thisMonthTransactions) {
      if (tx.type == TransactionType.expense && tx.categoryId != null) {
        result[tx.categoryId!] = (result[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    return result;
  }

  Map<int, double> get expenseByDayOfWeek {
    final Map<int, double> result = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (final tx in thisMonthTransactions) {
      if (tx.type == TransactionType.expense) {
        final dayOfWeek = tx.dateTime.weekday;
        result[dayOfWeek] = (result[dayOfWeek] ?? 0) + tx.amount;
      }
    }

    return result;
  }

  Map<String, double> get incomeByCategory {
    final Map<String, double> result = {};

    for (final tx in thisMonthTransactions) {
      if (tx.type == TransactionType.income && tx.categoryId != null) {
        result[tx.categoryId!] = (result[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    return result;
  }

  // ============ FILTER BY ============
  List<TransactionModel> getByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
          t.dateTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<TransactionModel> getByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  List<TransactionModel> getByWallet(String walletId) {
    return _transactions.where((t) => t.walletId == walletId).toList();
  }

  // ============ STATISTICS ============
  double get averageDailyExpense {
    if (thisMonthTransactions.isEmpty) return 0;
    final now = DateTime.now();
    return thisMonthExpense / now.day;
  }

  double get averageTransactionAmount {
    final expenses = thisMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    if (expenses.isEmpty) return 0;
    return expenses.fold<double>(0, (sum, t) => sum + t.amount) /
        expenses.length;
  }

  int get totalTransactionsThisMonth => thisMonthTransactions.length;

  // ============ INIT & CRUD ============
  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<TransactionModel>('transactions');
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions = _box.values.toList();
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
    _loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await transaction.save();
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _loadTransactions();
  }

  TransactionModel? getById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _box.clear();
    _loadTransactions();
  }
}

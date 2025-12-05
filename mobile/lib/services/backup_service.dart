import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/saving_goal.dart';
import '../models/budget.dart';
import '../models/recurring_transaction.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Export semua data ke file JSON
  Future<Map<String, dynamic>> exportToJson() async {
    final walletsBox = Hive.box<Wallet>('wallets');
    final transactionsBox = Hive.box<TransactionModel>('transactions');
    final categoriesBox = Hive.box<CategoryModel>('categories');
    final savingsBox = Hive.box<SavingGoal>('savings');
    final budgetsBox = Hive.box<Budget>('budgets');
    final recurringBox = Hive.box<RecurringTransaction>('recurring');
    final settingsBox = Hive.box('settings');

    return {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'wallets': walletsBox.values.map((w) => _walletToMap(w)).toList(),
      'transactions':
          transactionsBox.values.map((t) => _transactionToMap(t)).toList(),
      'categories': categoriesBox.values.map((c) => _categoryToMap(c)).toList(),
      'savings': savingsBox.values.map((s) => _savingToMap(s)).toList(),
      'budgets': budgetsBox.values.map((b) => _budgetToMap(b)).toList(),
      'recurring': recurringBox.values.map((r) => _recurringToMap(r)).toList(),
      'settings': {
        'isDarkMode': settingsBox.get('isDarkMode', defaultValue: false),
        'primaryColorValue': settingsBox.get('primaryColorValue',
            defaultValue: Colors.blue.value),
        'useBiometric': settingsBox.get('useBiometric', defaultValue: false),
      },
    };
  }

  /// Export dan simpan file
  Future<String?> exportAndSaveFile() async {
    try {
      final data = await exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Buat nama file dengan tanggal
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'money_report_backup_$dateStr.json';

      // Simpan ke folder Downloads/Documents
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  /// Export dan share file
  Future<bool> exportAndShare() async {
    try {
      final filePath = await exportAndSaveFile();
      if (filePath == null) return false;

      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Backup Money Report',
        subject: 'Money Report Backup',
      );

      return true;
    } catch (e) {
      debugPrint('Share error: $e');
      return false;
    }
  }

  /// Import data dari file JSON
  Future<ImportResult> importFromFile() async {
    try {
      // Pilih file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'Tidak ada file dipilih');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validasi versi
      if (!data.containsKey('version')) {
        return ImportResult(success: false, message: 'Format file tidak valid');
      }

      // Import data
      await _importData(data);

      return ImportResult(
        success: true,
        message: 'Import berhasil! ',
        stats: ImportStats(
          wallets: (data['wallets'] as List?)?.length ?? 0,
          transactions: (data['transactions'] as List?)?.length ?? 0,
          categories: (data['categories'] as List?)?.length ?? 0,
          savings: (data['savings'] as List?)?.length ?? 0,
          budgets: (data['budgets'] as List?)?.length ?? 0,
        ),
      );
    } catch (e) {
      debugPrint('Import error: $e');
      return ImportResult(success: false, message: 'Gagal import: $e');
    }
  }

  /// Import data ke Hive
  Future<void> _importData(Map<String, dynamic> data) async {
    // Clear existing data
    await Hive.box<Wallet>('wallets').clear();
    await Hive.box<TransactionModel>('transactions').clear();
    await Hive.box<CategoryModel>('categories').clear();
    await Hive.box<SavingGoal>('savings').clear();
    await Hive.box<Budget>('budgets').clear();
    await Hive.box<RecurringTransaction>('recurring').clear();

    // Import Wallets
    if (data['wallets'] != null) {
      final box = Hive.box<Wallet>('wallets');
      for (final item in data['wallets']) {
        final wallet = _mapToWallet(item);
        await box.put(wallet.id, wallet);
      }
    }

    // Import Transactions
    if (data['transactions'] != null) {
      final box = Hive.box<TransactionModel>('transactions');
      for (final item in data['transactions']) {
        final transaction = _mapToTransaction(item);
        await box.put(transaction.id, transaction);
      }
    }

    // Import Categories
    if (data['categories'] != null) {
      final box = Hive.box<CategoryModel>('categories');
      for (final item in data['categories']) {
        final category = _mapToCategory(item);
        await box.put(category.id, category);
      }
    }

    // Import Savings
    if (data['savings'] != null) {
      final box = Hive.box<SavingGoal>('savings');
      for (final item in data['savings']) {
        final saving = _mapToSaving(item);
        await box.put(saving.id, saving);
      }
    }

    // Import Budgets
    if (data['budgets'] != null) {
      final box = Hive.box<Budget>('budgets');
      for (final item in data['budgets']) {
        final budget = _mapToBudget(item);
        await box.put(budget.id, budget);
      }
    }

    // Import Recurring
    if (data['recurring'] != null) {
      final box = Hive.box<RecurringTransaction>('recurring');
      for (final item in data['recurring']) {
        final recurring = _mapToRecurring(item);
        await box.put(recurring.id, recurring);
      }
    }

    // Import Settings
    if (data['settings'] != null) {
      final box = Hive.box('settings');
      final settings = data['settings'] as Map<String, dynamic>;
      await box.put('isDarkMode', settings['isDarkMode'] ?? false);
      await box.put('primaryColorValue',
          settings['primaryColorValue'] ?? Colors.blue.value);
      await box.put('useBiometric', settings['useBiometric'] ?? false);
    }
  }

  // ============ WALLET CONVERTERS ============
  Map<String, dynamic> _walletToMap(Wallet w) => {
        'id': w.id,
        'name': w.name,
        'type': w.type.index,
        'balance': w.balance,
        'icon': w.icon,
        'createdAt': w.createdAt.toIso8601String(),
      };

  Wallet _mapToWallet(Map<String, dynamic> m) => Wallet(
        id: m['id'],
        name: m['name'],
        type: WalletType.values[m['type']],
        balance: (m['balance'] as num).toDouble(),
        icon: m['icon'],
        createdAt: DateTime.parse(m['createdAt']),
      );

  // ============ TRANSACTION CONVERTERS ============
  Map<String, dynamic> _transactionToMap(TransactionModel t) => {
        'id': t.id,
        'type': t.type.index,
        'walletId': t.walletId,
        'categoryId': t.categoryId,
        'amount': t.amount,
        'dateTime': t.dateTime.toIso8601String(),
        'note': t.note,
      };

  TransactionModel _mapToTransaction(Map<String, dynamic> m) =>
      TransactionModel(
        id: m['id'],
        type: TransactionType.values[m['type']],
        walletId: m['walletId'],
        categoryId: m['categoryId'],
        amount: (m['amount'] as num).toDouble(),
        dateTime: DateTime.parse(m['dateTime']),
        note: m['note'] ?? '',
      );

  // ============ CATEGORY CONVERTERS ============
  Map<String, dynamic> _categoryToMap(CategoryModel c) => {
        'id': c.id,
        'name': c.name,
        'icon': c.icon,
        'colorValue': c.colorValue,
        'isDefault': c.isDefault,
      };

  CategoryModel _mapToCategory(Map<String, dynamic> m) => CategoryModel(
        id: m['id'],
        name: m['name'],
        icon: m['icon'],
        colorValue: m['colorValue'],
        isDefault: m['isDefault'] ?? false,
      );

  // ============ SAVING CONVERTERS ============
  Map<String, dynamic> _savingToMap(SavingGoal s) => {
        'id': s.id,
        'name': s.name,
        'targetAmount': s.targetAmount,
        'currentAmount': s.currentAmount,
        'walletId': s.walletId,
        'createdAt': s.createdAt.toIso8601String(),
        'targetDate': s.targetDate?.toIso8601String(),
        'isCompleted': s.isCompleted,
      };

  SavingGoal _mapToSaving(Map<String, dynamic> m) => SavingGoal(
        id: m['id'],
        name: m['name'],
        targetAmount: (m['targetAmount'] as num).toDouble(),
        currentAmount: (m['currentAmount'] as num).toDouble(),
        walletId: m['walletId'],
        createdAt: DateTime.parse(m['createdAt']),
        targetDate:
            m['targetDate'] != null ? DateTime.parse(m['targetDate']) : null,
        isCompleted: m['isCompleted'] ?? false,
      );

  // ============ BUDGET CONVERTERS ============
  Map<String, dynamic> _budgetToMap(Budget b) => {
        'id': b.id,
        'categoryId': b.categoryId,
        'limitAmount': b.limitAmount,
        'month': b.month,
        'year': b.year,
      };

  Budget _mapToBudget(Map<String, dynamic> m) => Budget(
        id: m['id'],
        categoryId: m['categoryId'],
        limitAmount: (m['limitAmount'] as num).toDouble(),
        month: m['month'],
        year: m['year'],
      );

  // ============ RECURRING CONVERTERS ============
  Map<String, dynamic> _recurringToMap(RecurringTransaction r) => {
        'id': r.id,
        'name': r.name,
        'amount': r.amount,
        'isIncome': r.isIncome,
        'walletId': r.walletId,
        'categoryId': r.categoryId,
        'recurringType': r.recurringType.index,
        'dayOfMonth': r.dayOfMonth,
        'nextDueDate': r.nextDueDate.toIso8601String(),
        'isActive': r.isActive,
      };

  RecurringTransaction _mapToRecurring(Map<String, dynamic> m) =>
      RecurringTransaction(
        id: m['id'],
        name: m['name'],
        amount: (m['amount'] as num).toDouble(),
        isIncome: m['isIncome'],
        walletId: m['walletId'],
        categoryId: m['categoryId'],
        recurringType: RecurringType.values[m['recurringType']],
        dayOfMonth: m['dayOfMonth'],
        nextDueDate: DateTime.parse(m['nextDueDate']),
        isActive: m['isActive'] ?? true,
      );
}

class ImportResult {
  final bool success;
  final String message;
  final ImportStats? stats;

  ImportResult({
    required this.success,
    required this.message,
    this.stats,
  });
}

class ImportStats {
  final int wallets;
  final int transactions;
  final int categories;
  final int savings;
  final int budgets;

  ImportStats({
    required this.wallets,
    required this.transactions,
    required this.categories,
    required this.savings,
    required this.budgets,
  });
}

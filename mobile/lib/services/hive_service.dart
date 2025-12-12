import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/saving_goal.dart';
import '../models/recurring_transaction.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // Box Names
  static const String walletsBox = 'wallets';
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String savingsBox = 'savings';
  static const String recurringBox = 'recurring';
  static const String settingsBox = 'settings';

  // Boxes
  late Box<Wallet> _walletsBox;
  late Box<TransactionModel> _transactionsBox;
  late Box<CategoryModel> _categoriesBox;
  late Box<SavingGoal> _savingsBox;
  late Box<RecurringTransaction> _recurringBox;
  late Box _settingsBox;

  // Getters
  Box<Wallet> get wallets => _walletsBox;
  Box<TransactionModel> get transactions => _transactionsBox;
  Box<CategoryModel> get categories => _categoriesBox;
  Box<SavingGoal> get savings => _savingsBox;
  Box<RecurringTransaction> get recurring => _recurringBox;
  Box get settings => _settingsBox;

  /// Inisialisasi Hive dan semua Box
  Future<void> initialize() async {
    // Inisialisasi Hive Flutter
    await Hive.initFlutter();

    // Register semua Adapter
    _registerAdapters();

    // Buka semua Box
    await _openBoxes();
  }

  /// Register semua Hive Adapter
  void _registerAdapters() {
    // Wallet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WalletTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WalletAdapter());
    }

    // Transaction
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }

    // Category
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    // SavingGoal
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(SavingGoalAdapter());
    }

    // RecurringTransaction
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(RecurringTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(RecurringTransactionAdapter());
    }
  }

  /// Buka semua Box
  Future<void> _openBoxes() async {
    _walletsBox = await Hive.openBox<Wallet>(walletsBox);
    _transactionsBox = await Hive.openBox<TransactionModel>(transactionsBox);
    _categoriesBox = await Hive.openBox<CategoryModel>(categoriesBox);
    _savingsBox = await Hive.openBox<SavingGoal>(savingsBox);
    _recurringBox = await Hive.openBox<RecurringTransaction>(recurringBox);
    _settingsBox = await Hive.openBox(settingsBox);
  }

  /// Tutup semua Box
  Future<void> closeAll() async {
    await _walletsBox.close();
    await _transactionsBox.close();
    await _categoriesBox.close();
    await _savingsBox.close();
    await _recurringBox.close();
    await _settingsBox.close();
  }

  /// Hapus semua data
  Future<void> clearAll() async {
    await _walletsBox.clear();
    await _transactionsBox.clear();
    await _categoriesBox.clear();
    await _savingsBox.clear();
    await _recurringBox.clear();
    await _settingsBox.clear();
  }

  // ============================================
  // WALLET OPERATIONS
  // ============================================

  /// Tambah wallet baru
  Future<void> addWallet(Wallet wallet) async {
    await _walletsBox.put(wallet.id, wallet);
  }

  /// Update wallet
  Future<void> updateWallet(Wallet wallet) async {
    await wallet.save();
  }

  /// Hapus wallet
  Future<void> deleteWallet(String id) async {
    await _walletsBox.delete(id);
  }

  /// Ambil wallet berdasarkan ID
  Wallet? getWalletById(String id) {
    return _walletsBox.get(id);
  }

  /// Ambil semua wallet
  List<Wallet> getAllWallets() {
    return _walletsBox.values.toList();
  }

  /// Update saldo wallet
  Future<void> updateWalletBalance(String walletId, double amount) async {
    final wallet = getWalletById(walletId);
    if (wallet != null) {
      wallet.balance += amount;
      await wallet.save();
    }
  }

  // ============================================
  // TRANSACTION OPERATIONS
  // ============================================

  /// Tambah transaksi baru
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  /// Update transaksi
  Future<void> updateTransaction(TransactionModel transaction) async {
    await transaction.save();
  }

  /// Hapus transaksi
  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  /// Ambil transaksi berdasarkan ID
  TransactionModel? getTransactionById(String id) {
    return _transactionsBox.get(id);
  }

  /// Ambil semua transaksi
  List<TransactionModel> getAllTransactions() {
    final list = _transactionsBox.values.toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  /// Ambil transaksi berdasarkan wallet
  List<TransactionModel> getTransactionsByWallet(String walletId) {
    return _transactionsBox.values.where((t) => t.walletId == walletId).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Ambil transaksi berdasarkan kategori
  List<TransactionModel> getTransactionsByCategory(String categoryId) {
    return _transactionsBox.values
        .where((t) => t.categoryId == categoryId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Ambil transaksi berdasarkan rentang tanggal
  List<TransactionModel> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactionsBox.values.where((t) {
      return t.dateTime.isAfter(start) && t.dateTime.isBefore(end);
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Ambil transaksi bulan ini
  List<TransactionModel> getThisMonthTransactions() {
    final now = DateTime.now();
    final start =
        DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(start, end);
  }

  /// Ambil transaksi minggu ini
  List<TransactionModel> getThisWeekTransactions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));
    return getTransactionsByDateRange(
        start.subtract(const Duration(seconds: 1)), end);
  }

  // ============================================
  // CATEGORY OPERATIONS
  // ============================================

  /// Tambah kategori baru
  Future<void> addCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  /// Update kategori
  Future<void> updateCategory(CategoryModel category) async {
    await category.save();
  }

  /// Hapus kategori
  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  /// Ambil kategori berdasarkan ID
  CategoryModel? getCategoryById(String id) {
    return _categoriesBox.get(id);
  }

  /// Ambil semua kategori
  List<CategoryModel> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  /// Inisialisasi kategori default
  Future<void> initDefaultCategories() async {
    if (_categoriesBox.isEmpty) {
      final defaults = [
        CategoryModel(
          id: 'food',
          name: 'Makanan',
          icon: '🍔',
          colorValue: 0xFFFF6B6B,
          isDefault: true,
        ),
        CategoryModel(
          id: 'transport',
          name: 'Transportasi',
          icon: '🚗',
          colorValue: 0xFF4ECDC4,
          isDefault: true,
        ),
        CategoryModel(
          id: 'shopping',
          name: 'Belanja',
          icon: '🛍️',
          colorValue: 0xFFFFE66D,
          isDefault: true,
        ),
        CategoryModel(
          id: 'bills',
          name: 'Tagihan',
          icon: '📄',
          colorValue: 0xFF95E1D3,
          isDefault: true,
        ),
        CategoryModel(
          id: 'entertainment',
          name: 'Hiburan',
          icon: '🎮',
          colorValue: 0xFFDDA0DD,
          isDefault: true,
        ),
        CategoryModel(
          id: 'health',
          name: 'Kesehatan',
          icon: '💊',
          colorValue: 0xFF98D8C8,
          isDefault: true,
        ),
        CategoryModel(
          id: 'education',
          name: 'Pendidikan',
          icon: '📚',
          colorValue: 0xFFAED6F1,
          isDefault: true,
        ),
        CategoryModel(
          id: 'other',
          name: 'Lainnya',
          icon: '📦',
          colorValue: 0xFFD5DBDB,
          isDefault: true,
        ),
      ];

      for (var cat in defaults) {
        await addCategory(cat);
      }
    }
  }

  // ============================================
  // SAVING GOAL OPERATIONS
  // ============================================

  /// Tambah saving goal baru
  Future<void> addSavingGoal(SavingGoal saving) async {
    await _savingsBox.put(saving.id, saving);
  }

  /// Update saving goal
  Future<void> updateSavingGoal(SavingGoal saving) async {
    await saving.save();
  }

  /// Hapus saving goal
  Future<void> deleteSavingGoal(String id) async {
    await _savingsBox.delete(id);
  }

  /// Ambil saving goal berdasarkan ID
  SavingGoal? getSavingGoalById(String id) {
    return _savingsBox.get(id);
  }

  /// Ambil semua saving goals
  List<SavingGoal> getAllSavingGoals() {
    return _savingsBox.values.toList();
  }

  /// Ambil saving goals yang aktif
  List<SavingGoal> getActiveSavingGoals() {
    return _savingsBox.values.where((s) => !s.isCompleted).toList();
  }

  /// Tambah deposit ke saving goal
  Future<void> addDepositToSaving(String savingId, double amount) async {
    final saving = getSavingGoalById(savingId);
    if (saving != null) {
      saving.currentAmount += amount;
      if (saving.currentAmount >= saving.targetAmount) {
        saving.isCompleted = true;
      }
      await saving.save();
    }
  }

  // ============================================
  // RECURRING TRANSACTION OPERATIONS
  // ============================================

  /// Tambah recurring transaction baru
  Future<void> addRecurringTransaction(RecurringTransaction recurring) async {
    await _recurringBox.put(recurring.id, recurring);
  }

  /// Update recurring transaction
  Future<void> updateRecurringTransaction(
      RecurringTransaction recurring) async {
    await recurring.save();
  }

  /// Hapus recurring transaction
  Future<void> deleteRecurringTransaction(String id) async {
    await _recurringBox.delete(id);
  }

  /// Ambil recurring transaction berdasarkan ID
  RecurringTransaction? getRecurringTransactionById(String id) {
    return _recurringBox.get(id);
  }

  /// Ambil semua recurring transactions
  List<RecurringTransaction> getAllRecurringTransactions() {
    return _recurringBox.values.toList();
  }

  /// Ambil recurring transactions yang aktif
  List<RecurringTransaction> getActiveRecurringTransactions() {
    return _recurringBox.values.where((r) => r.isActive).toList();
  }

  /// Proses recurring transactions yang jatuh tempo
  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final activeRecurring = getActiveRecurringTransactions();

    for (var recurring in activeRecurring) {
      if (recurring.nextDueDate.isBefore(now) ||
          recurring.nextDueDate.isAtSameMomentAs(now)) {
        // Buat transaksi baru
        final transaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: recurring.isIncome
              ? TransactionType.income
              : TransactionType.expense,
          amount: recurring.amount,
          walletId: recurring.walletId,
          categoryId: recurring.categoryId,
          note: '${recurring.name} (Otomatis)',
          dateTime: now,
        );

        // Simpan transaksi
        await addTransaction(transaction);

        // Update saldo wallet
        final balanceChange =
            recurring.isIncome ? recurring.amount : -recurring.amount;
        await updateWalletBalance(recurring.walletId, balanceChange);

        // Hitung tanggal jatuh tempo berikutnya
        DateTime nextDue;
        switch (recurring.recurringType) {
          case RecurringType.daily:
            nextDue = recurring.nextDueDate.add(const Duration(days: 1));
            break;
          case RecurringType.weekly:
            nextDue = recurring.nextDueDate.add(const Duration(days: 7));
            break;
          case RecurringType.monthly:
            nextDue = DateTime(
              recurring.nextDueDate.year,
              recurring.nextDueDate.month + 1,
              recurring.dayOfMonth,
            );
            break;
          case RecurringType.yearly:
            nextDue = DateTime(
              recurring.nextDueDate.year + 1,
              recurring.nextDueDate.month,
              recurring.nextDueDate.day,
            );
            break;
        }

        // Update recurring transaction
        recurring.nextDueDate = nextDue;
        await recurring.save();
      }
    }
  }

  // ============================================
  // SETTINGS OPERATIONS
  // ============================================

  /// Simpan setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Ambil setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Hapus setting
  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // ============================================
  // ANALYTICS / STATISTICS
  // ============================================

  /// Hitung total saldo semua wallet
  double getTotalBalance() {
    return _walletsBox.values.fold(0, (sum, w) => sum + w.balance);
  }

  /// Hitung total pemasukan bulan ini
  double getThisMonthIncome() {
    return getThisMonthTransactions()
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Hitung total pengeluaran bulan ini
  double getThisMonthExpense() {
    return getThisMonthTransactions()
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Hitung total pengeluaran minggu ini
  double getThisWeekExpense() {
    return getThisWeekTransactions()
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Ambil pengeluaran per kategori bulan ini
  Map<String, double> getExpenseByCategory() {
    final map = <String, double>{};
    final transactions = getThisMonthTransactions()
        .where((t) => t.type == TransactionType.expense);

    for (var t in transactions) {
      final categoryId = t.categoryId ?? 'uncategorized';
      map[categoryId] = (map[categoryId] ?? 0) + t.amount;
    }

    return map;
  }

  /// Ambil pengeluaran per hari dalam seminggu
  Map<int, double> getExpenseByDayOfWeek() {
    final map = <int, double>{};
    final transactions =
        _transactionsBox.values.where((t) => t.type == TransactionType.expense);

    for (var t in transactions) {
      final day = t.dateTime.weekday;
      map[day] = (map[day] ?? 0) + t.amount;
    }

    return map;
  }

  /// Hitung penggunaan budget
  double getBudgetUsage(String categoryId, int month, int year) {
    return _transactionsBox.values
        .where((t) =>
            t.categoryId == categoryId &&
            t.type == TransactionType.expense &&
            t.dateTime.month == month &&
            t.dateTime.year == year)
        .fold(0, (sum, t) => sum + t.amount);
  }
}

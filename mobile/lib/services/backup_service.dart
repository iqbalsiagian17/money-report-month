import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

// Import semua models
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/saving_goal.dart';
import '../models/recurring_transaction.dart';
import '../models/user_profile.dart';
import '../models/todo.dart';
import '../models/custom_notification.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  static void restartApp() {
    SystemNavigator.pop();
  }
  // ============ ENSURE BOXES ARE OPEN ============

  Future<void> _ensureBoxesOpen() async {
    // Open boxes if not already open
    if (!Hive.isBoxOpen('wallets')) {
      await Hive.openBox<Wallet>('wallets');
    }
    if (!Hive.isBoxOpen('transactions')) {
      await Hive.openBox<TransactionModel>('transactions');
    }
    if (!Hive.isBoxOpen('categories')) {
      await Hive.openBox<CategoryModel>('categories');
    }
    if (!Hive.isBoxOpen('saving_goal')) {
      await Hive.openBox<SavingGoal>('saving_goal');
    }
    if (!Hive.isBoxOpen('recurring')) {
      await Hive.openBox<RecurringTransaction>('recurring');
    }
    if (!Hive.isBoxOpen('user_profile')) {
      await Hive.openBox<UserProfile>('user_profile');
    }
    if (!Hive.isBoxOpen('todo')) {
      await Hive.openBox<Todo>('todo');
    }
    if (!Hive.isBoxOpen('custom_notifications')) {
      await Hive.openBox<CustomNotification>('custom_notifications');
    }
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    if (!Hive.isBoxOpen('app_state')) {
      await Hive.openBox('app_state');
    }
  }

  // ============ STORAGE HELPERS ============

  Future<Directory?> _getPublicDownloadDirectory() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();

      final possiblePaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/sdcard/Download',
        '/sdcard/Downloads',
      ];

      for (final path in possiblePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          return dir;
        }
      }

      // Fallback:  create Dompetku folder
      final externalDir = Directory('/storage/emulated/0/Dompetku');
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }
      return externalDir;
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;

      final result = await Permission.storage.request();
      if (result.isGranted) return true;

      final manageResult = await Permission.manageExternalStorage.request();
      return manageResult.isGranted;
    }
    return true;
  }

  // ============ SAFE BOX GETTERS ============

  List<T> _safeGetBoxValues<T>(String boxName) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName).values.toList();
      }
    } catch (e) {
      debugPrint('Error getting values from $boxName: $e');
    }
    return [];
  }

  dynamic _safeGetSetting(String key, dynamic defaultValue) {
    try {
      if (Hive.isBoxOpen('settings')) {
        return Hive.box('settings').get(key, defaultValue: defaultValue);
      }
    } catch (e) {
      debugPrint('Error getting setting $key: $e');
    }
    return defaultValue;
  }

  // ============ EXPORT METHODS ============

  Future<Map<String, dynamic>> exportToJson() async {
    // Ensure all boxes are open first
    await _ensureBoxesOpen();

    // Get all data safely
    final wallets = _safeGetBoxValues<Wallet>('wallets');
    final transactions = _safeGetBoxValues<TransactionModel>('transactions');
    final categories = _safeGetBoxValues<CategoryModel>('categories');
    final savings = _safeGetBoxValues<SavingGoal>('saving_goal');
    final recurring = _safeGetBoxValues<RecurringTransaction>('recurring');
    final userProfiles = _safeGetBoxValues<UserProfile>('user_profile');
    final todos = _safeGetBoxValues<Todo>('todo');
    final notifications =
        _safeGetBoxValues<CustomNotification>('custom_notifications');

    return {
      'version': '2.0.0',
      'appName': 'Dompetku',
      'exportDate': DateTime.now().toIso8601String(),

      // All 8 Models
      'wallets': wallets.map((w) => _walletToMap(w)).toList(),
      'transactions': transactions.map((t) => _transactionToMap(t)).toList(),
      'categories': categories.map((c) => _categoryToMap(c)).toList(),
      'savings': savings.map((s) => _savingToMap(s)).toList(),
      'recurring': recurring.map((r) => _recurringToMap(r)).toList(),
      'userProfiles': userProfiles.map((u) => _userProfileToMap(u)).toList(),
      'todos': todos.map((t) => _todoToMap(t)).toList(),
      'notifications': notifications.map((n) => _notificationToMap(n)).toList(),

      // Settings
      'settings': {
        'isDarkMode': _safeGetSetting('isDarkMode', false),
        'primaryColorValue':
            _safeGetSetting('primaryColorValue', Colors.blue.value),
        'useBiometric': _safeGetSetting('useBiometric', false),
        'lockEnabled': _safeGetSetting('lockEnabled', false),
        'pin': _safeGetSetting('pin', ''),
      },

      // Stats
      'stats': {
        'totalWallets': wallets.length,
        'totalTransactions': transactions.length,
        'totalCategories': categories.length,
        'totalSavings': savings.length,
        'totalRecurring': recurring.length,
        'totalUserProfiles': userProfiles.length,
        'totalTodos': todos.length,
        'totalNotifications': notifications.length,
      },
    };
  }

  Future<BackupResult> exportAndSaveFile() async {
    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return BackupResult(
          success: false,
          message:
              'Izin penyimpanan ditolak.  Silakan berikan izin di pengaturan.',
        );
      }

      final data = await exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'dompetku_backup_$dateStr.json';

      final downloadDir = await _getPublicDownloadDirectory();

      if (downloadDir != null) {
        final file = File('${downloadDir.path}/$fileName');
        await file.writeAsString(jsonString);

        return BackupResult(
          success: true,
          message: 'Backup berhasil disimpan! ',
          filePath: file.path,
          fileName: fileName,
          stats: data['stats'] as Map<String, dynamic>?,
        );
      }

      return await _saveWithFilePicker(
          jsonString, fileName, data['stats'] as Map<String, dynamic>?);
    } catch (e) {
      debugPrint('Export error: $e');
      return BackupResult(
        success: false,
        message: 'Gagal membuat backup: $e',
      );
    }
  }

  Future<BackupResult> _saveWithFilePicker(
      String content, String fileName, Map<String, dynamic>? stats) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(content);

        return BackupResult(
          success: true,
          message: 'Backup berhasil disimpan!',
          filePath: result,
          fileName: fileName,
          stats: stats,
        );
      }

      return BackupResult(
        success: false,
        message: 'Penyimpanan dibatalkan',
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Gagal menyimpan file: $e',
      );
    }
  }

  Future<BackupResult> exportWithPicker() async {
    try {
      final data = await exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'dompetku_backup_$dateStr.json';

      return await _saveWithFilePicker(
          jsonString, fileName, data['stats'] as Map<String, dynamic>?);
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Gagal membuat backup: $e',
      );
    }
  }

  Future<bool> exportAndShare() async {
    try {
      final data = await exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'dompetku_backup_$dateStr.json';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Backup Dompetku - $dateStr',
        subject: 'Dompetku Backup',
      );

      return true;
    } catch (e) {
      debugPrint('Share error: $e');
      return false;
    }
  }

  // ============ IMPORT METHODS ============

  Future<ImportResult> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Pilih File Backup',
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'Tidak ada file dipilih');
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return ImportResult(success: false, message: 'Path file tidak valid');
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!data.containsKey('version')) {
        return ImportResult(success: false, message: 'Format file tidak valid');
      }

      await _importData(data);

      return ImportResult(
        success: true,
        message: 'Import berhasil! ',
        stats: ImportStats(
          wallets: (data['wallets'] as List?)?.length ?? 0,
          transactions: (data['transactions'] as List?)?.length ?? 0,
          categories: (data['categories'] as List?)?.length ?? 0,
          savings: (data['savings'] as List?)?.length ?? 0,
          recurring: (data['recurring'] as List?)?.length ?? 0,
          userProfiles: (data['userProfiles'] as List?)?.length ?? 0,
          todos: (data['todos'] as List?)?.length ?? 0,
          notifications: (data['notifications'] as List?)?.length ?? 0,
        ),
      );
    } catch (e) {
      debugPrint('Import error: $e');
      return ImportResult(success: false, message: 'Gagal import: $e');
    }
  }

  Future<void> _importData(Map<String, dynamic> data) async {
    // Ensure all boxes are open first
    await _ensureBoxesOpen();

    // Clear existing data safely
    await _safeClearBox<Wallet>('wallets');
    await _safeClearBox<TransactionModel>('transactions');
    await _safeClearBox<CategoryModel>('categories');
    await _safeClearBox<SavingGoal>('saving_goal');
    await _safeClearBox<RecurringTransaction>('recurring');
    await _safeClearBox<UserProfile>('user_profile');
    await _safeClearBox<Todo>('todo');
    await _safeClearBox<CustomNotification>('custom_notifications');

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
      final box = Hive.box<SavingGoal>('saving_goal');
      for (final item in data['savings']) {
        final saving = _mapToSaving(item);
        await box.put(saving.id, saving);
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

    // Import User Profiles
    if (data['userProfiles'] != null) {
      final box = Hive.box<UserProfile>('user_profile');
      for (final item in data['userProfiles']) {
        final profile = _mapToUserProfile(item);
        await box.add(profile);
      }
    }

    // Import Todos
    if (data['todos'] != null) {
      final box = Hive.box<Todo>('todo');
      for (final item in data['todos']) {
        final todo = _mapToTodo(item);
        await box.add(todo);
      }
    }

    // Import Notifications
    if (data['notifications'] != null) {
      final box = Hive.box<CustomNotification>('custom_notifications');
      for (final item in data['notifications']) {
        final notification = _mapToNotification(item);
        await box.put(notification.id, notification);
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
      await box.put('lockEnabled', settings['lockEnabled'] ?? false);
      if (settings['pin'] != null && settings['pin'].toString().isNotEmpty) {
        await box.put('pin', settings['pin']);
      }
    }

    // Mark as onboarded if user profile exists
    if (data['userProfiles'] != null &&
        (data['userProfiles'] as List).isNotEmpty) {
      final appState = Hive.box('app_state');
      await appState.put('has_onboarded', true);
    }
  }

  Future<void> _safeClearBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<T>(boxName).clear();
      }
    } catch (e) {
      debugPrint('Error clearing box $boxName: $e');
      // Try with untyped box
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        }
      } catch (e2) {
        debugPrint('Error clearing untyped box $boxName: $e2');
      }
    }
  }

  // ============================================================
  // WALLET CONVERTERS (typeId: 0 = WalletType, typeId: 1 = Wallet)
  // ============================================================
  Map<String, dynamic> _walletToMap(Wallet w) => {
        'id': w.id,
        'name': w.name,
        'type': w.type.index,
        'balance': w.balance,
        'icon': w.icon,
        'createdAt': w.createdAt.toIso8601String(),
        'excludeFromTotal': w.excludeFromTotal,
      };

  Wallet _mapToWallet(Map<String, dynamic> m) => Wallet(
        id: m['id'],
        name: m['name'],
        type: WalletType.values[m['type'] ?? 0],
        balance: (m['balance'] as num?)?.toDouble() ?? 0,
        icon: m['icon'],
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'])
            : DateTime.now(),
        excludeFromTotal: m['excludeFromTotal'] ?? false,
      );

  // ============================================================
  // TRANSACTION CONVERTERS (typeId: 2 = TransactionType, typeId: 3 = TransactionModel)
  // ============================================================
  Map<String, dynamic> _transactionToMap(TransactionModel t) => {
        'id': t.id,
        'type': t.type.index,
        'walletId': t.walletId,
        'categoryId': t.categoryId,
        'amount': t.amount,
        'dateTime': t.dateTime.toIso8601String(),
        'note': t.note,
        'toWalletId': t.toWalletId, // ✅ NEW
        'savingGoalId': t.savingGoalId, // ✅ NEW
      };

  TransactionModel _mapToTransaction(Map<String, dynamic> m) =>
      TransactionModel(
        id: m['id'],
        type: TransactionType.values[m['type'] ?? 0],
        walletId: m['walletId'],
        categoryId: m['categoryId'],
        amount: (m['amount'] as num?)?.toDouble() ?? 0,
        dateTime: m['dateTime'] != null
            ? DateTime.parse(m['dateTime'])
            : DateTime.now(),
        note: m['note'],
        toWalletId: m['toWalletId'], // ✅ NEW
        savingGoalId: m['savingGoalId'], // ✅ NEW
      );
  // ============================================================
  // CATEGORY CONVERTERS (typeId: 4)
  // ============================================================
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
        colorValue: m['colorValue'] ?? 0xFF2196F3,
        isDefault: m['isDefault'] ?? false,
      );

  // ============================================================
  // SAVING GOAL CONVERTERS (typeId: 5)
  // ============================================================
  Map<String, dynamic> _savingToMap(SavingGoal s) => {
        'id': s.id,
        'name': s.name,
        'targetAmount': s.targetAmount,
        'currentAmount': s.currentAmount,
        'targetWalletId':
            s.targetWalletId, // ✅ UPDATED: walletId → targetWalletId
        'createdAt': s.createdAt.toIso8601String(),
        'targetDate': s.targetDate?.toIso8601String(),
        'isCompleted': s.isCompleted,
      };

  SavingGoal _mapToSaving(Map<String, dynamic> m) => SavingGoal(
        id: m['id'],
        name: m['name'],
        targetAmount: (m['targetAmount'] as num?)?.toDouble() ?? 0,
        currentAmount: (m['currentAmount'] as num?)?.toDouble() ?? 0,
        // ✅ UPDATED: Support both old 'walletId' and new 'targetWalletId' for backward compatibility
        targetWalletId: m['targetWalletId'] ?? m['walletId'] ?? '',
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'])
            : DateTime.now(),
        targetDate:
            m['targetDate'] != null ? DateTime.parse(m['targetDate']) : null,
        isCompleted: m['isCompleted'] ?? false,
      );

  // ============================================================
  // RECURRING TRANSACTION CONVERTERS (typeId: 7 = RecurringType, typeId: 8)
  // ============================================================
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
        amount: (m['amount'] as num?)?.toDouble() ?? 0,
        isIncome: m['isIncome'] ?? false,
        walletId: m['walletId'],
        categoryId: m['categoryId'],
        recurringType: RecurringType.values[m['recurringType'] ?? 2],
        dayOfMonth: m['dayOfMonth'] ?? 1,
        nextDueDate: m['nextDueDate'] != null
            ? DateTime.parse(m['nextDueDate'])
            : DateTime.now(),
        isActive: m['isActive'] ?? true,
      );

  // ============================================================
  // USER PROFILE CONVERTERS (typeId: 10)
  // ============================================================
  Map<String, dynamic> _userProfileToMap(UserProfile u) => {
        'name': u.name,
        'photoPath': u.photoPath,
        'dailyLimit': u.dailyLimit,
        'isDailyLimitEnabled': u.isDailyLimitEnabled,
        'createdAt': u.createdAt.toIso8601String(),
        'weekendLimit': u.weekendLimit,
        'isWeekendLimitEnabled': u.isWeekendLimitEnabled,
        'dailyLimitCategories': u.dailyLimitCategories,
        'weekendLimitCategories': u.weekendLimitCategories,
        'unlimitedCategories': u.unlimitedCategories,
      };

  UserProfile _mapToUserProfile(Map<String, dynamic> m) => UserProfile(
        name: m['name'] ?? 'Pengguna',
        photoPath: m['photoPath'],
        dailyLimit: (m['dailyLimit'] as num?)?.toDouble() ?? 100000,
        isDailyLimitEnabled: m['isDailyLimitEnabled'] ?? false,
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'])
            : DateTime.now(),
        weekendLimit: (m['weekendLimit'] as num?)?.toDouble() ?? 300000,
        isWeekendLimitEnabled: m['isWeekendLimitEnabled'] ?? false,
        dailyLimitCategories:
            List<String>.from(m['dailyLimitCategories'] ?? []),
        weekendLimitCategories:
            List<String>.from(m['weekendLimitCategories'] ?? []),
        unlimitedCategories: List<String>.from(m['unlimitedCategories'] ?? []),
      );

  // ============================================================
  // CUSTOM NOTIFICATION CONVERTERS (typeId: 11)
  // ============================================================
  Map<String, dynamic> _notificationToMap(CustomNotification n) => {
        'id': n.id,
        'title': n.title,
        'message': n.message,
        'hour': n.hour,
        'minute': n.minute,
        'isEnabled': n.isEnabled,
        'isDefault': n.isDefault,
      };

  CustomNotification _mapToNotification(Map<String, dynamic> m) =>
      CustomNotification(
        id: m['id'],
        title: m['title'] ?? '',
        message: m['message'] ?? '',
        hour: m['hour'] ?? 9,
        minute: m['minute'] ?? 0,
        isEnabled: m['isEnabled'] ?? true,
        isDefault: m['isDefault'] ?? false,
      );

  // ============================================================
  // TODO CONVERTERS (typeId: 20)
  // ============================================================
  Map<String, dynamic> _todoToMap(Todo t) => {
        'title': t.title,
        'isCompleted': t.isCompleted,
        'createdAt': t.createdAt.toIso8601String(),
        'dueDate': t.dueDate?.toIso8601String(),
        'reminderTime': t.reminderTime?.toIso8601String(),
        'hasReminder': t.hasReminder,
        'notificationId': t.notificationId,
      };

  Todo _mapToTodo(Map<String, dynamic> m) => Todo(
        title: m['title'] ?? '',
        isCompleted: m['isCompleted'] ?? false,
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'])
            : DateTime.now(),
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
        reminderTime: m['reminderTime'] != null
            ? DateTime.parse(m['reminderTime'])
            : null,
        hasReminder: m['hasReminder'] ?? false,
        notificationId: m['notificationId'],
      );
}

// ============================================================
// RESULT CLASSES
// ============================================================
class BackupResult {
  final bool success;
  final String message;
  final String? filePath;
  final String? fileName;
  final Map<String, dynamic>? stats;

  BackupResult({
    required this.success,
    required this.message,
    this.filePath,
    this.fileName,
    this.stats,
  });
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
  final int recurring;
  final int userProfiles;
  final int todos;
  final int notifications;

  ImportStats({
    required this.wallets,
    required this.transactions,
    required this.categories,
    required this.savings,
    required this.recurring,
    required this.userProfiles,
    required this.todos,
    required this.notifications,
  });

  int get total =>
      wallets +
      transactions +
      categories +
      savings +
      recurring +
      userProfiles +
      todos +
      notifications;
}

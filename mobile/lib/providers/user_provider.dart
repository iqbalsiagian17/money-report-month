import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  Box<UserProfile>? _box;
  UserProfile? _profile;
  bool _isInitialized = false;

  // Getters
  UserProfile? get profile => _profile;
  bool get isInitialized => _isInitialized;
  String get userName => _profile?.name ?? 'Pengguna';

  // Daily Limit
  double get dailyLimit => _profile?.dailyLimit ?? 100000.0;
  bool get isDailyLimitEnabled => _profile?.isDailyLimitEnabled ?? false;
  List<String> get dailyLimitCategories => _profile?.dailyLimitCategories ?? [];

  // Weekend Limit
  double get weekendLimit => _profile?.weekendLimit ?? 300000.0;
  bool get isWeekendLimitEnabled => _profile?.isWeekendLimitEnabled ?? false;
  List<String> get weekendLimitCategories =>
      _profile?.weekendLimitCategories ?? [];

  // Unlimited Categories
  List<String> get unlimitedCategories => _profile?.unlimitedCategories ?? [];

  String? get photoPath => _profile?.photoPath;

  bool get hasPhoto =>
      _profile?.photoPath != null && _profile!.photoPath!.isNotEmpty;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = Hive.box<UserProfile>('user_profile');
      if (_box != null && _box!.isNotEmpty) {
        _profile = _box!.getAt(0);
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing UserProvider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _ensureProfileExists() async {
    if (_profile == null) {
      _profile = UserProfile(
        name: 'Pengguna',
        dailyLimit: 100000.0,
        isDailyLimitEnabled: false,
        weekendLimit: 300000.0,
        isWeekendLimitEnabled: false,
      );
      if (_box != null) {
        await _box!.add(_profile!);
      }
    }
  }

  // ============ PROFILE ============
  Future<void> setProfile({
    required String name,
    double? dailyLimit,
    bool? isDailyLimitEnabled,
    double? weekendLimit,
    bool? isWeekendLimitEnabled,
  }) async {
    await _ensureProfileExists();

    _profile!.name = name;
    if (dailyLimit != null) _profile!.dailyLimit = dailyLimit;
    if (isDailyLimitEnabled != null)
      _profile!.isDailyLimitEnabled = isDailyLimitEnabled;
    if (weekendLimit != null) _profile!.weekendLimit = weekendLimit;
    if (isWeekendLimitEnabled != null)
      _profile!.isWeekendLimitEnabled = isWeekendLimitEnabled;

    await _profile!.save();
    notifyListeners();
  }

  Future<void> setName(String name) async {
    await _ensureProfileExists();
    _profile!.name = name;
    await _profile!.save();
    notifyListeners();
  }

  // ============ DAILY LIMIT ============
  Future<void> setDailyLimit(double limit) async {
    await _ensureProfileExists();
    _profile!.dailyLimit = limit;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> toggleDailyLimit(bool enabled) async {
    await _ensureProfileExists();
    _profile!.isDailyLimitEnabled = enabled;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> setDailyLimitCategories(List<String> categoryIds) async {
    await _ensureProfileExists();
    _profile!.dailyLimitCategories = categoryIds;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> addDailyLimitCategory(String categoryId) async {
    await _ensureProfileExists();
    if (!_profile!.dailyLimitCategories.contains(categoryId)) {
      _profile!.dailyLimitCategories.add(categoryId);
      // Hapus dari kategori lain jika ada
      _profile!.weekendLimitCategories.remove(categoryId);
      _profile!.unlimitedCategories.remove(categoryId);
      await _profile!.save();
      notifyListeners();
    }
  }

  Future<void> removeDailyLimitCategory(String categoryId) async {
    await _ensureProfileExists();
    _profile!.dailyLimitCategories.remove(categoryId);
    await _profile!.save();
    notifyListeners();
  }

  // ============ WEEKEND LIMIT ============
  Future<void> setWeekendLimit(double limit) async {
    await _ensureProfileExists();
    _profile!.weekendLimit = limit;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> toggleWeekendLimit(bool enabled) async {
    await _ensureProfileExists();
    _profile!.isWeekendLimitEnabled = enabled;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> setWeekendLimitCategories(List<String> categoryIds) async {
    await _ensureProfileExists();
    _profile!.weekendLimitCategories = categoryIds;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> addWeekendLimitCategory(String categoryId) async {
    await _ensureProfileExists();
    if (!_profile!.weekendLimitCategories.contains(categoryId)) {
      _profile!.weekendLimitCategories.add(categoryId);
      // Hapus dari kategori lain jika ada
      _profile!.dailyLimitCategories.remove(categoryId);
      _profile!.unlimitedCategories.remove(categoryId);
      await _profile!.save();
      notifyListeners();
    }
  }

  Future<void> removeWeekendLimitCategory(String categoryId) async {
    await _ensureProfileExists();
    _profile!.weekendLimitCategories.remove(categoryId);
    await _profile!.save();
    notifyListeners();
  }

  // ============ UNLIMITED CATEGORIES ============
  Future<void> setUnlimitedCategories(List<String> categoryIds) async {
    await _ensureProfileExists();
    _profile!.unlimitedCategories = categoryIds;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> addUnlimitedCategory(String categoryId) async {
    await _ensureProfileExists();
    if (!_profile!.unlimitedCategories.contains(categoryId)) {
      _profile!.unlimitedCategories.add(categoryId);
      // Hapus dari kategori lain jika ada
      _profile!.dailyLimitCategories.remove(categoryId);
      _profile!.weekendLimitCategories.remove(categoryId);
      await _profile!.save();
      notifyListeners();
    }
  }

  Future<void> removeUnlimitedCategory(String categoryId) async {
    await _ensureProfileExists();
    _profile!.unlimitedCategories.remove(categoryId);
    await _profile!.save();
    notifyListeners();
  }

  Future<void> setPhotoPath(String? path) async {
    await _ensureProfileExists();
    _profile!.photoPath = path;
    await _profile!.save();
    notifyListeners();
  }

  Future<void> removePhoto() async {
    await _ensureProfileExists();
    _profile!.photoPath = null;
    await _profile!.save();
    notifyListeners();
  }

  // ============ HELPER METHODS ============

  /// Cek apakah kategori termasuk limit harian
  bool isCategoryDailyLimited(String categoryId) {
    return dailyLimitCategories.contains(categoryId);
  }

  /// Cek apakah kategori termasuk limit weekend
  bool isCategoryWeekendLimited(String categoryId) {
    return weekendLimitCategories.contains(categoryId);
  }

  /// Cek apakah kategori unlimited
  bool isCategoryUnlimited(String categoryId) {
    return unlimitedCategories.contains(categoryId);
  }

  /// Cek apakah hari ini weekend (Sabtu/Minggu)
  bool isWeekend() {
    final now = DateTime.now();
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  /// Get limit type untuk kategori tertentu
  /// Returns: 'daily', 'weekend', 'unlimited', atau 'none' (belum diatur)
  String getLimitTypeForCategory(String categoryId) {
    if (dailyLimitCategories.contains(categoryId)) return 'daily';
    if (weekendLimitCategories.contains(categoryId)) return 'weekend';
    if (unlimitedCategories.contains(categoryId)) return 'unlimited';
    return 'none';
  }

  // Reset profile
  Future<void> resetProfile() async {
    if (_box != null) {
      await _box!.clear();
    }
    _profile = null;
    notifyListeners();
  }
}

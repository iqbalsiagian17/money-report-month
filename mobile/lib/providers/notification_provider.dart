import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/custom_notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  late Box<CustomNotification> _box;
  List<CustomNotification> _notifications = [];
  bool _isInitialized = false;

  List<CustomNotification> get notifications => _notifications;
  List<CustomNotification> get defaultNotifications =>
      _notifications.where((n) => n.isDefault).toList();
  List<CustomNotification> get customNotifications =>
      _notifications.where((n) => !n.isDefault).toList();
  bool get isInitialized => _isInitialized;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = Hive.box<CustomNotification>('custom_notifications');

      // Initialize default notifications if empty
      if (_box.isEmpty) {
        await _initDefaultNotifications();
      }

      _loadNotifications();

      // Schedule all notifications
      await _rescheduleAllNotifications();

      _isInitialized = true;
      debugPrint(
          '✅ NotificationProvider initialized with ${_notifications.length} notifications');
    } catch (e) {
      debugPrint('❌ NotificationProvider init error: $e');
      _isInitialized = true;
    }
  }

  Future<void> _initDefaultNotifications() async {
    final defaults = [
      CustomNotification(
        id: 'default_1',
        title: '🌅 Pengingat Pagi',
        message:
            'Selamat pagi {nama}! Jangan lupa catat pengeluaran sarapan 🍳',
        hour: 10,
        minute: 0,
        isDefault: true,
        isEnabled: true,
      ),
      CustomNotification(
        id: 'default_2',
        title: '☀️ Pengingat Siang',
        message: 'Hai {nama}! Sudah makan siang? Catat pengeluaranmu 🍱',
        hour: 13,
        minute: 0,
        isDefault: true,
        isEnabled: true,
      ),
      CustomNotification(
        id: 'default_3',
        title: '🌆 Pengingat Sore',
        message: 'Sore {nama}! Ada pengeluaran yang belum dicatat? 📝',
        hour: 17,
        minute: 0,
        isDefault: true,
        isEnabled: true,
      ),
      CustomNotification(
        id: 'default_4',
        title: '🌙 Pengingat Malam',
        message: 'Malam {nama}! Yuk review keuangan hari ini 💰',
        hour: 20,
        minute: 0,
        isDefault: true,
        isEnabled: true,
      ),
    ];

    for (final notif in defaults) {
      await _box.put(notif.id, notif);
    }

    debugPrint('✅ Default notifications created');
  }

  void _loadNotifications() {
    _notifications = _box.values.toList();

    // Sort by time
    _notifications.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });

    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required int hour,
    required int minute,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final notif = CustomNotification(
      id: id,
      title: title,
      message: message,
      hour: hour,
      minute: minute,
      isDefault: false,
      isEnabled: true,
    );

    await _box.put(id, notif);
    _loadNotifications();
    await _rescheduleAllNotifications();

    debugPrint('✅ Added notification: $title at $hour:$minute');
  }

  Future<void> updateNotification(CustomNotification notif) async {
    await notif.save();
    _loadNotifications();
    await _rescheduleAllNotifications();

    debugPrint('✅ Updated notification: ${notif.title}');
  }

  Future<void> deleteNotification(String id) async {
    final notif = _box.get(id);
    if (notif != null && !notif.isDefault) {
      await _box.delete(id);
      _loadNotifications();
      await _rescheduleAllNotifications();

      debugPrint('✅ Deleted notification: ${notif.title}');
    }
  }

  Future<void> toggleNotification(String id, bool enabled) async {
    final notif = _box.get(id);
    if (notif != null) {
      notif.isEnabled = enabled;
      await notif.save();
      _loadNotifications();
      await _rescheduleAllNotifications();

      debugPrint(
          '✅ Toggled notification: ${notif.title} -> ${enabled ? "ON" : "OFF"}');
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    try {
      // Cancel all existing
      await NotificationService().cancelAll();

      // Get only enabled notifications
      final enabledNotifications =
          _notifications.where((n) => n.isEnabled).toList();

      // Schedule them
      await NotificationService()
          .scheduleCustomNotifications(enabledNotifications);

      // Debug: print pending
      await NotificationService().debugPrintPendingNotifications();
    } catch (e) {
      debugPrint('❌ Error rescheduling notifications: $e');
    }
  }

  Future<void> refreshNotifications() async {
    _loadNotifications();
    await _rescheduleAllNotifications();
  }

  /// Test notification instantly
  Future<void> testNotification() async {
    await NotificationService().testNotification();
  }
}

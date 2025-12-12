import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/custom_notification.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  late Box<CustomNotification> _box;
  List<CustomNotification> _notifications = [];

  List<CustomNotification> get notifications => _notifications;
  List<CustomNotification> get defaultNotifications =>
      _notifications.where((n) => n.isDefault).toList();
  List<CustomNotification> get customNotifications =>
      _notifications.where((n) => !n.isDefault).toList();

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<CustomNotification>('custom_notifications');

    // Inisialisasi notifikasi wajib jika belum ada
    if (_box.isEmpty) {
      await _initDefaultNotifications();
    }

    _loadNotifications();
  }

  Future<void> _initDefaultNotifications() async {
    final defaults = [
      CustomNotification(
        id: 'default_1',
        title: 'Pengingat Pagi',
        message: 'Selamat pagi!  Jangan lupa catat pengeluaran sarapan 🍳',
        hour: 10,
        minute: 0,
        isDefault: true,
      ),
      CustomNotification(
        id: 'default_2',
        title: 'Pengingat Siang',
        message: 'Sudah makan siang? Catat pengeluaranmu!  🍱',
        hour: 13,
        minute: 0,
        isDefault: true,
      ),
      CustomNotification(
        id: 'default_3',
        title: 'Pengingat Sore',
        message: 'Sore!  Ada pengeluaran yang belum dicatat?  📝',
        hour: 17,
        minute: 0,
        isDefault: true,
      ),
      CustomNotification(
        id: 'default_4',
        title: 'Pengingat Malam',
        message: 'Malam! Yuk review keuangan hari ini 💰',
        hour: 20,
        minute: 0,
        isDefault: true,
      ),
    ];

    for (final notif in defaults) {
      await _box.put(notif.id, notif);
    }
  }

  void _loadNotifications() {
    _notifications = _box.values.toList();
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
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notif = CustomNotification(
      id: id,
      title: title,
      message: message,
      hour: hour,
      minute: minute,
      isDefault: false,
    );
    await _box.put(id, notif);
    _loadNotifications();
    await _rescheduleAllNotifications();
  }

  Future<void> updateNotification(CustomNotification notif) async {
    await notif.save();
    _loadNotifications();
    await _rescheduleAllNotifications();
  }

  Future<void> deleteNotification(String id) async {
    final notif = _box.get(id);
    if (notif != null && !notif.isDefault) {
      await _box.delete(id);
      _loadNotifications();
      await _rescheduleAllNotifications();
    }
  }

  Future<void> toggleNotification(String id, bool enabled) async {
    final notif = _box.get(id);
    if (notif != null) {
      notif.isEnabled = enabled;
      await notif.save();
      _loadNotifications();
      await _rescheduleAllNotifications();
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    await NotificationService().cancelAll();
    await NotificationService().scheduleCustomNotifications(_notifications);
  }

  Future<void> refreshNotifications() async {
    await _rescheduleAllNotifications();
  }
}

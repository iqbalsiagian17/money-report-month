import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/custom_notification.dart';
import '../models/todo.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  String _userName = 'Pengguna';

  void setUserName(String name) {
    _userName = name;
  }

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // ============ TODO REMINDER NOTIFICATIONS ============

  /// Schedule a reminder for a specific Todo
  Future<int> scheduleTodoReminder({
    required Todo todo,
    required DateTime reminderTime,
  }) async {
    // Generate unique notification ID
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const androidDetails = AndroidNotificationDetails(
      'todo_reminder_channel',
      'Todo Reminders',
      channelDescription: 'Pengingat untuk tugas To-Do',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE91E63),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        notificationId,
        '📋 Pengingat Tugas',
        'Hai $_userName!  Jangan lupa:  ${todo.title}',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint(
          'Todo reminder scheduled:  ID=$notificationId, Time=$reminderTime');
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling todo reminder:  $e');
      return -1;
    }
  }

  /// Cancel a specific todo reminder
  Future<void> cancelTodoReminder(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
      debugPrint('Todo reminder cancelled:  ID=$notificationId');
    } catch (e) {
      debugPrint('Error cancelling todo reminder: $e');
    }
  }

  /// Show instant notification for todo due today
  Future<void> showTodoDueNotification(Todo todo) async {
    await showInstantNotification(
      title: '⏰ Tugas Jatuh Tempo Hari Ini',
      body: 'Hai $_userName!  Tugas "${todo.title}" jatuh tempo hari ini.',
    );
  }

  /// Show instant notification for overdue todo
  Future<void> showTodoOverdueNotification(Todo todo) async {
    await showInstantNotification(
      title: '🚨 Tugas Terlambat! ',
      body: 'Hai $_userName! Tugas "${todo.title}" sudah melewati batas waktu.',
    );
  }

  // ============ SCHEDULE DAILY REMINDERS (DEFAULT) ============
  Future<void> scheduleDailyReminders() async {
    // Cancel existing first
    await cancelAll();

    // Schedule default reminders
    final defaultReminders = [
      {
        'id': 1,
        'hour': 10,
        'minute': 0,
        'title': 'Pengingat Pagi',
        'body':
            'Selamat pagi $_userName! Jangan lupa catat pengeluaran sarapan 🍳'
      },
      {
        'id': 2,
        'hour': 13,
        'minute': 0,
        'title': 'Pengingat Siang',
        'body': 'Hai $_userName! Sudah makan siang? Catat pengeluaranmu 🍱'
      },
      {
        'id': 3,
        'hour': 17,
        'minute': 0,
        'title': 'Pengingat Sore',
        'body': 'Sore $_userName! Ada pengeluaran yang belum dicatat? 📝'
      },
      {
        'id': 4,
        'hour': 20,
        'minute': 0,
        'title': 'Pengingat Malam',
        'body': 'Malam $_userName!  Yuk review keuangan hari ini 💰'
      },
    ];

    for (final reminder in defaultReminders) {
      await _scheduleDaily(
        id: reminder['id'] as int,
        hour: reminder['hour'] as int,
        minute: reminder['minute'] as int,
        title: reminder['title'] as String,
        body: reminder['body'] as String,
      );
    }
  }

  // ============ INSTANT NOTIFICATION ============
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'money_report_channel',
      'Dompetku Notifications',
      channelDescription: 'Notifikasi untuk Dompetku',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body.replaceAll('{nama}', _userName),
      details,
    );
  }

  // ============ SCHEDULE CUSTOM NOTIFICATIONS ============
  Future<void> scheduleCustomNotifications(
      List<CustomNotification> notifs) async {
    for (int i = 0; i < notifs.length; i++) {
      final notif = notifs[i];
      if (notif.isEnabled) {
        await _scheduleDaily(
          id: i + 100, // Offset ID untuk custom notifications
          hour: notif.hour,
          minute: notif.minute,
          title: notif.title.replaceAll('{nama}', _userName),
          body: notif.message.replaceAll('{nama}', _userName),
        );
      }
    }
  }

  // ============ INTERNAL: SCHEDULE DAILY ============
  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Pengingat harian untuk mencatat keuangan',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // ============ DAILY LIMIT NOTIFICATIONS ============
  Future<void> showDailyLimitWarning({
    required double spent,
    required double limit,
  }) async {
    final percentage = (spent / limit * 100).round();

    await showInstantNotification(
      title: 'Peringatan Limit Harian!  ⚠️',
      body:
          'Hai $_userName, pengeluaranmu sudah $percentage% dari limit harian.',
    );
  }

  Future<void> showDailyLimitExceeded({
    required double spent,
    required double limit,
  }) async {
    await showInstantNotification(
      title: 'Limit Harian Terlampaui! 🚨',
      body:
          'Hai $_userName, kamu sudah melebihi limit harian.  Gunakan mode darurat jika perlu.',
    );
  }

  // ============ BUDGET WARNING ============
  Future<void> showBudgetWarning(String categoryName, int percentage) async {
    await showInstantNotification(
      title: 'Peringatan Budget!  ⚠️',
      body: 'Hai $_userName, budget $categoryName sudah terpakai $percentage%',
    );
  }

  // ============ CANCEL ALL ============
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // ============ CANCEL BY ID ============
  Future<void> cancelById(int id) async {
    await _notifications.cancel(id);
  }
}

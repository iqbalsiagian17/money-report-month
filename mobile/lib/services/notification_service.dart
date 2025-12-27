import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:hive/hive.dart';
import '../models/custom_notification.dart';
import '../models/todo.dart';
import '../models/user_profile.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Custom sound settings
  static const String _customSoundName = 'mario_ring';

  String get _userName {
    try {
      final box = Hive.box<UserProfile>('user_profile');
      if (box.isNotEmpty) {
        return box.getAt(0)?.name ?? 'Pengguna';
      }
    } catch (e) {
      debugPrint('Error getting username: $e');
    }
    return 'Pengguna';
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

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

      final initialized = await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('Notification initialized: $initialized');

      // Create notification channels with custom sound
      await _createNotificationChannels();

      await _requestPermissions();
      _isInitialized = true;

      debugPrint('NotificationService fully initialized with custom sound');
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Create notification channels with custom sound
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Daily reminder channel with custom sound
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminder_channel',
          'Daily Reminders',
          description: 'Pengingat harian untuk mencatat keuangan',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(_customSoundName),
          playSound: true,
          enableVibration: true,
        ),
      );

      // Todo reminder channel with custom sound
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'todo_reminder_channel',
          'Todo Reminders',
          description: 'Pengingat untuk tugas To-Do',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(_customSoundName),
          playSound: true,
          enableVibration: true,
        ),
      );

      // Instant notification channel with custom sound
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'instant_channel',
          'Instant Notifications',
          description: 'Notifikasi langsung',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(_customSoundName),
          playSound: true,
          enableVibration: true,
        ),
      );

      debugPrint(
          '✅ Notification channels created with custom sound:  $_customSoundName');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> _requestPermissions() async {
    try {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final notifPermission =
            await androidPlugin.requestNotificationsPermission();
        debugPrint('Notification permission:  $notifPermission');

        final exactAlarmPermission =
            await androidPlugin.requestExactAlarmsPermission();
        debugPrint('Exact alarm permission:  $exactAlarmPermission');
      }

      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  String _replacePlaceholders(String text) {
    return text
        .replaceAll('{nama}', _userName)
        .replaceAll('{user}', _userName)
        .replaceAll('{name}', _userName);
  }

  // ============ ANDROID NOTIFICATION DETAILS WITH CUSTOM SOUND ============

  AndroidNotificationDetails _getDailyReminderDetails() {
    return const AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Pengingat harian untuk mencatat keuangan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound(_customSoundName),
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
    );
  }

  AndroidNotificationDetails _getTodoReminderDetails() {
    return const AndroidNotificationDetails(
      'todo_reminder_channel',
      'Todo Reminders',
      channelDescription: 'Pengingat untuk tugas To-Do',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE91E63),
      sound: RawResourceAndroidNotificationSound(_customSoundName),
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
    );
  }

  AndroidNotificationDetails _getInstantNotificationDetails() {
    return const AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Notifikasi langsung',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound(_customSoundName),
      playSound: true,
      enableVibration: true,
    );
  }

  // ============ TODO REMINDER NOTIFICATIONS ============

  Future<int> scheduleTodoReminder({
    required Todo todo,
    required DateTime reminderTime,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationId = todo.hashCode.abs() % 100000;

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'mario_ring.mp3', // iOS custom sound
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: _getTodoReminderDetails(),
      iOS: iosDetails,
    );

    try {
      final scheduledTime = tz.TZDateTime.from(reminderTime, tz.local);

      if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notifications.zonedSchedule(
          notificationId,
          '📋 Pengingat Tugas',
          _replacePlaceholders('Hai {nama}! Jangan lupa:  ${todo.title}'),
          scheduledTime,
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        debugPrint(
            '✅ Todo reminder scheduled:  ID=$notificationId, Time=$scheduledTime');
        return notificationId;
      } else {
        debugPrint('⚠️ Reminder time is in the past, not scheduling');
        return -1;
      }
    } catch (e) {
      debugPrint('❌ Error scheduling todo reminder: $e');
      return -1;
    }
  }

  Future<void> cancelTodoReminder(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
      debugPrint('✅ Todo reminder cancelled: ID=$notificationId');
    } catch (e) {
      debugPrint('❌ Error cancelling todo reminder: $e');
    }
  }

  Future<void> showTodoDueNotification(Todo todo) async {
    await showInstantNotification(
      title: '⏰ Tugas Jatuh Tempo Hari Ini',
      body: 'Hai $_userName! Tugas "${todo.title}" jatuh tempo hari ini.',
    );
  }

  Future<void> showTodoOverdueNotification(Todo todo) async {
    await showInstantNotification(
      title: '🚨 Tugas Terlambat! ',
      body: 'Hai $_userName! Tugas "${todo.title}" sudah melewati batas waktu.',
    );
  }

  // ============ INSTANT NOTIFICATION ============

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'mario_ring.mp3', // iOS custom sound
    );

    final details = NotificationDetails(
      android: _getInstantNotificationDetails(),
      iOS: iosDetails,
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    try {
      await _notifications.show(
        notificationId,
        _replacePlaceholders(title),
        _replacePlaceholders(body),
        details,
        payload: payload,
      );
      debugPrint('✅ Instant notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error showing instant notification: $e');
    }
  }

  // ============ SCHEDULE DAILY REMINDERS ============

  Future<void> scheduleDailyReminders() async {
    if (!_isInitialized) await initialize();

    await cancelAll();

    final defaultReminders = [
      {
        'id': 1,
        'hour': 10,
        'minute': 0,
        'title': '🌅 Pengingat Pagi',
        'body': 'Selamat pagi {nama}! Jangan lupa catat pengeluaran sarapan 🍳'
      },
      {
        'id': 2,
        'hour': 13,
        'minute': 0,
        'title': '☀️ Pengingat Siang',
        'body': 'Hai {nama}! Sudah makan siang? Catat pengeluaranmu 🍱'
      },
      {
        'id': 3,
        'hour': 17,
        'minute': 0,
        'title': '🌆 Pengingat Sore',
        'body': 'Sore {nama}! Ada pengeluaran yang belum dicatat?  📝'
      },
      {
        'id': 4,
        'hour': 20,
        'minute': 0,
        'title': '🌙 Pengingat Malam',
        'body': 'Malam {nama}! Yuk review keuangan hari ini 💰'
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

  // ============ SCHEDULE CUSTOM NOTIFICATIONS ============

  Future<void> scheduleCustomNotifications(
      List<CustomNotification> notifs) async {
    if (!_isInitialized) await initialize();

    debugPrint('📅 Scheduling ${notifs.length} custom notifications');

    for (int i = 0; i < notifs.length; i++) {
      final notif = notifs[i];

      if (notif.isEnabled) {
        final notifId = 100 + i;

        await _scheduleDaily(
          id: notifId,
          hour: notif.hour,
          minute: notif.minute,
          title: notif.title,
          body: notif.message,
        );

        debugPrint(
            '✅ Scheduled:  "${notif.title}" at ${notif.hour}:${notif.minute}');
      } else {
        debugPrint('⏭️ Skipped (disabled): "${notif.title}"');
      }
    }
  }

  // ============ INTERNAL:  SCHEDULE DAILY ============

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'mario_ring.mp3', // iOS custom sound
    );

    final details = NotificationDetails(
      android: _getDailyReminderDetails(),
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        _replacePlaceholders(title),
        _replacePlaceholders(body),
        scheduledDate,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('✅ Daily notification scheduled: ID=$id, Time=$hour:$minute');
    } catch (e) {
      debugPrint('❌ Error scheduling daily notification: $e');
    }
  }

  // ============ DAILY LIMIT NOTIFICATIONS ============

  Future<void> showDailyLimitWarning({
    required double spent,
    required double limit,
  }) async {
    final percentage = (spent / limit * 100).round();
    await showInstantNotification(
      title: '⚠️ Peringatan Limit Harian! ',
      body:
          'Hai $_userName, pengeluaranmu sudah $percentage% dari limit harian.',
    );
  }

  Future<void> showDailyLimitExceeded({
    required double spent,
    required double limit,
  }) async {
    await showInstantNotification(
      title: '🚨 Limit Harian Terlampaui!',
      body: 'Hai $_userName, kamu sudah melebihi limit harian.  Hati-hati ya!',
    );
  }

  // ============ BUDGET WARNING ============

  Future<void> showBudgetWarning(String categoryName, int percentage) async {
    await showInstantNotification(
      title: '⚠️ Peringatan Budget!',
      body: 'Hai $_userName, budget $categoryName sudah terpakai $percentage%',
    );
  }

  // ============ CANCEL ============

  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  Future<void> cancelById(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('✅ Notification $id cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling notification $id: $e');
    }
  }

  // ============ DEBUG ============

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> debugPrintPendingNotifications() async {
    final pending = await getPendingNotifications();
    debugPrint('📋 Pending notifications: ${pending.length}');
    for (final notif in pending) {
      debugPrint('  - ID: ${notif.id}, Title: ${notif.title}');
    }
  }

  Future<void> testNotification() async {
    await showInstantNotification(
      title: '🔔 Test Notifikasi',
      body:
          'Hai $_userName! Ini adalah test notifikasi dengan sound Mario!  🎮',
    );
  }
}

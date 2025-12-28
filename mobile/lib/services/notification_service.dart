import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // Custom sound - TANPA ekstensi . mp3
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

      debugPrint('✅ Notification initialized:  $initialized');

      // PENTING: Buat channel dengan custom sound
      await _createNotificationChannels();
      await _requestPermissions();

      _isInitialized = true;

      debugPrint('✅ NotificationService fully initialized');
    } catch (e) {
      debugPrint('❌ NotificationService init error: $e');
    }
  }

  /// Create notification channels with CUSTOM SOUND
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // PENTING: Channel ID harus UNIK jika ingin ganti sound
      // Jika channel sudah ada dengan sound lama, harus uninstall app dulu
      // atau pakai channel ID baru

      // Channel untuk daily reminder dengan custom sound
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminder_v2', // Ganti ID agar channel baru dibuat
          'Pengingat Harian',
          description: 'Pengingat harian untuk mencatat keuangan',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(_customSoundName),
          playSound: true,
          enableVibration: true,
        ),
      );

      // Channel untuk instant notification dengan custom sound
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'instant_v2', // Ganti ID agar channel baru dibuat
          'Notifikasi Langsung',
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

  Future<bool> _requestPermissions() async {
    try {
      final notifStatus = await Permission.notification.request();
      debugPrint('📱 Notification permission: $notifStatus');

      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final exactAlarm = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('⏰ Exact alarm permission: $exactAlarm');

        final notifPermission =
            await androidPlugin.requestNotificationsPermission();
        debugPrint('🔔 Plugin notification permission: $notifPermission');
      }

      return notifStatus.isGranted;
    } catch (e) {
      debugPrint('❌ Permission request error: $e');
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  String _replacePlaceholders(String text) {
    return text
        .replaceAll('{nama}', _userName)
        .replaceAll('{user}', _userName)
        .replaceAll('{name}', _userName);
  }

  // ============ NOTIFICATION DETAILS WITH CUSTOM SOUND ============

  NotificationDetails _getNotificationDetails({bool isInstant = false}) {
    final androidDetails = AndroidNotificationDetails(
      isInstant ? 'instant_v2' : 'daily_reminder_v2', // Pakai channel ID baru
      isInstant ? 'Notifikasi Langsung' : 'Pengingat Harian',
      channelDescription: isInstant
          ? 'Notifikasi langsung'
          : 'Pengingat harian untuk mencatat keuangan',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      // Custom sound
      sound: const RawResourceAndroidNotificationSound(_customSoundName),
      playSound: true,
      enableVibration: true,
    );

    // iOS custom sound (file harus ada di iOS bundle)
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Untuk iOS, file harus bernama mario_ring.aiff atau mario_ring.caf
      // dan ada di Runner/Resources
      // sound: 'mario_ring. aiff',
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // ============ INSTANT NOTIFICATION ============

  Future<bool> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    final hasPermission = await areNotificationsEnabled();
    if (!hasPermission) {
      debugPrint('❌ Notification permission not granted! ');
      return false;
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    try {
      await _notifications.show(
        notificationId,
        _replacePlaceholders(title),
        _replacePlaceholders(body),
        _getNotificationDetails(isInstant: true),
        payload: payload,
      );
      debugPrint('✅ Instant notification shown: $title (ID: $notificationId)');
      return true;
    } catch (e) {
      debugPrint('❌ Error showing instant notification: $e');
      return false;
    }
  }

  // ============ SCHEDULE DAILY ============

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

    try {
      await _notifications.zonedSchedule(
        id,
        _replacePlaceholders(title),
        _replacePlaceholders(body),
        scheduledDate,
        _getNotificationDetails(),
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
      }
    }
  }

  // ============ TODO REMINDER ============

  Future<int> scheduleTodoReminder({
    required Todo todo,
    required DateTime reminderTime,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationId = todo.hashCode.abs() % 100000;

    try {
      final scheduledTime = tz.TZDateTime.from(reminderTime, tz.local);

      if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notifications.zonedSchedule(
          notificationId,
          '📋 Pengingat Tugas',
          _replacePlaceholders('Hai {nama}! Jangan lupa:  ${todo.title}'),
          scheduledTime,
          _getNotificationDetails(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );

        debugPrint('✅ Todo reminder scheduled: ID=$notificationId');
        return notificationId;
      }
      return -1;
    } catch (e) {
      debugPrint('❌ Error scheduling todo reminder:  $e');
      return -1;
    }
  }

  Future<void> cancelTodoReminder(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
    } catch (e) {
      debugPrint('❌ Error cancelling todo reminder: $e');
    }
  }

  // ============ BUDGET NOTIFICATIONS ============

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
      body: 'Hai $_userName, kamu sudah melebihi limit harian.  Hati-hati ya! ',
    );
  }

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
    debugPrint('📋 Pending notifications:  ${pending.length}');
    for (final notif in pending) {
      debugPrint('  - ID: ${notif.id}, Title: ${notif.title}');
    }
  }

  Future<bool> testNotification() async {
    return await showInstantNotification(
      title: '🔔 Test Notifikasi',
      body:
          'Hai $_userName!  Ini adalah test notifikasi dengan sound custom!  🎮',
    );
  }
}

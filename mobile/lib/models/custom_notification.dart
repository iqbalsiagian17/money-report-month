import 'package:hive/hive.dart';

part 'custom_notification.g.dart';

@HiveType(typeId: 11)
class CustomNotification extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String message;

  @HiveField(3)
  int hour;

  @HiveField(4)
  int minute;

  @HiveField(5)
  bool isEnabled;

  @HiveField(6)
  bool isDefault; // true = notifikasi wajib (tidak bisa dihapus)

  CustomNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.isDefault = false,
  });

  String get timeFormatted {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

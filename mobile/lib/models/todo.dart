import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 20)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  DateTime? reminderTime; // Waktu reminder

  @HiveField(5)
  bool hasReminder; // Apakah reminder aktif

  @HiveField(6)
  int? notificationId; // ID untuk cancel notification

  Todo({
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
    this.reminderTime,
    this.hasReminder = false,
    this.notificationId,
  }) : createdAt = createdAt ?? DateTime.now();
}

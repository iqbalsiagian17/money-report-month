import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';

class TodoProvider extends ChangeNotifier {
  final _box = Hive.box<Todo>('todos');

  List<Todo> get todos => _box.values.toList();

  // Todos yang belum selesai
  List<Todo> get pendingTodos =>
      _box.values.where((t) => !t.isCompleted).toList();

  // Todos yang sudah selesai
  List<Todo> get completedTodos =>
      _box.values.where((t) => t.isCompleted).toList();

  // Todos dengan reminder aktif
  List<Todo> get todosWithReminder =>
      _box.values.where((t) => t.hasReminder && !t.isCompleted).toList();

  // Jumlah total
  int get totalCount => _box.length;

  // Jumlah selesai
  int get completedCount => _box.values.where((t) => t.isCompleted).length;

  Future<void> addTodo(
    String title, {
    DateTime? dueDate,
    DateTime? reminderTime,
  }) async {
    final todo = Todo(
      title: title,
      dueDate: dueDate,
      reminderTime: reminderTime,
      hasReminder: reminderTime != null,
    );

    await _box.add(todo);

    // Schedule reminder if set
    if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
      final notificationId = await NotificationService().scheduleTodoReminder(
        todo: todo,
        reminderTime: reminderTime,
      );
      todo.notificationId = notificationId;
      await todo.save();
    }

    notifyListeners();
  }

  Future<void> toggleTodo(Todo todo) async {
    todo.isCompleted = !todo.isCompleted;

    // Cancel reminder if completed
    if (todo.isCompleted && todo.notificationId != null) {
      await NotificationService().cancelTodoReminder(todo.notificationId!);
      todo.hasReminder = false;
    }

    await todo.save();
    notifyListeners();
  }

  void updateTodoTitle(Todo todo, String newTitle) {
    todo.title = newTitle;
    todo.save();
    notifyListeners();
  }

  Future<void> updateTodo(
    Todo todo, {
    String? title,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? clearReminder,
  }) async {
    if (title != null) {
      todo.title = title;
    }
    todo.dueDate = dueDate;

    // Handle reminder update
    if (clearReminder == true) {
      // Cancel existing reminder
      if (todo.notificationId != null) {
        await NotificationService().cancelTodoReminder(todo.notificationId!);
      }
      todo.reminderTime = null;
      todo.hasReminder = false;
      todo.notificationId = null;
    } else if (reminderTime != null) {
      // Cancel existing reminder first
      if (todo.notificationId != null) {
        await NotificationService().cancelTodoReminder(todo.notificationId!);
      }

      // Schedule new reminder
      if (reminderTime.isAfter(DateTime.now())) {
        final notificationId = await NotificationService().scheduleTodoReminder(
          todo: todo,
          reminderTime: reminderTime,
        );
        todo.reminderTime = reminderTime;
        todo.hasReminder = true;
        todo.notificationId = notificationId;
      }
    }

    await todo.save();
    notifyListeners();
  }

  Future<void> setReminder(Todo todo, DateTime reminderTime) async {
    // Cancel existing reminder first
    if (todo.notificationId != null) {
      await NotificationService().cancelTodoReminder(todo.notificationId!);
    }

    // Schedule new reminder
    if (reminderTime.isAfter(DateTime.now())) {
      final notificationId = await NotificationService().scheduleTodoReminder(
        todo: todo,
        reminderTime: reminderTime,
      );
      todo.reminderTime = reminderTime;
      todo.hasReminder = true;
      todo.notificationId = notificationId;
      await todo.save();
      notifyListeners();
    }
  }

  Future<void> cancelReminder(Todo todo) async {
    if (todo.notificationId != null) {
      await NotificationService().cancelTodoReminder(todo.notificationId!);
    }
    todo.reminderTime = null;
    todo.hasReminder = false;
    todo.notificationId = null;
    await todo.save();
    notifyListeners();
  }

  Future<void> deleteTodo(Todo todo) async {
    // Cancel reminder before deleting
    if (todo.notificationId != null) {
      await NotificationService().cancelTodoReminder(todo.notificationId!);
    }
    await todo.delete();
    notifyListeners();
  }

  Future<void> clearCompleted() async {
    final completed = _box.values.where((t) => t.isCompleted).toList();
    for (final todo in completed) {
      // Cancel reminder if any
      if (todo.notificationId != null) {
        await NotificationService().cancelTodoReminder(todo.notificationId!);
      }
      await todo.delete();
    }
    notifyListeners();
  }
}

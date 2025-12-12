import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/saving_goal.dart';

class SavingProvider extends ChangeNotifier {
  final Box<SavingGoal> _box = Hive.box<SavingGoal>('savings');

  List<SavingGoal> get savings => _box.values.toList();

  List<SavingGoal> get activeSavings =>
      savings.where((s) => !s.isCompleted).toList();

  List<SavingGoal> get completedSavings =>
      savings.where((s) => s.isCompleted).toList();

  SavingGoal? getById(String id) {
    try {
      return _box.get(id);
    } catch (_) {
      return null;
    }
  }

  // ================= ADD =================
  Future<void> addSaving(SavingGoal saving) async {
    await _box.put(saving.id, saving);
    notifyListeners();
  }
  

  // ================= UPDATE =================
  Future<void> updateSaving(SavingGoal saving) async {
    await _box.put(saving.id, saving);
    notifyListeners();
  }

  // ================= DELETE =================
  Future<void> deleteSaving(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  // ================= DEPOSIT =================
  Future<void> deposit(String savingId, double amount) async {
    if (amount <= 0) return;

    final saving = _box.get(savingId);
    if (saving == null) return;

    saving.currentAmount += amount;

    if (saving.currentAmount >= saving.targetAmount) {
      saving.isCompleted = true;
    }

    await _box.put(saving.id, saving);
    notifyListeners();
  }
}

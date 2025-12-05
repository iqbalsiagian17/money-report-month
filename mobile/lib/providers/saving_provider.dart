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
      return savings.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addSaving(SavingGoal saving) async {
    await _box.put(saving.id, saving);
    notifyListeners();
  }

  Future<void> updateSaving(SavingGoal saving) async {
    await saving.save();
    notifyListeners();
  }

  Future<void> deleteSaving(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> addDeposit(String savingId, double amount) async {
    final saving = getById(savingId);
    if (saving != null) {
      saving.currentAmount += amount;
      if (saving.currentAmount >= saving.targetAmount) {
        saving.isCompleted = true;
      }
      await saving.save();
      notifyListeners();
    }
  }
}

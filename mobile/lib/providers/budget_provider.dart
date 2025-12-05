import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final Box<Budget> _box = Hive.box<Budget>('budgets');

  List<Budget> get budgets => _box.values.toList();

  List<Budget> getCurrentMonthBudgets() {
    final now = DateTime.now();
    return budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();
  }

  Budget? getByCategoryAndMonth(String categoryId, int month, int year) {
    try {
      return budgets.firstWhere(
        (b) => b.categoryId == categoryId && b.month == month && b.year == year,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> addBudget(Budget budget) async {
    await _box.put(budget.id, budget);
    notifyListeners();
  }

  Future<void> updateBudget(Budget budget) async {
    await budget.save();
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}

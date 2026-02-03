import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/quick_action_item.dart';
import '../config/routes.dart';

class QuickActionProvider extends ChangeNotifier {
  final Box<QuickActionItem> _box = Hive.box<QuickActionItem>('quick_actions');

  // Available actions (semua yang bisa ditambahkan)
  static final List<QuickActionItem> _availableActionsTemplate = [
    QuickActionItem.fromSettingsTile(
      id: 'wallets',
      label: 'Dompet',
      route: AppRoutes.wallets,
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFF2196F3),
      order: 0,
    ),
    QuickActionItem.fromSettingsTile(
      id: 'savings',
      label: 'Tabungan',
      route: AppRoutes.savings,
      icon: Icons.savings_rounded,
      iconColor: const Color(0xFF4CAF50),
      order: 1,
    ),
    QuickActionItem.fromSettingsTile(
      id: 'todo',
      label: 'To-Do',
      route: AppRoutes.todo,
      icon: Icons.checklist_rounded,
      iconColor: const Color(0xFFE91E63),
      order: 2,
    ),
    QuickActionItem.fromSettingsTile(
      id: 'recurring',
      label: 'Rutin',
      route: AppRoutes.recurring,
      icon: Icons.repeat_rounded,
      iconColor: const Color(0xFF9C27B0),
      order: 3,
    ),
    QuickActionItem.fromSettingsTile(
      id: 'debts',
      label: 'Hutang/\nPiutang',
      route: AppRoutes.debts,
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFFFF9800),
      order: 4,
    ),
    QuickActionItem.fromSettingsTile(
      id: 'notifications',
      label: 'Notifikasi',
      route: AppRoutes.notificationSettings,
      icon: Icons.notifications_rounded,
      iconColor: const Color(0xFFFFC107),
      order: 5,
    ),
    QuickActionItem.fromSettingsTile(
      id: 'categories',
      label: 'Kategori',
      route: AppRoutes.categories,
      icon: Icons.category_rounded,
      iconColor: const Color(0xFF9C27B0),
      order: 6,
    ),
    QuickActionItem.fromSettingsTile(
      id: 'limit',
      label: 'Limit',
      route: AppRoutes.limitSettings,
      icon: Icons.tune_rounded,
      iconColor: const Color(0xFF009688),
      order: 7,
    ),
  ];

  // ✅ Get all available actions (with current state from box)
  List<QuickActionItem> get availableActions {
    if (_box.isEmpty) {
      _initDefaultActions();
    }

    // Merge template with box data
    return _availableActionsTemplate.map((template) {
      final existingAction = _box.get(template.id);
      if (existingAction != null) {
        return existingAction;
      }
      // If not in box, add it with isVisible = false
      return QuickActionItem(
        id: template.id,
        label: template.label,
        route: template.route,
        iconCodePoint: template.iconCodePoint,
        colorValue: template.colorValue,
        order: template.order,
        isVisible: false,
      );
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  // Get active quick actions (yang ditampilkan)
  List<QuickActionItem> get activeActions {
    if (_box.isEmpty) {
      _initDefaultActions();
    }
    return _box.values.where((a) => a.isVisible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  // Get all actions (termasuk yang hidden)
  List<QuickActionItem> get allActions {
    if (_box.isEmpty) {
      _initDefaultActions();
    }
    return _box.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  // Initialize default actions
  void _initDefaultActions() {
    // Add first 5 as visible
    for (var i = 0; i < _availableActionsTemplate.length; i++) {
      final template = _availableActionsTemplate[i];
      final action = QuickActionItem(
        id: template.id,
        label: template.label,
        route: template.route,
        iconCodePoint: template.iconCodePoint,
        colorValue: template.colorValue,
        order: i,
        isVisible: i < 5, // First 5 visible
      );
      _box.put(action.id, action);
    }
  }

  // ✅ Toggle visibility with proper sync
  Future<void> toggleVisibility(String id) async {
    var action = _box.get(id);

    if (action == null) {
      // If not exists, create from template
      final template = _availableActionsTemplate.firstWhere((a) => a.id == id);
      action = QuickActionItem(
        id: template.id,
        label: template.label,
        route: template.route,
        iconCodePoint: template.iconCodePoint,
        colorValue: template.colorValue,
        order: _box.length,
        isVisible: true,
      );
      await _box.put(id, action);
    } else {
      action.isVisible = !action.isVisible;
      await action.save();
    }

    notifyListeners();
  }

  // Add action
  Future<void> addAction(QuickActionItem action) async {
    await _box.put(action.id, action);
    notifyListeners();
  }

  // Remove action
  Future<void> removeAction(String id) async {
    final action = _box.get(id);
    if (action != null) {
      action.isVisible = false;
      await action.save();
      notifyListeners();
    }
  }

  // Reorder actions
  Future<void> reorder(int oldIndex, int newIndex) async {
    final items = activeActions;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Update order
    for (var i = 0; i < items.length; i++) {
      items[i].order = i;
      await items[i].save();
    }
    notifyListeners();
  }

  // Reset to default
  Future<void> resetToDefault() async {
    await _box.clear();
    _initDefaultActions();
    notifyListeners();
  }

  // Check if action is visible
  bool isActionVisible(String id) {
    final action = _box.get(id);
    return action?.isVisible ?? false;
  }
}

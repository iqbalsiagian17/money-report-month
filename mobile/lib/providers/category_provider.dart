import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final Box<CategoryModel> _box = Hive.box<CategoryModel>('categories');

  List<CategoryModel> get categories => _box.values.toList();

  // Semua kategori dianggap expense (untuk limit settings)
  List<CategoryModel> get expenseCategories => categories;

  // Untuk income (kosong untuk sementara, atau filter manual)
  List<CategoryModel> get incomeCategories => [];

  CategoryModel? getById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await _box.put(category.id, category);
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await category.save();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> initDefaultCategories() async {
    if (categories.isEmpty) {
      final defaults = [
        CategoryModel(
          id: 'food',
          name: 'Makanan',
          icon: '🍔',
          colorValue: 0xFFFF6B6B,
          isDefault: true,
        ),
        CategoryModel(
          id: 'snack',
          name: 'Jajan',
          icon: '🍿',
          colorValue: 0xFFFFB347,
          isDefault: true,
        ),
        CategoryModel(
          id: 'transport',
          name: 'Transportasi',
          icon: '🚗',
          colorValue: 0xFF4ECDC4,
          isDefault: true,
        ),
        CategoryModel(
          id: 'shopping',
          name: 'Belanja',
          icon: '🛍️',
          colorValue: 0xFFFFE66D,
          isDefault: true,
        ),
        CategoryModel(
          id: 'bills',
          name: 'Tagihan',
          icon: '📄',
          colorValue: 0xFF95E1D3,
          isDefault: true,
        ),
        CategoryModel(
          id: 'entertainment',
          name: 'Hiburan',
          icon: '🎮',
          colorValue: 0xFFDDA0DD,
          isDefault: true,
        ),
        CategoryModel(
          id: 'health',
          name: 'Kesehatan',
          icon: '💊',
          colorValue: 0xFF98D8C8,
          isDefault: true,
        ),
        CategoryModel(
          id: 'education',
          name: 'Pendidikan',
          icon: '📚',
          colorValue: 0xFFAED6F1,
          isDefault: true,
        ),
        CategoryModel(
          id: 'investment',
          name: 'Investasi',
          icon: '📈',
          colorValue: 0xFF85C1E9,
          isDefault: true,
        ),
        CategoryModel(
          id: 'donation',
          name: 'Donasi',
          icon: '❤️',
          colorValue: 0xFFF1948A,
          isDefault: true,
        ),
        CategoryModel(
          id: 'other',
          name: 'Lainnya',
          icon: '📦',
          colorValue: 0xFFD5DBDB,
          isDefault: true,
        ),
      ];

      for (var cat in defaults) {
        await addCategory(cat);
      }
    }
  }
}

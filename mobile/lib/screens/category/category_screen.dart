import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          final categories = provider.categories;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: category.isDefault
                      ? const Text('Default', style: TextStyle(fontSize: 12))
                      : const Text('Custom', style: TextStyle(fontSize: 12)),
                  trailing: category.isDefault
                      ? null
                      : PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditCategoryDialog(context, category);
                            } else if (value == 'delete') {
                              _confirmDelete(context, category);
                            }
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';
    Color selectedColor = Colors.blue;

    final icons = [
      '📦',
      '🛒',
      '🍔',
      '🚗',
      '🏠',
      '💊',
      '🎮',
      '👕',
      '💄',
      '🐕',
      '📚',
      '✈️'
    ];
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.brown,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Contoh: Skincare, Laundry',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Pilih Icon'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((icon) {
                    return InkWell(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedIcon == icon
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: selectedIcon == icon
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)
                              : null,
                        ),
                        child: Center(
                            child: Text(icon,
                                style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Pilih Warna'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((color) {
                    return InkWell(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final category = CategoryModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    icon: selectedIcon,
                    colorValue: selectedColor.value,
                  );
                  context.read<CategoryProvider>().addCategory(category);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    final nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              category.name = nameController.text;
              context.read<CategoryProvider>().updateCategory(category);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori? '),
        content: Text('Apakah Anda yakin ingin menghapus "${category.name}"? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

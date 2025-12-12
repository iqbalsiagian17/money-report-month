import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/category.dart';
import '../../../providers/category_provider.dart';
import '../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../widgets/bottom_sheet/variants/options_bottom_sheet.dart';
import '../../../widgets/bottom_sheet/variants/info_bottom_sheet.dart';

// Form Fields
import 'category_form_fields.dart';
import 'icon_selector.dart';
import 'color_selector.dart';

enum CategoryOptionAction {
  edit,
  delete,
}

class CategoryOptions {
  CategoryOptions._();

  // ================= SHOW OPTIONS =================
  static Future<void> show(BuildContext context, CategoryModel category) async {
    if (category.isDefault) {
      await AppBottomSheet.showInfo(
        context: context,
        title: 'Kategori Default',
        message:
            '"${category.name}" adalah kategori bawaan dan tidak dapat diubah atau dihapus.',
        type: InfoType.info,
        icon: Icons.lock_rounded,
      );
      return;
    }

    final action = await AppBottomSheet.showOptions<CategoryOptionAction>(
      context: context,
      title: category.name,
      subtitle: '${category.icon} Kategori Custom',
      options: const [
        BottomSheetOption(
          title: 'Edit Kategori',
          subtitle: 'Ubah nama, icon, atau warna',
          icon: Icons.edit_rounded,
          iconColor: Colors.blue,
          value: CategoryOptionAction.edit,
        ),
        BottomSheetOption(
          title: 'Hapus Kategori',
          subtitle: 'Hapus kategori ini secara permanen',
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          isDestructive: true,
          value: CategoryOptionAction.delete,
        ),
      ],
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case CategoryOptionAction.edit:
        showEditForm(context, category);
        break;
      case CategoryOptionAction.delete:
        _confirmDelete(context, category);
        break;
    }
  }

  // ================= ADD CATEGORY =================
  static void showAddForm(BuildContext context) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';
    Color selectedColor = const Color(0xFF5DADE2);

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Kategori Baru',
      subtitle: 'Buat kategori pengeluaran custom',
      submitText: 'Simpan',
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview
            CategoryPreview(
              name: nameController.text,
              icon: selectedIcon,
              color: selectedColor,
            ),
            const SizedBox(height: 20),

            // Name Field
            CategoryNameField(
              controller: nameController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Icon Selector
            IconSelector(
              selectedIcon: selectedIcon,
              onChanged: (icon) => setState(() => selectedIcon = icon),
            ),
            const SizedBox(height: 20),

            // Color Selector
            ColorSelector(
              selectedColor: selectedColor,
              onChanged: (color) => setState(() => selectedColor = color),
            ),
          ],
        );
      },
      onSubmit: () async {
        if (nameController.text.trim().isEmpty) {
          _showError(context, 'Nama kategori tidak boleh kosong');
          return null;
        }

        final category = CategoryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text.trim(),
          icon: selectedIcon,
          colorValue: selectedColor.value,
        );

        await context.read<CategoryProvider>().addCategory(category);

        if (context.mounted) {
          _showSuccess(
              context, 'Kategori "${category.name}" berhasil ditambahkan');
        }

        return true;
      },
    );
  }

  // ================= EDIT CATEGORY =================
  static void showEditForm(BuildContext context, CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon;
    Color selectedColor = Color(category.colorValue);

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Edit Kategori',
      subtitle: 'Ubah detail ${category.name}',
      submitText: 'Simpan Perubahan',
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview
            CategoryPreview(
              name: nameController.text,
              icon: selectedIcon,
              color: selectedColor,
            ),
            const SizedBox(height: 20),

            // Name Field
            CategoryNameField(
              controller: nameController,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Icon Selector
            IconSelector(
              selectedIcon: selectedIcon,
              onChanged: (icon) => setState(() => selectedIcon = icon),
            ),
            const SizedBox(height: 20),

            // Color Selector
            ColorSelector(
              selectedColor: selectedColor,
              onChanged: (color) => setState(() => selectedColor = color),
            ),
          ],
        );
      },
      onSubmit: () async {
        if (nameController.text.trim().isEmpty) {
          _showError(context, 'Nama kategori tidak boleh kosong');
          return null;
        }

        category.name = nameController.text.trim();
        category.icon = selectedIcon;
        category.colorValue = selectedColor.value;

        await context.read<CategoryProvider>().updateCategory(category);

        if (context.mounted) {
          _showSuccess(
              context, 'Kategori "${category.name}" berhasil diupdate');
        }

        return true;
      },
    );
  }

  // ================= DELETE CATEGORY =================
  static Future<void> _confirmDelete(
    BuildContext context,
    CategoryModel category,
  ) async {
    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Hapus ${category.name}?',
      message:
          'Kategori ini akan dihapus secara permanen. Transaksi dengan kategori ini akan kehilangan kategorinya.',
      isDanger: true,
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      content: CategoryDeletePreview(
        name: category.name,
        icon: category.icon,
        color: Color(category.colorValue),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CategoryProvider>().deleteCategory(category.id);
      _showSuccess(context, 'Kategori "${category.name}" berhasil dihapus');
    }
  }

  // ================= SNACKBAR HELPERS =================
  static void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/wallet.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../../../widgets/bottom_sheet/variants/options_bottom_sheet.dart';

enum WalletOptionAction { edit, delete }

class WalletOptions {
  static Future<void> show(
    BuildContext context,
    Wallet wallet,
  ) async {
    final action = await AppBottomSheet.showOptions<WalletOptionAction>(
      context: context,
      title: 'Opsi Dompet',
      subtitle: wallet.name,
      options: [
        BottomSheetOption(
          title: 'Edit Dompet',
          subtitle: 'Ubah nama dan jenis dompet',
          icon: Icons.edit_rounded,
          iconColor: Colors.blue,
          value: WalletOptionAction.edit,
        ),
        BottomSheetOption(
          title: 'Hapus Dompet',
          subtitle: 'Hapus dompet secara permanen',
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          isDestructive: true,
          value: WalletOptionAction.delete,
        ),
      ],
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case WalletOptionAction.edit:
        _showEditForm(context, wallet);
        break;
      case WalletOptionAction.delete:
        _showDeleteConfirm(context, wallet);
        break;
    }
  }

  // ================= EDIT FORM =================
  static void _showEditForm(BuildContext context, Wallet wallet) {
    final nameController = TextEditingController(text: wallet.name);
    WalletType selectedType = wallet.type;

    AppBottomSheet.showForm<bool>(
      context: context,
      title: 'Edit Dompet',
      submitText: 'Simpan',
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Dompet'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama dompet wajib diisi'
                  : null,
            ),
            const SizedBox(height: 20),
            const Text(
              'Jenis Dompet',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: WalletType.values.map((type) {
                return ChoiceChip(
                  label: Text(_walletTypeLabel(type)),
                  selected: selectedType == type,
                  onSelected: (_) => setState(() => selectedType = type),
                );
              }).toList(),
            ),
          ],
        );
      },
      onSubmit: () async {
        final provider = context.read<WalletProvider>();

        await provider.updateWallet(
          Wallet(
            id: wallet.id,
            name: nameController.text.trim(),
            type: selectedType,
            balance: wallet.balance,
            icon: _walletTypeIcon(selectedType),
            createdAt: wallet.createdAt,
          ),
        );

        return true; // ✅ PENTING
      },
    );
  }

  // ================= DELETE CONFIRM =================
  static Future<void> _showDeleteConfirm(
    BuildContext context,
    Wallet wallet,
  ) async {
    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Hapus Dompet',
      message: 'Dompet "${wallet.name}" akan dihapus secara permanen.',
      isDanger: true,
      confirmText: 'Hapus',
    );

    if (confirmed == true && context.mounted) {
      await context.read<WalletProvider>().deleteWallet(wallet.id);
    }
  }
}

// ================= HELPERS =================
String _walletTypeLabel(WalletType type) {
  switch (type) {
    case WalletType.cash:
      return 'Cash';
    case WalletType.bank:
      return 'Bank';
    case WalletType.emoney:
      return 'E-Money';
  }
}

String _walletTypeIcon(WalletType type) {
  switch (type) {
    case WalletType.cash:
      return '💵';
    case WalletType.bank:
      return '🏦';
    case WalletType.emoney:
      return '📱';
  }
}

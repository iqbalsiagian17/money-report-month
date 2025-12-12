import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/wallet.dart';
import '../../transaction/widgets/shared/currency_input_formatter.dart';

class SavingNameField extends StatelessWidget {
  final TextEditingController controller;

  const SavingNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Nama Target',
        hintText: 'Contoh: Beli Laptop, Liburan',
        prefixIcon: const Icon(Icons.flag_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Masukkan nama target';
        }
        return null;
      },
    );
  }
}

class SavingTargetField extends StatelessWidget {
  final TextEditingController controller;

  const SavingTargetField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Target Nominal',
        prefixText: 'Rp ',
        prefixIcon: const Icon(Icons.monetization_on_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Masukkan target nominal';
        }
        final amount = CurrencyInputFormatter.getNumericValue(value);
        if (amount <= 0) {
          return 'Target harus lebih dari 0';
        }
        return null;
      },
    );
  }
}

class SavingWalletDropdown extends StatelessWidget {
  final String? selectedWalletId;
  final List<Wallet> wallets;
  final ValueChanged<String?> onChanged;

  const SavingWalletDropdown({
    super.key,
    required this.selectedWalletId,
    required this.wallets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Belum ada dompet.  Tambahkan dompet terlebih dahulu.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedWalletId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Sumber Dana',
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: wallets.map((wallet) {
        return DropdownMenuItem(
          value: wallet.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(wallet.icon ?? '💰', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  wallet.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Pilih sumber dana' : null,
    );
  }
}

class SavingDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const SavingDatePicker({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Target Tanggal (Opsional)',
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          suffixIcon: selectedDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: onTap,
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate!)
              : 'Pilih tanggal target',
          style: TextStyle(
            color: selectedDate != null
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

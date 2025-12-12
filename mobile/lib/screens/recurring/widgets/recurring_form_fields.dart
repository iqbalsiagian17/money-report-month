import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/recurring_transaction.dart';
import '../../../models/wallet.dart';
import '../../transaction/widgets/shared/currency_input_formatter.dart';

class RecurringNameField extends StatelessWidget {
  final TextEditingController controller;

  const RecurringNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Nama Transaksi',
        hintText: 'Contoh: Gaji, Sewa Kos, Netflix',
        prefixIcon: const Icon(Icons.label_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class RecurringAmountField extends StatelessWidget {
  final TextEditingController controller;

  const RecurringAmountField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Nominal',
        prefixText: 'Rp ',
        prefixIcon: const Icon(Icons.monetization_on_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class RecurringTypeSwitch extends StatelessWidget {
  final bool isIncome;
  final ValueChanged<bool> onChanged;

  const RecurringTypeSwitch({
    super.key,
    required this.isIncome,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TypeButton(
            label: 'Pengeluaran',
            icon: Icons.arrow_upward_rounded,
            isSelected: !isIncome,
            color: Colors.red,
            onTap: () => onChanged(false),
          ),
          _TypeButton(
            label: 'Pemasukan',
            icon: Icons.arrow_downward_rounded,
            isSelected: isIncome,
            color: Colors.green,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecurringWalletDropdown extends StatelessWidget {
  final String? selectedWalletId;
  final List<Wallet> wallets;
  final ValueChanged<String?> onChanged;

  const RecurringWalletDropdown({
    super.key,
    required this.selectedWalletId,
    required this.wallets,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: selectedWalletId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Dompet Tujuan',
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: wallets.map((wallet) {
        return DropdownMenuItem(
          value: wallet.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(wallet.icon ?? '💰', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
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
    );
  }
}

class RecurringPeriodDropdown extends StatelessWidget {
  final RecurringType selectedType;
  final ValueChanged<RecurringType?> onChanged;

  const RecurringPeriodDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<RecurringType>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: 'Periode',
        prefixIcon: const Icon(Icons.repeat_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: RecurringType.daily,
          child: Row(
            children: [
              Icon(Icons.today_rounded, size: 18),
              SizedBox(width: 8),
              Text('Harian'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: RecurringType.weekly,
          child: Row(
            children: [
              Icon(Icons.view_week_rounded, size: 18),
              SizedBox(width: 8),
              Text('Mingguan'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: RecurringType.monthly,
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18),
              SizedBox(width: 8),
              Text('Bulanan'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: RecurringType.yearly,
          child: Row(
            children: [
              Icon(Icons.event_rounded, size: 18),
              SizedBox(width: 8),
              Text('Tahunan'),
            ],
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class RecurringDayDropdown extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int?> onChanged;

  const RecurringDayDropdown({
    super.key,
    required this.selectedDay,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<int>(
      value: selectedDay,
      decoration: InputDecoration(
        labelText: 'Tanggal Eksekusi',
        prefixIcon: const Icon(Icons.calendar_today_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: List.generate(28, (i) => i + 1).map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text('Tanggal $day'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

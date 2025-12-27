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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedWalletId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Dompet Tujuan',
          prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        dropdownColor: isDark ? Colors.grey[850] : Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
      ),
    );
  }
}

class RecurringPeriodDropdown extends StatelessWidget {
  final RecurringType? selectedType;
  final ValueChanged<RecurringType?> onChanged;

  const RecurringPeriodDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  String _getPeriodLabel(RecurringType type) {
    switch (type) {
      case RecurringType.daily:
        return 'Harian';
      case RecurringType.weekly:
        return 'Mingguan';
      case RecurringType.monthly:
        return 'Bulanan';
      case RecurringType.yearly:
        return 'Tahunan';
    }
  }

  IconData _getPeriodIcon(RecurringType type) {
    switch (type) {
      case RecurringType.daily:
        return Icons.today_rounded;
      case RecurringType.weekly:
        return Icons.view_week_rounded;
      case RecurringType.monthly:
        return Icons.calendar_month_rounded;
      case RecurringType.yearly:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<RecurringType>(
      value: selectedType, // sekarang bisa null
      decoration: InputDecoration(
        hintText: 'Periode',
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.repeat_rounded),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      dropdownColor: isDark ? Colors.grey[850] : Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),

      items: RecurringType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(_getPeriodIcon(type), size: 18),
              const SizedBox(width: 8),
              Text(_getPeriodLabel(type)),
            ],
          ),
        );
      }).toList(),

      onChanged: onChanged,
      validator: (value) =>
          value == null ? 'Pilih periode terlebih dahulu' : null,
    );
  }
}

class RecurringDayPicker extends StatelessWidget {
  final int selectedDay;
  final RecurringType recurringType;
  final ValueChanged<int?> onChanged;

  const RecurringDayPicker({
    super.key,
    required this.selectedDay,
    required this.recurringType,
    required this.onChanged,
  });

  Future<void> _showDayPicker(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // tanggal harus 1 - 28
    final validDay = selectedDay.clamp(1, 28);
    final now = DateTime.now();
    final initialDate = DateTime(now.year, now.month, validDay);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(now.year, now.month, 28),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: isDark ? Colors.grey[850]! : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked.day.clamp(1, 28));
    }
  }

  String _getDisplayText() {
    switch (recurringType) {
      case RecurringType.daily:
        return 'Setiap Hari';
      case RecurringType.weekly:
        return 'Setiap ${_getWeekdayName(selectedDay)}';
      case RecurringType.monthly:
        return 'Tanggal $selectedDay';
      case RecurringType.yearly:
        return 'Tanggal $selectedDay';
    }
  }

  String _getWeekdayName(int day) {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return weekdays[(day - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (recurringType != RecurringType.monthly) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _showDayPicker(context),
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Tanggal Eksekusi',
            prefixIcon: const Icon(Icons.calendar_month_rounded),
            hintText: selectedDay == 0 ? 'Pilih tanggal' : _getDisplayText(),
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _DayPickerSheet extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const _DayPickerSheet({
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Tanggal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 28,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isSelected = day == selectedDay;

                return GestureDetector(
                  onTap: () => onDaySelected(day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

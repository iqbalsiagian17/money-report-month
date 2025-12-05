import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../models/recurring_transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/category_provider.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  Box<RecurringTransaction> get _box => Hive.box<RecurringTransaction>('recurring');

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Rutin'),
        actions: [
          IconButton(
            onPressed: () => _showAddRecurringDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box<RecurringTransaction> box, _) {
          final recurring = box.values.toList();

          if (recurring.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi rutin',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contoh: Gaji bulanan, Sewa kos, Netflix',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddRecurringDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Transaksi Rutin'),
                  ),
                ],
              ),
            );
          }

          final incomeRecurring = recurring.where((r) => r.isIncome).toList();
          final expenseRecurring = recurring.where((r) => ! r.isIncome).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Income Recurring
              if (incomeRecurring.isNotEmpty) ...[
                const Text(
                  '💰 Pemasukan Rutin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...incomeRecurring.map((r) => _buildRecurringCard(
                  context,
                  r,
                  currencyFormat,
                  Colors.green,
                )),
                const SizedBox(height: 24),
              ],

              // Expense Recurring
              if (expenseRecurring.isNotEmpty) ...[
                const Text(
                  '💸 Pengeluaran Rutin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...expenseRecurring.map((r) => _buildRecurringCard(
                  context,
                  r,
                  currencyFormat,
                  Colors.red,
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    RecurringTransaction recurring,
    NumberFormat format,
    Color color,
  ) {
    final walletProvider = context.read<WalletProvider>();
    final wallet = walletProvider.getById(recurring.walletId);

    String recurringLabel;
    switch (recurring.recurringType) {
      case RecurringType.daily:
        recurringLabel = 'Setiap hari';
        break;
      case RecurringType.weekly:
        recurringLabel = 'Setiap minggu';
        break;
      case RecurringType.monthly:
        recurringLabel = 'Setiap tanggal ${recurring.dayOfMonth}';
        break;
      case RecurringType.yearly:
        recurringLabel = 'Setiap tahun';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRecurringOptions(context, recurring),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  recurring.isIncome ?  Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recurring.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.repeat, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          recurringLabel,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          wallet?.name ?? 'Unknown',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    format.format(recurring.amount),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: recurring.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      recurring.isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        color: recurring.isActive ? Colors.green : Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;
    String? selectedWalletId;
    RecurringType recurringType = RecurringType.monthly;
    int dayOfMonth = 1;

    showDialog(
      context: context,
      builder: (context) => Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Tambah Transaksi Rutin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        hintText: 'Contoh: Gaji, Sewa Kos',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Nominal',
                        prefixText: 'Rp ',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Pemasukan? '),
                      value: isIncome,
                      onChanged: (value) => setState(() => isIncome = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedWalletId,
                      decoration: const InputDecoration(labelText: 'Dompet'),
                      items: walletProvider.wallets.map((wallet) {
                        return DropdownMenuItem(
                          value: wallet.id,
                          child: Text(wallet.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedWalletId = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RecurringType>(
                      value: recurringType,
                      decoration: const InputDecoration(labelText: 'Periode'),
                      items: const [
                        DropdownMenuItem(value: RecurringType.daily, child: Text('Harian')),
                        DropdownMenuItem(value: RecurringType.weekly, child: Text('Mingguan')),
                        DropdownMenuItem(value: RecurringType.monthly, child: Text('Bulanan')),
                        DropdownMenuItem(value: RecurringType.yearly, child: Text('Tahunan')),
                      ],
                      onChanged: (value) => setState(() => recurringType = value! ),
                    ),
                    if (recurringType == RecurringType.monthly) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: dayOfMonth,
                        decoration: const InputDecoration(labelText: 'Tanggal'),
                        items: List.generate(28, (i) => i + 1).map((day) {
                          return DropdownMenuItem(value: day, child: Text('Tanggal $day'));
                        }).toList(),
                        onChanged: (value) => setState(() => dayOfMonth = value! ),
                      ),
                    ],
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
                    if (nameController.text.isNotEmpty &&
                        amountController.text.isNotEmpty &&
                        selectedWalletId != null) {
                      final now = DateTime.now();
                      var nextDue = DateTime(now.year, now.month, dayOfMonth);
                      if (nextDue.isBefore(now)) {
                        nextDue = DateTime(now.year, now.month + 1, dayOfMonth);
                      }

                      final recurring = RecurringTransaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        amount: double.parse(amountController.text),
                        isIncome: isIncome,
                        walletId: selectedWalletId! ,
                        recurringType: recurringType,
                        dayOfMonth: dayOfMonth,
                        nextDueDate: nextDue,
                      );

                      _box.put(recurring.id, recurring);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRecurringOptions(BuildContext context, RecurringTransaction recurring) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              recurring.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                recurring.isActive ? Icons.pause : Icons.play_arrow,
              ),
              title: Text(recurring.isActive ? 'Nonaktifkan' : 'Aktifkan'),
              onTap: () {
                recurring.isActive = ! recurring.isActive;
                recurring.save();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                _box.delete(recurring.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
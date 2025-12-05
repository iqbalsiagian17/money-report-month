import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/routes.dart';
import '../../models/saving_goal.dart';
import '../../providers/saving_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/progress_bar.dart';

class SavingListScreen extends StatelessWidget {
  const SavingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan Saya'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addSaving),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<SavingProvider>(
        builder: (context, provider, _) {
          if (provider.savings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada target tabungan',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.addSaving),
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Target Baru'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Active Savings
              if (provider.activeSavings.isNotEmpty) ...[
                const Text(
                  'Target Aktif',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...provider.activeSavings.map((saving) => _buildSavingCard(
                  context,
                  saving,
                  currencyFormat,
                )),
                const SizedBox(height: 24),
              ],

              // Completed Savings
              if (provider.completedSavings.isNotEmpty) ...[
                const Text(
                  'Target Tercapai 🎉',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...provider.completedSavings.map((saving) => _buildSavingCard(
                  context,
                  saving,
                  currencyFormat,
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSavingCard(
    BuildContext context,
    SavingGoal saving,
    NumberFormat format,
  ) {
    final walletProvider = context.read<WalletProvider>();
    final wallet = walletProvider.getById(saving.walletId);
    final progressPercent = (saving.progress * 100).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSavingOptions(context, saving),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: saving.isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      saving.isCompleted ?  Icons.check_circle : Icons.savings,
                      color: saving.isCompleted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saving.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sumber: ${wallet?.name ?? "Unknown"}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (saving.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tercapai',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBar(
                progress: saving.progress,
                color: saving.isCompleted
                    ? Colors.green
                    : Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    format.format(saving.currentAmount),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$progressPercent%',
                    style: TextStyle(
                      color: saving.isCompleted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    format.format(saving.targetAmount),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (! saving.isCompleted) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDepositDialog(context, saving),
                    icon: const Icon(Icons.add),
                    label: const Text('Setor Tabungan'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSavingOptions(BuildContext context, SavingGoal saving) {
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
              saving.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            if (! saving.isCompleted)
              ListTile(
                leading: const Icon(Icons.add_circle),
                title: const Text('Setor Tabungan'),
                onTap: () {
                  Navigator.pop(context);
                  _showDepositDialog(context, saving);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Target'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, saving);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Target', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, saving);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, SavingGoal saving) {
    final amountController = TextEditingController();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setor Tabungan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target: ${saving.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Sisa: ${currencyFormat.format(saving.remaining)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Setoran',
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ??  0;
              if (amount > 0) {
                // Potong saldo wallet
                context.read<WalletProvider>().updateBalance(
                  saving.walletId,
                  -amount,
                );
                
                // Tambah ke tabungan
                context.read<SavingProvider>().addDeposit(saving.id, amount);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil menyetor ${currencyFormat.format(amount)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Setor'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, SavingGoal saving) {
    final nameController = TextEditingController(text: saving.name);
    final targetController = TextEditingController(
      text: saving.targetAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Target'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Nominal',
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              saving.name = nameController.text;
              saving.targetAmount = double.tryParse(targetController.text) ?? saving.targetAmount;
              context.read<SavingProvider>().updateSaving(saving);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SavingGoal saving) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Target? '),
        content: Text('Apakah Anda yakin ingin menghapus "${saving.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SavingProvider>().deleteSaving(saving.id);
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
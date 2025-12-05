import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/saving_goal.dart';
import '../../providers/saving_provider.dart';
import '../../providers/wallet_provider.dart';

class AddSavingScreen extends StatefulWidget {
  const AddSavingScreen({super.key});

  @override
  State<AddSavingScreen> createState() => _AddSavingScreenState();
}

class _AddSavingScreenState extends State<AddSavingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  String? _selectedWalletId;
  DateTime? _targetDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Target Tabungan'),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.savings,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Target',
                    hintText: 'Contoh: Beli Laptop, Liburan',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nama target';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Amount
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Target Nominal',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan target nominal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Wallet
                DropdownButtonFormField<String>(
                  value: _selectedWalletId,
                  decoration: const InputDecoration(
                    labelText: 'Sumber Dana',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  items: walletProvider.wallets.map((wallet) {
                    return DropdownMenuItem(
                      value: wallet.id,
                      child: Row(
                        children: [
                          Text(wallet.icon ?? '💰'),
                          const SizedBox(width: 8),
                          Text(wallet.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedWalletId = value),
                  validator: (value) {
                    if (value == null) return 'Pilih sumber dana';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Date (Optional)
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Target Tanggal (Opsional)',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _targetDate != null
                          ? DateFormat('dd MMMM yyyy', 'id_ID')
                              .format(_targetDate!)
                          : 'Pilih tanggal',
                      style: TextStyle(
                        color: _targetDate != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveSaving,
                    child: const Text(
                      'Buat Target Tabungan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  void _saveSaving() {
    if (_formKey.currentState!.validate()) {
      final saving = SavingGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        targetAmount: double.parse(_targetController.text),
        walletId: _selectedWalletId!,
        targetDate: _targetDate,
      );

      context.read<SavingProvider>().addSaving(saving);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target tabungan berhasil dibuat!  🎯'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}

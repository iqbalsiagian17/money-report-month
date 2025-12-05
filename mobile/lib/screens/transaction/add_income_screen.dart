import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String?  _selectedWalletId;
  String _selectedSource = 'Gaji';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _incomeSources = [
    'Gaji',
    'Bonus',
    'Hadiah',
    'Usaha',
    'Investasi',
    'Pinjaman',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pemasukan'),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Amount
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Jumlah Pemasukan',
                        style: TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan jumlah';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Source
                DropdownButtonFormField<String>(
                  value: _selectedSource,
                  decoration: const InputDecoration(
                    labelText: 'Sumber Pemasukan',
                    prefixIcon: Icon(Icons.source),
                  ),
                  items: _incomeSources.map((source) {
                    return DropdownMenuItem(value: source, child: Text(source));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedSource = value!),
                ),
                const SizedBox(height: 16),

                // Wallet
                DropdownButtonFormField<String>(
                  value: _selectedWalletId,
                  decoration: const InputDecoration(
                    labelText: 'Simpan ke Dompet',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  items: walletProvider.wallets.map((wallet) {
                    return DropdownMenuItem(
                      value: wallet.id,
                      child: Row(
                        children: [
                          Text(wallet.icon ??  '💰'),
                          const SizedBox(width: 8),
                          Text(wallet.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedWalletId = value),
                  validator: (value) {
                    if (value == null) return 'Pilih dompet';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Waktu',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(_selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note (gabungan source + catatan)
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Contoh: Gaji bulan Desember',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveIncome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Simpan Pemasukan',
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
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _saveIncome() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Gabungkan source dan note untuk field note
      String noteText = _selectedSource;
      if (_noteController.text.isNotEmpty) {
        noteText = '$_selectedSource: ${_noteController.text}';
      }

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.income,
        amount: amount,
        walletId: _selectedWalletId!,
        categoryId: null, // Income tidak perlu kategori
        dateTime: dateTime,
        note: noteText,
      );

      // Save transaction
      context.read<TransactionProvider>().addTransaction(transaction);

      // Update wallet balance
      context.read<WalletProvider>().updateBalance(_selectedWalletId!, amount);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemasukan berhasil disimpan! 💰'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
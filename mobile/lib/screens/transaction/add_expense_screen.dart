import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/budget_provider.dart';
import '../../services/notification_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedWalletId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
      ),
      body: Consumer3<WalletProvider, CategoryProvider, BudgetProvider>(
        builder:
            (context, walletProvider, categoryProvider, budgetProvider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Amount
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Jumlah Pengeluaran',
                        style: TextStyle(color: Colors.red),
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
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
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

                // Note (Apa yang dibeli)
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Apa yang dibeli? ',
                    prefixIcon: Icon(Icons.shopping_bag),
                    hintText: 'Contoh: Makan siang, Bensin',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan catatan pengeluaran';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Text(category.icon),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategoryId = value),
                  validator: (value) {
                    if (value == null) return 'Pilih kategori';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Wallet
                DropdownButtonFormField<String>(
                  value: _selectedWalletId,
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    prefixIcon: Icon(Icons.payment),
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
                    if (value == null) return 'Pilih metode pembayaran';
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
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Simpan Pengeluaran',
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

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.expense,
        amount: amount,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId, // Ini sudah String?
        dateTime: dateTime,
        note: _noteController.text, // Ini String, bukan String?
      );

      // Save transaction
      context.read<TransactionProvider>().addTransaction(transaction);

      // Update wallet balance (subtract)
      context.read<WalletProvider>().updateBalance(_selectedWalletId!, -amount);

      // Check budget
      _checkBudget();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengeluaran berhasil disimpan! 📝'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkBudget() async {
    if (_selectedCategoryId == null) return;

    final now = DateTime.now();
    final budgetProvider = context.read<BudgetProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    final budget = budgetProvider.getByCategoryAndMonth(
      _selectedCategoryId!,
      now.month,
      now.year,
    );

    if (budget != null) {
      final spent = transactionProvider.thisMonthTransactions
          .where((t) =>
              t.categoryId == _selectedCategoryId &&
              t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final percentage = ((spent / budget.limitAmount) * 100).round();

      if (percentage >= 80) {
        final category = categoryProvider.getById(_selectedCategoryId!);
        await NotificationService().showBudgetWarning(
          category?.name ?? 'Kategori',
          percentage,
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

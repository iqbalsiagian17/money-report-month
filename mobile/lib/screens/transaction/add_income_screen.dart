import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_button.dart';

// Import widgets
import 'widgets/shared/amount_input.dart';
import 'widgets/shared/date_time_picker.dart';
import 'widgets/shared/note_field.dart';
import 'widgets/shared/currency_input_formatter.dart';
import 'widgets/income/income_source_dropdown.dart';
import 'widgets/income/wallet_selector.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedWalletId;
  String _selectedSource = 'Gaji';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pemasukan')),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AmountInput(
                  controller: _amountController,
                  label: 'Jumlah Pemasukan',
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                IncomeSourceDropdown(
                  selectedSource: _selectedSource,
                  onChanged: (value) =>
                      setState(() => _selectedSource = value!),
                ),
                const SizedBox(height: 16),
                IncomeWalletSelector(
                  selectedWalletId: _selectedWalletId,
                  wallets: walletProvider.wallets,
                  onChanged: (value) =>
                      setState(() => _selectedWalletId = value),
                ),
                const SizedBox(height: 16),
                DateTimePicker(
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onDateChanged: (date) => setState(() => _selectedDate = date),
                  onTimeChanged: (time) => setState(() => _selectedTime = time),
                ),
                const SizedBox(height: 16),
                NoteField(
                  controller: _noteController,
                  hintText: 'Contoh: Gaji bulan Desember',
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Simpan Pemasukan',
                  onPressed: _saveIncome,
                  isLoading: _isLoading,
                  backgroundColor: Colors.green,
                  icon: Icons.save_rounded,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih dompet'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount =
          CurrencyInputFormatter.getNumericValue(_amountController.text);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      String noteText = _selectedSource;
      if (_noteController.text.isNotEmpty) {
        noteText = '$_selectedSource:  ${_noteController.text}';
      }

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.income,
        amount: amount,
        walletId: _selectedWalletId!,
        categoryId: null,
        dateTime: dateTime,
        note: noteText,
      );

      await context.read<TransactionProvider>().addTransaction(transaction);
      await context
          .read<WalletProvider>()
          .updateBalance(_selectedWalletId!, amount);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pemasukan berhasil disimpan! 💰'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menyimpan:  $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

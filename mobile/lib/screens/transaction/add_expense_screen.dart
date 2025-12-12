import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';

// Import widgets
import 'widgets/shared/amount_input.dart';
import 'widgets/shared/date_time_picker.dart';
import 'widgets/shared/note_field.dart';
import 'widgets/shared/currency_input_formatter.dart';
import 'widgets/expense/limit_info_card.dart';
import 'widgets/expense/category_dropdown.dart';
import 'widgets/expense/wallet_dropdown.dart';
import 'widgets/expense/dialogs/insufficient_balance_dialog.dart';
import 'widgets/expense/dialogs/limit_exceeded_dialog.dart';

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
  bool _isLoading = false;

  double get _currentAmount =>
      CurrencyInputFormatter.getNumericValue(_amountController.text);

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengeluaran')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final userProvider = context.watch<UserProvider>();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LimitInfoCard(
            userProvider: userProvider,
            txProvider: txProvider,
          ),
          const SizedBox(height: 20),
          AmountInput(
            controller: _amountController,
            label: 'Jumlah Pengeluaran',
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          NoteField(controller: _noteController),
          const SizedBox(height: 16),
          CategoryDropdown(
            selectedCategoryId: _selectedCategoryId,
            categoryProvider: categoryProvider,
            userProvider: userProvider,
            onChanged: (value) => setState(() => _selectedCategoryId = value),
          ),
          const SizedBox(height: 16),
          ExpenseWalletDropdown(
            selectedWalletId: _selectedWalletId,
            walletProvider: walletProvider,
            currentAmount: _currentAmount,
            onChanged: (value) => setState(() => _selectedWalletId = value),
          ),
          const SizedBox(height: 16),
          DateTimePicker(
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            onDateChanged: (date) => setState(() => _selectedDate = date),
            onTimeChanged: (time) => setState(() => _selectedTime = time),
          ),
          const SizedBox(height: 32),
          _buildSaveButton(walletProvider),
        ],
      ),
    );
  }

  Widget _buildSaveButton(WalletProvider walletProvider) {
    final canSave = _checkCanSave(walletProvider);

    return CustomButton(
      text: canSave ? 'Simpan Pengeluaran' : 'Saldo Tidak Cukup',
      onPressed: (_isLoading || !canSave) ? () {} : _saveExpense,
      isLoading: _isLoading,
      backgroundColor: canSave ? Colors.red : Colors.grey,
      icon: canSave ? Icons.save_rounded : Icons.block,
    );
  }

  bool _checkCanSave(WalletProvider walletProvider) {
    if (_selectedWalletId == null) return true;

    final wallet = walletProvider.wallets.firstWhere(
      (w) => w.id == _selectedWalletId,
      orElse: () => throw Exception('Wallet not found'),
    );

    if (wallet.balance <= 0) return false;
    if (_currentAmount > 0 && _currentAmount > wallet.balance) return false;

    return true;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lengkapi semua field'), backgroundColor: Colors.red),
      );
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final amount = _currentAmount;
    final walletId = _selectedWalletId!;
    final wallet = walletProvider.wallets.firstWhere((w) => w.id == walletId);

    // Validasi saldo
    if (wallet.balance < amount) {
      showDialog(
        context: context,
        builder: (ctx) =>
            InsufficientBalanceDialog(wallet: wallet, amount: amount),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final txProvider = context.read<TransactionProvider>();
      final categoryId = _selectedCategoryId!;

      // Cek limit
      final limitCheck =
          _checkLimit(userProvider, txProvider, categoryId, amount);
      if (limitCheck != null) {
        setState(() => _isLoading = false);
        final proceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => LimitExceededDialog(result: limitCheck),
        );
        if (proceed != true) return;
        setState(() => _isLoading = true);
      }

      // Simpan transaksi
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
        walletId: walletId,
        categoryId: categoryId,
        dateTime: dateTime,
        note: _noteController.text.trim(),
      );

      await txProvider.addTransaction(transaction);
      await walletProvider.updateBalance(walletId, -amount);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pengeluaran berhasil disimpan!  📝'),
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

  LimitCheckResult? _checkLimit(
    UserProvider userProvider,
    TransactionProvider txProvider,
    String categoryId,
    double amount,
  ) {
    final limitType = userProvider.getLimitTypeForCategory(categoryId);
    final isWeekend = userProvider.isWeekend();

    if (limitType == 'unlimited' || limitType == 'none') return null;

    if (limitType == 'daily' && userProvider.isDailyLimitEnabled) {
      final todaySpent = txProvider
          .getTodayExpenseByCategories(userProvider.dailyLimitCategories);
      final newTotal = todaySpent + amount;

      if (newTotal > userProvider.dailyLimit) {
        return LimitCheckResult(
          type: 'daily',
          limitName: 'Limit Harian',
          currentSpent: todaySpent,
          newAmount: amount,
          limit: userProvider.dailyLimit,
          exceeded: newTotal - userProvider.dailyLimit,
        );
      }
    }

    if (limitType == 'weekend' &&
        userProvider.isWeekendLimitEnabled &&
        isWeekend) {
      final weekendSpent = txProvider.getCurrentWeekendExpenseByCategories(
          userProvider.weekendLimitCategories);
      final newTotal = weekendSpent + amount;

      if (newTotal > userProvider.weekendLimit) {
        return LimitCheckResult(
          type: 'weekend',
          limitName: 'Limit Weekend',
          currentSpent: weekendSpent,
          newAmount: amount,
          limit: userProvider.weekendLimit,
          exceeded: newTotal - userProvider.weekendLimit,
        );
      }
    }

    return null;
  }
}

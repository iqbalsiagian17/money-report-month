import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_report_monthly/widgets/snack_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/user_provider.dart';
import '../category/widgets/icon_selector.dart';

// Import widgets
import 'widgets/shared/currency_input_formatter.dart';
import 'widgets/expense/dialogs/insufficient_balance_dialog.dart';
import 'widgets/expense/dialogs/limit_exceeded_dialog.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedWalletId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  double get _currentAmount =>
      CurrencyInputFormatter.getNumericValue(_amountController.text);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: _buildForm(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.red,
      leading: _BackButton(
        onTap: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pengeluaran',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE53935),
                Color(0xFFC62828),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: 50,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  size: 40,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isDark) {
    final walletProvider = context.watch<WalletProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final userProvider = context.watch<UserProvider>();

    // Get selected category untuk icon
    final selectedCategory = _selectedCategoryId != null
        ? categoryProvider.getById(_selectedCategoryId!)
        : null;

    // Get selected wallet untuk icon
    final selectedWallet = _selectedWalletId != null
        ? walletProvider.wallets.firstWhere((w) => w.id == _selectedWalletId)
        : null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Limit Info
            _buildLimitInfo(userProvider, txProvider, isDark),

            const SizedBox(height: 20),

            // Amount Card
            _AmountCard(
              controller: _amountController,
              color: Colors.red,
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // Category Selector
            _SelectorCard(
              label: 'Kategori',
              icon: Icons.category_rounded,
              value: selectedCategory?.name,
              valueIcon: selectedCategory != null
                  ? IconSelector.getIconData(selectedCategory.icon)
                  : null,
              valueIconColor: selectedCategory != null
                  ? Color(selectedCategory.colorValue)
                  : null,
              placeholder: 'Pilih kategori',
              isDark: isDark,
              onTap: () => _showCategoryPicker(
                  context, categoryProvider, userProvider, isDark),
            ),

            const SizedBox(height: 12),

            // Wallet Selector
            _SelectorCard(
              label: 'Dompet',
              icon: Icons.account_balance_wallet_rounded,
              value: selectedWallet?.name,
              valueIcon: _getWalletIcon(selectedWallet?.type),
              valueIconColor: _getWalletColor(selectedWallet?.type),
              subtitle: selectedWallet != null
                  ? _formatCurrency(selectedWallet.balance)
                  : null,
              placeholder: 'Pilih dompet',
              isDark: isDark,
              onTap: () => _showWalletPicker(context, walletProvider, isDark),
            ),

            // Balance Warning
            if (_selectedWalletId != null)
              _buildBalanceWarning(walletProvider, isDark),

            const SizedBox(height: 12),

            // Date Time Row
            Row(
              children: [
                Expanded(
                  child: _SelectorCard(
                    label: 'Tanggal',
                    icon: Icons.calendar_today_rounded,
                    value:
                        DateFormat('dd MMM yyyy', 'id').format(_selectedDate),
                    isDark: isDark,
                    compact: true,
                    onTap: () => _pickDate(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SelectorCard(
                    label: 'Waktu',
                    icon: Icons.access_time_rounded,
                    value: _selectedTime.format(context),
                    isDark: isDark,
                    compact: true,
                    onTap: () => _pickTime(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Note Field
            _NoteCard(
              controller: _noteController,
              isDark: isDark,
              hintText: 'Catatan (opsional)',
            ),

            const SizedBox(height: 24),

            // Save Button
            _SaveButton(
              label: 'Simpan Pengeluaran',
              color: Colors.red,
              icon: Icons.arrow_upward_rounded,
              isEnabled: _checkCanSave(walletProvider),
              isLoading: _isLoading,
              onTap: _saveExpense,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  IconData? _getWalletIcon(dynamic walletType) {
    if (walletType == null) return null;
    final typeStr = walletType.toString().split('.').last;
    switch (typeStr) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'emoney':
        return Icons.smartphone_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color? _getWalletColor(dynamic walletType) {
    if (walletType == null) return null;
    final typeStr = walletType.toString().split('.').last;
    switch (typeStr) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'emoney':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLimitInfo(
    UserProvider userProvider,
    TransactionProvider txProvider,
    bool isDark,
  ) {
    final isWeekend = userProvider.isWeekend();
    final hasAnyLimit =
        userProvider.isDailyLimitEnabled || userProvider.isWeekendLimitEnabled;

    if (!hasAnyLimit) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.speed_rounded,
                    color: Colors.blue, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Status Limit',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              if (isWeekend) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.celebration_rounded,
                          size: 12, color: Colors.purple),
                      const SizedBox(width: 4),
                      const Text(
                        'Weekend',
                        style: TextStyle(fontSize: 11, color: Colors.purple),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (userProvider.isDailyLimitEnabled)
            _LimitProgressBar(
              label: 'Harian',
              spent: txProvider.getTodayExpenseByCategories(
                  userProvider.dailyLimitCategories),
              limit: userProvider.dailyLimit,
              color: Colors.blue,
              formatCurrency: _formatCurrency,
            ),
          if (userProvider.isWeekendLimitEnabled && isWeekend) ...[
            if (userProvider.isDailyLimitEnabled) const SizedBox(height: 12),
            _LimitProgressBar(
              label: 'Weekend',
              spent: txProvider.getCurrentWeekendExpenseByCategories(
                  userProvider.weekendLimitCategories),
              limit: userProvider.weekendLimit,
              color: Colors.purple,
              formatCurrency: _formatCurrency,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceWarning(WalletProvider walletProvider, bool isDark) {
    final wallet = walletProvider.wallets.firstWhere(
      (w) => w.id == _selectedWalletId,
    );

    if (wallet.balance <= 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Saldo dompet kosong! ',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentAmount > 0 && _currentAmount > wallet.balance) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saldo tidak cukup (${_formatCurrency(wallet.balance)})',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentAmount > 0) {
      final remaining = wallet.balance - _currentAmount;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sisa:  ${_formatCurrency(remaining)}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCategoryPicker(
    BuildContext context,
    CategoryProvider categoryProvider,
    UserProvider userProvider,
    bool isDark,
  ) {
    final categories = categoryProvider.categories;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PickerSheet(
        title: 'Pilih Kategori',
        isDark: isDark,
        children: categories.map((cat) {
          final limitType = userProvider.getLimitTypeForCategory(cat.id);
          return _CategoryPickerItem(
            iconData: IconSelector.getIconData(cat.icon),
            iconColor: Color(cat.colorValue),
            label: cat.name,
            badge: limitType != 'none' ? _getLimitBadge(limitType) : null,
            isSelected: _selectedCategoryId == cat.id,
            onTap: () {
              setState(() => _selectedCategoryId = cat.id);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  String? _getLimitBadge(String limitType) {
    switch (limitType) {
      case 'daily':
        return 'Harian';
      case 'weekend':
        return 'Weekend';
      case 'unlimited':
        return 'Bebas';
      default:
        return null;
    }
  }

  void _showWalletPicker(
    BuildContext context,
    WalletProvider walletProvider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PickerSheet(
        title: 'Pilih Dompet',
        isDark: isDark,
        children: walletProvider.wallets.map((wallet) {
          return _WalletPickerItem(
            iconData: _getWalletIcon(wallet.type) ??
                Icons.account_balance_wallet_rounded,
            iconColor: _getWalletColor(wallet.type) ?? Colors.grey,
            label: wallet.name,
            subtitle: _formatCurrency(wallet.balance),
            subtitleColor: wallet.balance > 0 ? Colors.green : Colors.red,
            isSelected: _selectedWalletId == wallet.id,
            onTap: () {
              setState(() => _selectedWalletId = wallet.id);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
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

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  bool _checkCanSave(WalletProvider walletProvider) {
    if (_selectedWalletId == null) return true;

    final wallet = walletProvider.wallets.firstWhere(
      (w) => w.id == _selectedWalletId,
    );

    if (wallet.balance <= 0) return false;
    if (_currentAmount > 0 && _currentAmount > wallet.balance) return false;

    return true;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedWalletId == null) {
      _showError('Lengkapi kategori dan dompet');
      return;
    }

    if (_currentAmount <= 0) {
      _showError('Masukkan jumlah pengeluaran');
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final amount = _currentAmount;
    final walletId = _selectedWalletId!;
    final wallet = walletProvider.wallets.firstWhere((w) => w.id == walletId);

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
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        SnackHelper.success(context, 'Pengeluaran berhasil disimpan!');
      }
    } catch (e) {
      _showError('Gagal menyimpan:  $e');
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

  void _showError(String message) {
    SnackHelper.error(context, message);
  }
}

// ==================== SHARED WIDGETS ====================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final bool isDark;

  const _AmountCard({
    required this.controller,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jumlah',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[300],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectorCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final String? value;
  final IconData? valueIcon;
  final Color? valueIconColor;
  final String? subtitle;
  final String placeholder;
  final bool isDark;
  final bool compact;
  final VoidCallback onTap;

  const _SelectorCard({
    required this.label,
    required this.icon,
    this.value,
    this.valueIcon,
    this.valueIconColor,
    this.subtitle,
    this.placeholder = 'Pilih',
    required this.isDark,
    this.compact = false,
    required this.onTap,
  });

  @override
  State<_SelectorCard> createState() => _SelectorCardState();
}

class _SelectorCardState extends State<_SelectorCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        padding: EdgeInsets.all(widget.compact ? 14 : 16),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? Colors.grey[800]!
                : const Color(0xFF1A1A2E).withOpacity(0.08),
          ),
          boxShadow: widget.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (widget.valueIcon != null) ...[
                        Icon(
                          widget.valueIcon,
                          size: 16,
                          color: widget.valueIconColor ?? Colors.grey,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          widget.value ?? widget.placeholder,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.value != null
                                ? (widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E))
                                : Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final String hintText;

  const _NoteCard({
    required this.controller,
    required this.isDark,
    this.hintText = 'Catatan',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.grey[800]!
              : const Color(0xFF1A1A2E).withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.note_rounded,
              color: Colors.grey[500],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _SaveButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled && !widget.isLoading
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.isEnabled && !widget.isLoading
          ? (_) {
              setState(() => _isPressed = false);
              HapticFeedback.lightImpact();
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: widget.isEnabled ? widget.color : Colors.grey[400],
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.isEnabled
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else ...[
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LimitProgressBar extends StatelessWidget {
  final String label;
  final double spent;
  final double limit;
  final Color color;
  final String Function(double) formatCurrency;

  const _LimitProgressBar({
    required this.label,
    required this.spent,
    required this.limit,
    required this.color,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        limit > 0 ? (spent / limit * 100).clamp(0.0, 100.0) : 0.0;
    final remaining = (limit - spent).clamp(0.0, limit);

    Color progressColor;
    if (percentage < 50) {
      progressColor = Colors.green;
    } else if (percentage < 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatCurrency(spent),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            Text(
              'Sisa: ${formatCurrency(remaining)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: remaining > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _PickerSheet({
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              shrinkWrap: true,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerItem extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPickerItem({
    required this.iconData,
    required this.iconColor,
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}

class _WalletPickerItem extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Color? subtitleColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletPickerItem({
    required this.iconData,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.subtitleColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor ?? Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}

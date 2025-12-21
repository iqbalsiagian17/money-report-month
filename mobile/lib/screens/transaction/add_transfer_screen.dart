import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';

// shared widgets
import 'widgets/shared/currency_input_formatter.dart';

class AddTransferScreen extends StatefulWidget {
  const AddTransferScreen({super.key});

  @override
  State<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends State<AddTransferScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromWalletId;
  String? _toWalletId;
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
      backgroundColor: Colors.blue,
      leading: _BackButton(onTap: () => Navigator.pop(context)),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Transfer',
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
                Color(0xFF1976D2),
                Color(0xFF1565C0),
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
                  Icons.swap_horiz_rounded,
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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            _AmountCard(
              controller: _amountController,
              color: Colors.blue,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Transfer Visual Card
            _buildTransferCard(walletProvider, isDark),

            // Balance Warning
            if (_fromWalletId != null)
              _buildBalanceWarning(walletProvider, isDark),

            const SizedBox(height: 16),

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
              label: 'Transfer Dana',
              color: Colors.blue,
              icon: Icons.swap_horiz_rounded,
              isEnabled: _checkCanSave(walletProvider),
              isLoading: _isLoading,
              onTap: _saveTransfer,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferCard(WalletProvider walletProvider, bool isDark) {
    final fromWallet = _fromWalletId != null
        ? walletProvider.wallets.firstWhere((w) => w.id == _fromWalletId)
        : null;
    final toWallet = _toWalletId != null
        ? walletProvider.wallets.firstWhere((w) => w.id == _toWalletId)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          // From Wallet
          _WalletSelector(
            label: 'Dari',
            wallet: fromWallet,
            placeholder: 'Pilih dompet asal',
            isDark: isDark,
            color: Colors.red,
            icon: Icons.arrow_upward_rounded,
            formatCurrency: _formatCurrency,
            onTap: () => _showWalletPicker(
              context,
              walletProvider,
              isDark,
              isFrom: true,
              excludeId: _toWalletId,
            ),
          ),

          // Transfer Arrow
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
          ),

          // To Wallet
          _WalletSelector(
            label: 'Ke',
            wallet: toWallet,
            placeholder: 'Pilih dompet tujuan',
            isDark: isDark,
            color: Colors.green,
            icon: Icons.arrow_downward_rounded,
            formatCurrency: _formatCurrency,
            onTap: () => _showWalletPicker(
              context,
              walletProvider,
              isDark,
              isFrom: false,
              excludeId: _fromWalletId,
            ),
          ),

          // Same Wallet Warning
          if (_fromWalletId != null &&
              _toWalletId != null &&
              _fromWalletId == _toWalletId)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Dompet asal dan tujuan tidak boleh sama',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceWarning(WalletProvider walletProvider, bool isDark) {
    final wallet = walletProvider.wallets.firstWhere(
      (w) => w.id == _fromWalletId,
    );

    if (wallet.balance <= 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
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
                  'Saldo dompet asal kosong! ',
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
        padding: const EdgeInsets.only(top: 12),
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

    return const SizedBox.shrink();
  }

  void _showWalletPicker(
    BuildContext context,
    WalletProvider walletProvider,
    bool isDark, {
    required bool isFrom,
    String? excludeId,
  }) {
    final wallets =
        walletProvider.wallets.where((w) => w.id != excludeId).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PickerSheet(
        title: isFrom ? 'Pilih Dompet Asal' : 'Pilih Dompet Tujuan',
        isDark: isDark,
        children: wallets.map((wallet) {
          final selectedId = isFrom ? _fromWalletId : _toWalletId;
          return _PickerItem(
            icon: wallet.icon ?? '💰',
            label: wallet.name,
            subtitle: _formatCurrency(wallet.balance),
            subtitleColor: wallet.balance > 0 ? Colors.green : Colors.red,
            isSelected: selectedId == wallet.id,
            onTap: () {
              setState(() {
                if (isFrom) {
                  _fromWalletId = wallet.id;
                } else {
                  _toWalletId = wallet.id;
                }
              });
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
    if (_fromWalletId == null || _toWalletId == null) return false;
    if (_fromWalletId == _toWalletId) return false;

    final wallet = walletProvider.wallets.firstWhere(
      (w) => w.id == _fromWalletId,
    );

    if (wallet.balance <= 0) return false;
    if (_currentAmount > 0 && _currentAmount > wallet.balance) return false;

    return true;
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromWalletId == null || _toWalletId == null) {
      _showError('Pilih dompet asal dan tujuan');
      return;
    }

    if (_fromWalletId == _toWalletId) {
      _showError('Dompet asal dan tujuan tidak boleh sama');
      return;
    }

    final amount = _currentAmount;

    if (amount <= 0) {
      _showError('Masukkan jumlah transfer');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final note = _noteController.text.isNotEmpty
          ? _noteController.text
          : 'Transfer dana';

      // Transaksi keluar
      final outTransaction = TransactionModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_out',
        type: TransactionType.transfer,
        amount: amount,
        walletId: _fromWalletId!,
        categoryId: null,
        dateTime: dateTime,
        note: 'Transfer keluar:  $note',
      );

      // Transaksi masuk
      final inTransaction = TransactionModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_in',
        type: TransactionType.transfer,
        amount: amount,
        walletId: _toWalletId!,
        categoryId: null,
        dateTime: dateTime,
        note: 'Transfer masuk: $note',
      );

      await context.read<TransactionProvider>().addTransaction(outTransaction);
      await context.read<TransactionProvider>().addTransaction(inTransaction);

      await context.read<WalletProvider>().transferById(
            fromWalletId: _fromWalletId!,
            toWalletId: _toWalletId!,
            amount: amount,
          );

      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transfer berhasil!  🔄'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _showError('Gagal transfer: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ==================== WIDGETS ====================

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
            'Jumlah Transfer',
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

class _WalletSelector extends StatefulWidget {
  final String label;
  final Wallet? wallet;
  final String placeholder;
  final bool isDark;
  final Color color;
  final IconData icon;
  final String Function(double) formatCurrency;
  final VoidCallback onTap;

  const _WalletSelector({
    required this.label,
    required this.wallet,
    required this.placeholder,
    required this.isDark,
    required this.color,
    required this.icon,
    required this.formatCurrency,
    required this.onTap,
  });

  @override
  State<_WalletSelector> createState() => _WalletSelectorState();
}

class _WalletSelectorState extends State<_WalletSelector> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasWallet = widget.wallet != null;

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasWallet
              ? widget.color.withOpacity(0.05)
              : (widget.isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: hasWallet
              ? Border.all(color: widget.color.withOpacity(0.2))
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
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
                      if (hasWallet) ...[
                        Text(
                          widget.wallet!.icon ?? '💰',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          hasWallet ? widget.wallet!.name : widget.placeholder,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: hasWallet
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
                  if (hasWallet) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.formatCurrency(widget.wallet!.balance),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.wallet!.balance > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}

class _SelectorCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final String? value;
  final bool isDark;
  final bool compact;
  final VoidCallback onTap;

  const _SelectorCard({
    required this.label,
    required this.icon,
    this.value,
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
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon,
                  color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.value ?? 'Pilih',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.value != null
                          ? (widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E))
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 20),
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
            child: Icon(Icons.note_rounded, color: Colors.grey[500], size: 20),
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

class _PickerItem extends StatelessWidget {
  final String icon;
  final String label;
  final String? subtitle;
  final Color? subtitleColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerItem({
    required this.icon,
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
            Text(icon, style: const TextStyle(fontSize: 24)),
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

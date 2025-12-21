import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';

// Import widgets
import 'widgets/shared/currency_input_formatter.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String?  _selectedWalletId;
  String _selectedSource = 'Gaji';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  static const List<Map<String, dynamic>> _incomeSources = [
    {'name': 'Gaji', 'icon': '💼', 'color': Color(0xFF2196F3)},
    {'name': 'Bonus', 'icon': '🎁', 'color': Color(0xFFE91E63)},
    {'name': 'Hadiah', 'icon': '🎉', 'color': Color(0xFF9C27B0)},
    {'name': 'Usaha', 'icon': '🏪', 'color': Color(0xFFFF9800)},
    {'name': 'Investasi', 'icon': '📈', 'color': Color(0xFF4CAF50)},
    {'name': 'Freelance', 'icon': '💻', 'color': Color(0xFF00BCD4)},
    {'name': 'Pinjaman', 'icon': '🤝', 'color': Color(0xFF795548)},
    {'name': 'Lainnya', 'icon': '💰', 'color': Color(0xFF607D8B)},
  ];

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits:  0,
    ).format(amount);
  }

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve:  Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
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
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return FadeTransition(
      opacity:  _fadeAnimation,
      child:  CustomScrollView(
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
      backgroundColor: Colors.green,
      leading: _BackButton(onTap: () => Navigator.pop(context)),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pemasukan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient:  LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF43A047),
                Color(0xFF2E7D32),
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
                    shape:  BoxShape.circle,
                    color: Colors.white. withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: 50,
                child: Icon(
                  Icons.arrow_downward_rounded,
                  size: 40,
                  color: Colors. white. withOpacity(0.2),
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
              color: Colors.green,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Income Source Grid
            _buildSourceSection(isDark),

            const SizedBox(height: 16),

            // Wallet Selector
            _SelectorCard(
              label: 'Simpan ke Dompet',
              icon: Icons.account_balance_wallet_rounded,
              value: _selectedWalletId != null
                  ? walletProvider.wallets
                      .firstWhere((w) => w.id == _selectedWalletId)
                      .name
                  : null,
              valueIcon: _selectedWalletId != null
                  ? walletProvider.wallets
                      .firstWhere((w) => w.id == _selectedWalletId)
                      .icon
                  : null,
              subtitle: _selectedWalletId != null
                  ? _formatCurrency(walletProvider.wallets
                      .firstWhere((w) => w.id == _selectedWalletId)
                      .balance)
                  : null,
              placeholder: 'Pilih dompet',
              isDark: isDark,
              onTap: () => _showWalletPicker(context, walletProvider, isDark),
            ),

            const SizedBox(height: 12),

            // Date Time Row
            Row(
              children: [
                Expanded(
                  child:  _SelectorCard(
                    label:  'Tanggal',
                    icon: Icons.calendar_today_rounded,
                    value: DateFormat('dd MMM yyyy', 'id').format(_selectedDate),
                    isDark: isDark,
                    compact: true,
                    onTap: () => _pickDate(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SelectorCard(
                    label: 'Waktu',
                    icon: Icons. access_time_rounded,
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
              isDark:  isDark,
              hintText: 'Catatan (opsional)',
            ),

            const SizedBox(height:  24),

            // Save Button
            _SaveButton(
              label: 'Simpan Pemasukan',
              color: Colors.green,
              icon: Icons.arrow_downward_rounded,
              isEnabled: true,
              isLoading: _isLoading,
              onTap: _saveIncome,
            ),

            const SizedBox(height:  40),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ?  const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color:  Colors.black.withOpacity(0.04),
                  blurRadius:  10,
                  offset:  const Offset(0, 4),
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
                  color: Colors. green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  const Icon(Icons.source_rounded, color: Colors.green, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Sumber Pemasukan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap:  true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing:  10,
              mainAxisSpacing:  10,
              childAspectRatio: 0.85,
            ),
            itemCount: _incomeSources.length,
            itemBuilder: (context, index) {
              final source = _incomeSources[index];
              final isSelected = _selectedSource == source['name'];

              return _SourceChip(
                icon: source['icon'],
                label: source['name'],
                color: source['color'],
                isSelected:  isSelected,
                onTap: () => setState(() => _selectedSource = source['name']),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showWalletPicker(
    BuildContext context,
    WalletProvider walletProvider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context:  context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PickerSheet(
        title: 'Pilih Dompet',
        isDark: isDark,
        children: walletProvider.wallets. map((wallet) {
          return _PickerItem(
            icon: wallet.icon ??  '💰',
            label: wallet.name,
            subtitle: _formatCurrency(wallet.balance),
            subtitleColor: wallet. balance > 0 ? Colors.green : Colors.red,
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
      lastDate: DateTime. now().add(const Duration(days: 1)),
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

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyInputFormatter.getNumericValue(_amountController.text);

    if (amount <= 0) {
      _showError('Masukkan jumlah pemasukan');
      return;
    }

    if (_selectedWalletId == null) {
      _showError('Pilih dompet tujuan');
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

      String noteText = _selectedSource;
      if (_noteController.text.isNotEmpty) {
        noteText = '$_selectedSource:  ${_noteController.text}';
      }

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch. toString(),
        type: TransactionType.income,
        amount: amount,
        walletId: _selectedWalletId!,
        categoryId: null,
        dateTime: dateTime,
        note: noteText,
      );

      await context.read<TransactionProvider>().addTransaction(transaction);
      await context.read<WalletProvider>().updateBalance(_selectedWalletId!, amount);

      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pemasukan berhasil disimpan!  💰'),
            backgroundColor: Colors. green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _showError('Gagal menyimpan:  $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors. red,
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
          color: Colors.white. withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
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
    required this. isDark,
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
                  blurRadius:  20,
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
                  fontWeight: FontWeight. w700,
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

class _SourceChip extends StatefulWidget {
  final String icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SourceChip({
    required this.icon,
    required this.label,
    required this.color,
    required this. isSelected,
    required this. onTap,
  });

  @override
  State<_SourceChip> createState() => _SourceChipState();
}

class _SourceChipState extends State<_SourceChip> {
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
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.color.withOpacity(0.15)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: widget.isSelected
              ? Border.all(color: widget.color. withOpacity(0.5), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                color: widget.isSelected ? widget.color : Colors. grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final String?  value;
  final String? valueIcon;
  final String? subtitle;
  final String placeholder;
  final bool isDark;
  final bool compact;
  final VoidCallback onTap;

  const _SelectorCard({
    required this.label,
    required this.icon,
    this.value,
    this. valueIcon,
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
          borderRadius: BorderRadius. circular(16),
          border: Border.all(
            color: widget.isDark
                ? Colors.grey[800]!
                : const Color(0xFF1A1A2E).withOpacity(0.08),
          ),
          boxShadow: widget.isDark
              ? null
              :  [
                  BoxShadow(
                    color: Colors. black.withOpacity(0.03),
                    blurRadius:  10,
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
            const SizedBox(width:  12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize:  11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (widget.valueIcon != null) ...[
                        Text(widget.valueIcon!, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          widget.value ??  widget.placeholder,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.value != null
                                ? (widget.isDark ? Colors.white : const Color(0xFF1A1A2E))
                                : Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget. subtitle != null) ...[
                    const SizedBox(height:  2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
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
    required this. controller,
    required this.isDark,
    this.hintText = 'Catatan',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ?  const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors. grey[800]!
              :  const Color(0xFF1A1A2E).withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey. withOpacity(0.1),
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
                fontSize:  14,
                color: isDark ? Colors.white :  const Color(0xFF1A1A2E),
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
    required this. icon,
    required this.isEnabled,
    required this.isLoading,
    required this. onTap,
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
              widget. onTap();
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
          color: widget.isEnabled ?  widget.color :  Colors.grey[400],
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.isEnabled
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius:  20,
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
                width:  20,
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
                  fontSize:  16,
                  fontWeight: FontWeight.w700,
                  color: Colors. white,
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
              color: isDark ?  Colors.white : const Color(0xFF1A1A2E),
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
  final String?  subtitle;
  final Color?  subtitleColor;
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
              : (isDark ?  Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor. withOpacity(0.3))
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
                      subtitle! ,
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
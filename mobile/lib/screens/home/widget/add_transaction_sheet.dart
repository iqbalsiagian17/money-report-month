import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/routes.dart';

class AddTransactionSheet extends StatelessWidget {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Transaksi Baru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih jenis transaksi',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _TransactionTypeCard(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Pemasukan',
                    subtitle: 'Uang masuk',
                    color: const Color(0xFF4CAF50),
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.addIncome);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TransactionTypeCard(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Pengeluaran',
                    subtitle: 'Uang keluar',
                    color: const Color(0xFFE53935),
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.addExpense);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TransactionTypeCard(
                    icon: Icons.sync_alt_rounded,
                    label: 'Pemindahan Dana',
                    subtitle: 'Pindah saldo antar dompet',
                    color: const Color(0xFF1E88E5),
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.transfer);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
        ],
      ),
    );
  }
}

class _TransactionTypeCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _TransactionTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_TransactionTypeCard> createState() => _TransactionTypeCardState();
}

class _TransactionTypeCardState extends State<_TransactionTypeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF252525) : Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

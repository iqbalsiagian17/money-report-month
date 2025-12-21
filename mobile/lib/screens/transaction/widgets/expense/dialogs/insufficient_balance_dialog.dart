import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../models/wallet.dart';

class InsufficientBalanceDialog extends StatelessWidget {
  final Wallet wallet;
  final double amount;

  const InsufficientBalanceDialog({
    super.key,
    required this.wallet,
    required this.amount,
  });

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shortage = amount - wallet.balance;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.red,
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Saldo Tidak Cukup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Saldo ${wallet.name} tidak mencukupi untuk transaksi ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Pengeluaran',
                    value: _formatCurrency(amount),
                    valueColor: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Saldo Tersedia',
                    value: _formatCurrency(wallet.balance),
                    valueColor: Colors.green,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.grey[300], height: 1),
                  ),
                  _InfoRow(
                    icon: Icons.remove_circle_outline,
                    label: 'Kekurangan',
                    value: _formatCurrency(shortage),
                    valueColor: Colors.red,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Button
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                label: 'Mengerti',
                color: Colors.red,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

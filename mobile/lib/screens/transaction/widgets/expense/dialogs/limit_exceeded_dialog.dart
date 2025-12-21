import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class LimitCheckResult {
  final String type;
  final String limitName;
  final double currentSpent;
  final double newAmount;
  final double limit;
  final double exceeded;

  LimitCheckResult({
    required this.type,
    required this.limitName,
    required this.currentSpent,
    required this.newAmount,
    required this.limit,
    required this.exceeded,
  });
}

class LimitExceededDialog extends StatelessWidget {
  final LimitCheckResult result;

  const LimitExceededDialog({
    super.key,
    required this.result,
  });

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // Format ringkas untuk angka besar
  String _formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 100000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return _formatCurrency(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness. dark;
    final color = result.type == 'daily' ? Colors.blue : Colors.purple;
    final percentage = result.limit > 0
        ? ((result.currentSpent + result.newAmount) / result.limit * 100)
        : 0.0;

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
            // Icon with pulse effect
            Container(
              width: 72,
              height:  72,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape. circle,
              ),
              child: const Icon(
                Icons. warning_rounded,
                color: Colors.orange,
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Limit Terlampaui! ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),

            const SizedBox(height:  4),

            // Limit Type Badge
            Container(
              padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color. withOpacity(0.1),
                borderRadius: BorderRadius. circular(20),
              ),
              child:  Text(
                result.limitName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress Visual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ?  Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child:  Column(
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value:  (percentage / 100).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        percentage > 100 ? Colors.red : Colors. orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}% terpakai',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: percentage > 100 ? Colors.red : Colors.orange,
                        ),
                      ),
                      Text(
                        'Limit: ${_formatCompact(result.limit)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Details
                  _DetailRow(
                    label: 'Sudah Terpakai',
                    value: _formatCompact(result.currentSpent),
                    color: Colors.grey[600]!,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Pengeluaran Baru',
                    value: '+ ${_formatCompact(result.newAmount)}',
                    color:  Colors.orange,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Colors.grey[300], height: 1),
                  ),
                  _DetailRow(
                    label: 'Melebihi Limit',
                    value: _formatCompact(result.exceeded),
                    color: Colors.red,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:  Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lanjutkan hanya jika ini pengeluaran darurat',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors. orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    label: 'Batal',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator. pop(context, false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Lanjutkan',
                    icon: Icons.emergency_rounded,
                    color: Colors. orange,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    required this. color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:  [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:  14,
            fontWeight:  isBold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:  150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 :  1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets. symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize:  14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this. color,
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
        transformAlignment: Alignment. center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
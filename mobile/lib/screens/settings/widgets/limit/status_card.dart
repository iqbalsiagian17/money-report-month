import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LimitStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final double spent;
  final double limit;
  final double percentage;
  final Function(bool) onToggle;
  final VoidCallback onEditLimit;
  final bool isDark;
  final String? extraInfo;

  const LimitStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isEnabled,
    required this.spent,
    required this.limit,
    required this.percentage,
    required this.onToggle,
    required this.onEditLimit,
    required this.isDark,
    this.extraInfo,
  });

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    Color progressColor;
    if (percentage < 50) {
      progressColor = Colors.green;
    } else if (percentage < 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),

          if (extraInfo != null) ...[
            const SizedBox(height: 12),
            _buildExtraInfo(),
          ],

          if (isEnabled) ...[
            const SizedBox(height: 20),
            _buildProgress(progressColor),
            const SizedBox(height: 12),
            _buildAmountInfo(),
            const SizedBox(height: 16),
            _buildEditButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: onToggle,
          activeColor: color,
        ),
      ],
    );
  }

  Widget _buildExtraInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        extraInfo!,
        style: TextStyle(
          fontSize: 12,
          color: Colors.orange[700],
        ),
      ),
    );
  }

  Widget _buildProgress(Color progressColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terpakai',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terpakai',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              _formatCurrency(spent),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Sisa',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              _formatCurrency((limit - spent).clamp(0, limit)),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: (limit - spent) > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: onEditLimit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              'Ubah Limit:  ${_formatCurrency(limit)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

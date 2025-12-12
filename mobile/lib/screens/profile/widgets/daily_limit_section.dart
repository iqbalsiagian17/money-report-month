import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DailyLimitSection extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final TextEditingController limitController;

  const DailyLimitSection({
    super.key,
    required this.isEnabled,
    required this.onToggle,
    required this.limitController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Header Row
          _buildHeaderRow(context, isDark),

          // Limit Input (shown when enabled)
          if (isEnabled) ...[
            const SizedBox(height: 20),
            _buildLimitInput(context, isDark),
            const SizedBox(height: 12),
            _buildInfoBox(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.savings_rounded,
            color: Colors.orange,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Limit Pengeluaran Harian',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Batasi pengeluaran per hari',
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
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildLimitInput(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Limit Per Hari',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: limitController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            prefixText: 'Rp ',
            hintText: '100000',
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: isEnabled
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan limit harian';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Limit harus lebih dari 0';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Jika melebihi limit, akan ada opsi "Darurat" untuk melanjutkan.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

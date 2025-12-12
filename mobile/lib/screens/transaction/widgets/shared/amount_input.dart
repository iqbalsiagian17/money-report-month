import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'currency_input_formatter.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color color;
  final String? Function(String?)? validator;

  const AmountInput({
    super.key,
    required this.controller,
    required this.label,
    required this.color,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: color.withOpacity(0.3)),
            ),
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  final amount = CurrencyInputFormatter.getNumericValue(value);
                  if (amount <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }
}

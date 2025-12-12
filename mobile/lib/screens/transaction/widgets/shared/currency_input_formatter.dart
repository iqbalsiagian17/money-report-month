import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hapus semua karakter non-digit
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse ke integer dan format ulang
    final value = int.tryParse(digitsOnly) ?? 0;
    final formatted = _formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Mengambil nilai numerik dari text yang sudah diformat
  static double getNumericValue(String formattedText) {
    if (formattedText.isEmpty) return 0;
    final digitsOnly = formattedText.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(digitsOnly) ?? 0;
  }
}

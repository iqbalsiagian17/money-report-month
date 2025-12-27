import 'package:flutter/material.dart';
import 'package:money_report_monthly/widgets/snack_helper.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class SetPinDialog extends StatefulWidget {
  const SetPinDialog({super.key});

  @override
  State<SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<SetPinDialog> {
  String _pin = '';
  String _confirmPin = '';
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _step == 1 ? 'Buat PIN Baru' : 'Konfirmasi PIN',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _step == 1 ? 'Masukkan 6 digit PIN' : 'Masukkan ulang PIN Anda',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildPinIndicator(),
            const SizedBox(height: 24),
            _buildPinKeypad(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinIndicator() {
    final currentPin = _step == 1 ? _pin : _confirmPin;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < currentPin.length;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isFilled ? Theme.of(context).primaryColor : Colors.transparent,
            border: Border.all(
              color:
                  isFilled ? Theme.of(context).primaryColor : Colors.grey[400]!,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPinKeypad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 52, height: 52),
            _buildPinKey('0'),
            SizedBox(
              width: 52,
              height: 52,
              child: IconButton(
                onPressed: _onBackspace,
                icon: Icon(
                  Icons.backspace_outlined,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildPinKey(key)).toList(),
    );
  }

  Widget _buildPinKey(String value) {
    return SizedBox(
      width: 52,
      height: 52,
      child: TextButton(
        onPressed: () => _onKeyPressed(value),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.grey[100],
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_step == 1) {
        if (_pin.length < 6) _pin += key;
        if (_pin.length == 6) _step = 2;
      } else {
        if (_confirmPin.length < 6) _confirmPin += key;
        if (_confirmPin.length == 6) {
          _validateAndSave();
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_step == 1 && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_step == 2 && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
    });
  }

  void _validateAndSave() {
    if (_pin == _confirmPin) {
      context.read<AuthProvider>().setPin(_pin);
      Navigator.pop(context);
      SnackHelper.success(
        context,
        'PIN berhasil dibuat! ',
      );
    } else {
      setState(() {
        _confirmPin = '';
      });
      SnackHelper.error(
        context,
        'PIN tidak cocok, coba lagi',
      );
    }
  }
}

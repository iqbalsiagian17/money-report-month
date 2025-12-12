import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: Text(_step == 1 ? 'Buat PIN Baru' : 'Konfirmasi PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _step == 1 ? 'Masukkan 6 digit PIN' : 'Masukkan ulang PIN Anda',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildPinIndicator(),
          const SizedBox(height: 24),
          _buildPinKeypad(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  Widget _buildPinIndicator() {
    final currentPin = _step == 1 ? _pin : _confirmPin;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentPin.length
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildPinKeypad() {
    return Column(
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
            const SizedBox(width: 56),
            _buildPinKey('0'),
            SizedBox(
              width: 56,
              height: 56,
              child: IconButton(
                onPressed: _onBackspace,
                icon: const Icon(Icons.backspace_outlined),
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
      width: 56,
      height: 56,
      child: TextButton(
        onPressed: () => _onKeyPressed(value),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.grey[200],
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN berhasil dibuat! '),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _confirmPin = '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN tidak cocok, coba lagi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

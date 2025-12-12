import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackToExit extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration duration;

  const DoubleBackToExit({
    super.key,
    required this.child,
    this.message = 'Tekan sekali lagi untuk keluar',
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();

        // Cek apakah tombol back ditekan dalam durasi yang ditentukan
        if (_lastBackPressed != null &&
            now.difference(_lastBackPressed!) < widget.duration) {
          // Keluar dari aplikasi
          SystemNavigator.pop();
          return;
        }

        // Update waktu terakhir back ditekan
        _lastBackPressed = now;

        // Tampilkan snackbar
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.exit_to_app_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(widget.message),
              ],
            ),
            duration: widget.duration,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: widget.child,
    );
  }
}

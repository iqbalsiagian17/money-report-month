import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;
  final bool useDialog;
  final String snackBarMessage;
  final Duration snackBarDuration;

  const ExitConfirmationWrapper({
    super.key,
    required this.child,
    this.useDialog = false,
    this.snackBarMessage = 'Tekan sekali lagi untuk keluar',
    this.snackBarDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    if (useDialog) {
      return _DialogExitWrapper(child: child);
    }
    return _DoubleBackWrapper(
      message: snackBarMessage,
      duration: snackBarDuration,
      child: child,
    );
  }
}

// Double Back Implementation
class _DoubleBackWrapper extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration duration;

  const _DoubleBackWrapper({
    required this.child,
    required this.message,
    required this.duration,
  });

  @override
  State<_DoubleBackWrapper> createState() => _DoubleBackWrapperState();
}

class _DoubleBackWrapperState extends State<_DoubleBackWrapper> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();

        if (_lastBackPressed != null &&
            now.difference(_lastBackPressed!) < widget.duration) {
          SystemNavigator.pop();
          return;
        }

        _lastBackPressed = now;

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            duration: widget.duration,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Dialog Implementation
class _DialogExitWrapper extends StatelessWidget {
  final Widget child;

  const _DialogExitWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showExitDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Keluar Aplikasi? '),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi Money Report?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

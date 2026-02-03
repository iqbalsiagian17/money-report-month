import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/custom_notification.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart'; // ✅ Import NotificationService

// Import widgets
import 'widgets/notification/notification_section.dart';
import 'widgets/notification/empty_custom.dart';
import 'widgets/notification/notification_dialog.dart';
import 'widgets/notification/info_tip.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isSendingTest = false;

  Future<void> _sendTestNotification() async {
    if (_isSendingTest) return;

    setState(() => _isSendingTest = true);
    HapticFeedback.lightImpact();

    try {
      // ✅ Coba salah satu dari opsi berikut sesuai NotificationService Anda:

      // Opsi 1: showInstantNotification
      await NotificationService().showInstantNotification(
        title: '🔔 Test Notifikasi',
        body: 'Notifikasi berhasil! Pengaturan notifikasi Anda sudah benar.',
      );

      // Opsi 2: show
      // await NotificationService().show(
      //   id: 99999,
      //   title: '🔔 Test Notifikasi',
      //   body: 'Notifikasi berhasil! Pengaturan notifikasi Anda sudah benar.',
      // );

      // Opsi 3: displayNotification
      // await NotificationService().displayNotification(
      //   title: '🔔 Test Notifikasi',
      //   body: 'Notifikasi berhasil! Pengaturan notifikasi Anda sudah benar.',
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Notifikasi test berhasil dikirim!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingTest = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Notifikasi'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          // ✅ Tombol Test Notifikasi di AppBar
          actions: [
            IconButton(
              onPressed: _isSendingTest ? null : _sendTestNotification,
              tooltip: 'Test Notifikasi',
              icon: _isSendingTest
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : Icon(
                      Icons.notifications_active_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Default Notifications
                _buildSectionHeader(title: 'NOTIFIKASI WAJIB'),
                const SizedBox(height: 12),
                NotificationSection(
                  notifications: provider.defaultNotifications,
                  isDark: isDark,
                  isDefault: true,
                  onToggle: (id, enabled) {
                    provider.toggleNotification(id, enabled);
                  },
                ),

                const SizedBox(height: 28),

                // Custom Notifications Header
                _buildCustomHeader(context),
                const SizedBox(height: 12),

                // Custom Notifications List
                if (provider.customNotifications.isEmpty)
                  EmptyCustomNotification(isDark: isDark)
                else
                  NotificationSection(
                    notifications: provider.customNotifications,
                    isDark: isDark,
                    isDefault: false,
                    onToggle: (id, enabled) {
                      provider.toggleNotification(id, enabled);
                    },
                    onEdit: (notif) => _showNotificationDialog(context, notif),
                    onDelete: (notif) => _confirmDelete(context, notif),
                  ),

                const SizedBox(height: 24),

                // Info Tip
                const NotificationInfoTip(),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildSectionHeader({required String title}) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey[500],
      letterSpacing: 1,
    ),
  );
}

Widget _buildCustomHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'NOTIFIKASI CUSTOM',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 1,
        ),
      ),
      GestureDetector(
        onTap: () => _showNotificationDialog(context, null),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Tambah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

void _showNotificationDialog(
    BuildContext context, CustomNotification? existing) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NotificationDialog(existing: existing),
  );
}

void _confirmDelete(BuildContext context, CustomNotification notif) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Notifikasi?'),
      content: Text('Notifikasi "${notif.title}" akan dihapus.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<NotificationProvider>().deleteNotification(notif.id);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}

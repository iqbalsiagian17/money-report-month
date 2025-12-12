import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/custom_notification.dart';
import '../../providers/notification_provider.dart';

// Import widgets
import 'widgets/notification/notification_section.dart';
import 'widgets/notification/empty_custom.dart';
import 'widgets/notification/notification_dialog.dart';
import 'widgets/notification/info_tip.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // ANDROID
        statusBarBrightness: Brightness.light, // IOS
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Notifikasi'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Default Notifications
                _buildSectionHeader(
                  title: 'NOTIFIKASI WAJIB',
                ),
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
              ],
            );
          },
        ),
      ),
    );
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
        title: const Text('Hapus Notifikasi? '),
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
}

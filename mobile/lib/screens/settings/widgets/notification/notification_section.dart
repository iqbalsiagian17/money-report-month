import 'package:flutter/material.dart';
import '../../../../models/custom_notification.dart';
import 'notification_tile.dart';

class NotificationSection extends StatelessWidget {
  final List<CustomNotification> notifications;
  final bool isDark;
  final bool isDefault;
  final Function(String id, bool enabled) onToggle;
  final Function(CustomNotification)? onEdit;
  final Function(CustomNotification)? onDelete;

  const NotificationSection({
    super.key,
    required this.notifications,
    required this.isDark,
    required this.isDefault,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: isDark ? Colors.grey[800] : Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return NotificationTile(
            notification: notif,
            isDark: isDark,
            isDefault: isDefault,
            onToggle: (enabled) => onToggle(notif.id, enabled),
            onEdit: isDefault ? null : () => onEdit?.call(notif),
            onDelete: isDefault ? null : () => onDelete?.call(notif),
          );
        },
      ),
    );
  }
}

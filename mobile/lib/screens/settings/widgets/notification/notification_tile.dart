import 'package:flutter/material.dart';
import '../../../../models/custom_notification.dart';

class NotificationTile extends StatelessWidget {
  final CustomNotification notification;
  final bool isDark;
  final bool isDefault;
  final Function(bool) onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isDark,
    required this.isDefault,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildLeading(context),
      title: Text(
        notification.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        notification.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      trailing: _buildTrailing(context),
      onLongPress: !isDefault && onDelete != null ? onDelete : null,
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: (isDefault ? Colors.orange : Theme.of(context).primaryColor)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          notification.timeFormatted,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDefault ? Colors.orange : Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDefault && onEdit != null)
          IconButton(
            icon: Icon(Icons.edit_rounded, size: 20, color: Colors.grey[500]),
            onPressed: onEdit,
          ),
        Switch(
          value: notification.isEnabled,
          onChanged: onToggle,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}

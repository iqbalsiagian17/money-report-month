import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/custom_notification.dart';
import '../../../../providers/notification_provider.dart';

class NotificationDialog extends StatefulWidget {
  final CustomNotification? existing;

  const NotificationDialog({
    super.key,
    this.existing,
  });

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
    _messageController =
        TextEditingController(text: widget.existing?.message ?? '');
    _selectedTime = widget.existing != null
        ? TimeOfDay(
            hour: widget.existing!.hour, minute: widget.existing!.minute)
        : const TimeOfDay(hour: 12, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            const SizedBox(height: 24),
            _buildTitle(isDark),
            const SizedBox(height: 24),
            _buildTimePicker(context, isDark),
            const SizedBox(height: 16),
            _buildTitleField(isDark),
            const SizedBox(height: 16),
            _buildMessageField(isDark),
            const SizedBox(height: 24),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      widget.existing == null ? 'Tambah Notifikasi' : 'Edit Notifikasi',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              'Jam: ${_selectedTime.format(context)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.edit_rounded,
              size: 18,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(bool isDark) {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Judul',
        hintText: 'Pengingat Belanja',
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildMessageField(bool isDark) {
    return TextField(
      controller: _messageController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Pesan',
        hintText: 'Hai {nama}, jangan lupa catat belanjamu! ',
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _saveNotification(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveNotification(BuildContext context) {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan pesan harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<NotificationProvider>();

    if (widget.existing == null) {
      provider.addNotification(
        title: _titleController.text,
        message: _messageController.text,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
    } else {
      widget.existing!.title = _titleController.text;
      widget.existing!.message = _messageController.text;
      widget.existing!.hour = _selectedTime.hour;
      widget.existing!.minute = _selectedTime.minute;
      provider.updateNotification(widget.existing!);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existing == null
            ? 'Notifikasi ditambahkan!'
            : 'Notifikasi diupdate! '),
        backgroundColor: Colors.green,
      ),
    );
  }
}

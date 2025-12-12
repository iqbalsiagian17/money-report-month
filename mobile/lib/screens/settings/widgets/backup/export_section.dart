import 'package:flutter/material.dart';

class ExportSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onExportToFile;
  final VoidCallback onExportAndShare;

  const ExportSection({
    super.key,
    required this.isLoading,
    required this.onExportToFile,
    required this.onExportAndShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPORT DATA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _ExportTile(
                icon: Icons.upload_file,
                iconColor: Colors.green,
                title: 'Export ke File',
                subtitle: 'Simpan backup ke penyimpanan',
                onTap: isLoading ? null : onExportToFile,
              ),
              const Divider(height: 1),
              _ExportTile(
                icon: Icons.share,
                iconColor: Colors.blue,
                title: 'Export & Bagikan',
                subtitle: 'Bagikan file backup via aplikasi lain',
                onTap: isLoading ? null : onExportAndShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ExportTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

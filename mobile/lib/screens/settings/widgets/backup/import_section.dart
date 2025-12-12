import 'package:flutter/material.dart';

class ImportSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onImport;

  const ImportSection({
    super.key,
    required this.isLoading,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IMPORT DATA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.download, color: Colors.orange.shade700),
            ),
            title: const Text('Import dari File'),
            subtitle: const Text('Restore data dari file backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: isLoading ? null : onImport,
          ),
        ),
      ],
    );
  }
}

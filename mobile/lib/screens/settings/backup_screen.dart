import 'package:flutter/material.dart';
import '../../services/backup_service.dart';

// Import widgets
import 'widgets/backup/info_card.dart';
import 'widgets/backup/export_section.dart';
import 'widgets/backup/import_section.dart';
import 'widgets/backup/warning_card.dart';
import 'widgets/backup/import_success_dialog.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;
  String? _lastBackupPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          BackupInfoCard(
            icon: Icons.info_outline,
            text:
                'Backup data Anda secara berkala untuk mencegah kehilangan data.',
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 24),

          // Export Section
          ExportSection(
            isLoading: _isLoading,
            onExportToFile: _exportToFile,
            onExportAndShare: _exportAndShare,
          ),
          const SizedBox(height: 24),

          // Import Section
          ImportSection(
            isLoading: _isLoading,
            onImport: _importFromFile,
          ),
          const SizedBox(height: 24),

          // Warning Card
          const WarningCard(
            title: 'Perhatian!',
            message:
                'Import akan mengganti SEMUA data yang ada saat ini.  Pastikan Anda sudah membuat backup sebelum melakukan import.',
          ),

          // Last Backup Info
          if (_lastBackupPath != null) ...[
            const SizedBox(height: 24),
            _LastBackupCard(path: _lastBackupPath!),
          ],

          // Loading Indicator
          if (_isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Future<void> _exportToFile() async {
    setState(() => _isLoading = true);

    try {
      final path = await BackupService().exportAndSaveFile();

      if (path != null) {
        setState(() => _lastBackupPath = path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Backup berhasil disimpan! '),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        _showError('Gagal membuat backup');
      }
    } catch (e) {
      _showError('Error:  $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportAndShare() async {
    setState(() => _isLoading = true);

    try {
      final success = await BackupService().exportAndShare();
      if (!success && mounted) {
        _showError('Gagal membagikan backup');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromFile() async {
    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await BackupService().importFromFile();

      if (mounted) {
        if (result.success) {
          showDialog(
            context: context,
            builder: (context) => ImportSuccessDialog(stats: result.stats),
          );
        } else {
          _showError(result.message);
        }
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Import'),
        content: const Text(
          'Import akan mengganti SEMUA data yang ada saat ini.\n\n'
          'Apakah Anda yakin ingin melanjutkan?',
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
            child: const Text('Ya, Import'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _LastBackupCard extends StatelessWidget {
  final String path;

  const _LastBackupCard({required this.path});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backup Terakhir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              path,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

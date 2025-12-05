import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/backup_service.dart';

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
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Backup data Anda secara berkala untuk mencegah kehilangan data.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Export Section
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
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.upload_file, color: Colors.green.shade700),
                  ),
                  title: const Text('Export ke File'),
                  subtitle: const Text('Simpan backup ke penyimpanan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _isLoading ? null : _exportToFile,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.share, color: Colors.blue.shade700),
                  ),
                  title: const Text('Export & Bagikan'),
                  subtitle: const Text('Bagikan file backup via aplikasi lain'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _isLoading ? null : _exportAndShare,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Import Section
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
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.download, color: Colors.orange.shade700),
              ),
              title: const Text('Import dari File'),
              subtitle: const Text('Restore data dari file backup'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _isLoading ? null : _importFromFile,
            ),
          ),
          const SizedBox(height: 24),

          // Warning Card
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perhatian! ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Import akan mengganti SEMUA data yang ada saat ini.Pastikan Anda sudah membuat backup sebelum melakukan import.',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Last Backup Info
          if (_lastBackupPath != null) ...[
            const SizedBox(height: 24),
            Card(
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
                      _lastBackupPath! ,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Loading Indicator
          if (_isLoading) ...[
            const SizedBox(height: 24),
            const Center(
              child: CircularProgressIndicator(),
            ),
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
              content: Text('Backup berhasil disimpan! '),
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
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportAndShare() async {
    setState(() => _isLoading = true);

    try {
      final success = await BackupService().exportAndShare();
      
      if (! success && mounted) {
        _showError('Gagal membagikan backup');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromFile() async {
    // Konfirmasi dulu
    final confirm = await showDialog<bool>(
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

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await BackupService().importFromFile();
      
      if (mounted) {
        if (result.success) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Import Berhasil!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data berhasil di-import:'),
                  const SizedBox(height: 12),
                  if (result.stats != null) ...[
                    _buildStatRow('Dompet', result.stats!.wallets),
                    _buildStatRow('Transaksi', result.stats!.transactions),
                    _buildStatRow('Kategori', result.stats!.categories),
                    _buildStatRow('Tabungan', result.stats!.savings),
                    _buildStatRow('Budget', result.stats! .budgets),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Silakan restart aplikasi untuk melihat perubahan.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
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

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$count item',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
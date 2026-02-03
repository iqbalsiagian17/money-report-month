import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/backup_service.dart';
import '../../widgets/bottom_sheet/app_bottom_sheet.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info Card
                _buildInfoCard(),
                const SizedBox(height: 24),

                // Export Section
                _buildSectionTitle('EXPORT DATA'),
                const SizedBox(height: 12),
                _buildExportCard(),
                const SizedBox(height: 24),

                // Import Section
                _buildSectionTitle('IMPORT DATA'),
                const SizedBox(height: 12),
                _buildImportCard(),
                const SizedBox(height: 24),

                // Warning Card
                _buildWarningCard(),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Backup data secara berkala untuk mencegah kehilangan data.  File akan disimpan di folder Downloads.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildExportCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Export to Downloads
          _buildTile(
            icon: Icons.download_rounded,
            iconColor: Colors.green,
            title: 'Simpan Backup',
            subtitle: 'Simpan ke folder Downloads',
            onTap: _exportToDownloads,
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          // Share
          _buildTile(
            icon: Icons.share_rounded,
            iconColor: Colors.blue,
            title: 'Bagikan Backup',
            subtitle: 'Kirim via aplikasi lain',
            onTap: _exportAndShare,
          ),
        ],
      ),
    );
  }

  Widget _buildImportCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: _buildTile(
        icon: Icons.upload_rounded,
        iconColor: Colors.orange,
        title: 'Import dari File',
        subtitle: 'Restore data dari backup',
        onTap: _importFromFile,
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perhatian! ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Import akan mengganti SEMUA data yang ada.  Pastikan sudah membuat backup sebelum import.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  // ============ EXPORT METHODS ============

  Future<void> _exportToDownloads() async {
    setState(() => _isLoading = true);

    try {
      final result = await BackupService().exportAndSaveFile();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        _showExportSuccessSheet(result);
      } else {
        _showErrorSheet(result.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSheet('Gagal membuat backup: $e');
    }
  }

  Future<void> _exportAndShare() async {
    setState(() => _isLoading = true);

    try {
      final success = await BackupService().exportAndShare();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!success) {
        _showErrorSheet('Gagal membagikan backup');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSheet('Error: $e');
    }
  }

  // ============ IMPORT METHODS ============

  Future<void> _importFromFile() async {
    // Show confirm dialog first
    final confirmed = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Import Data? ',
      message:
          'Import akan mengganti SEMUA data yang ada saat ini.\n\nApakah Anda yakin ingin melanjutkan?',
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      isDanger: true,
      confirmText: 'Ya, Import',
      cancelText: 'Batal',
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final result = await BackupService().importFromFile();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        _showImportSuccessSheet(result.stats);
      } else if (result.message != 'Tidak ada file dipilih') {
        _showErrorSheet(result.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSheet('Gagal import: $e');
    }
  }

  // ============ BOTTOM SHEETS ============

  void _showExportSuccessSheet(BackupResult result) {
    AppBottomSheet.show(
      context: context,
      title: 'Backup Berhasil!',
      subtitle: 'File backup telah disimpan',
      child: Column(
        children: [
          // Success Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),

          // File Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // File name
                Row(
                  children: [
                    const Icon(Icons.insert_drive_file_rounded,
                        size: 20, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.fileName ?? 'backup.json',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Path
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.folder_rounded,
                        size: 20, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.filePath ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats if available
          if (result.stats != null) ...[
            _buildStatsGrid(result.stats!),
            const SizedBox(height: 24),
          ],

          // OK Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Selesai',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportSuccessSheet(ImportStats? stats) {
    AppBottomSheet.show(
      context: context,
      title: 'Import Berhasil!',
      subtitle: 'Data berhasil di-import',
      isDismissible: false,
      child: Column(
        children: [
          // Success Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          if (stats != null) ...[
            _buildImportStatsGrid(stats),
            const SizedBox(height: 24),
          ],

          // Warning about restart
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh_rounded,
                    size: 20, color: Colors.orange.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Aplikasi akan restart untuk menerapkan perubahan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Restart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restartApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Restart Aplikasi',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSheet(String message) {
    AppBottomSheet.showError(
      context: context,
      title: 'Gagal',
      message: message,
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Dompet', stats['totalWallets'] ?? 0,
                  Icons.account_balance_wallet_rounded, Colors.blue),
              _buildStatItem('Transaksi', stats['totalTransactions'] ?? 0,
                  Icons.swap_horiz_rounded, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('Kategori', stats['totalCategories'] ?? 0,
                  Icons.category_rounded, Colors.purple),
              _buildStatItem('Tabungan', stats['totalSavings'] ?? 0,
                  Icons.savings_rounded, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportStatsGrid(ImportStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Dompet', stats.wallets,
                  Icons.account_balance_wallet_rounded, Colors.blue),
              _buildStatItem('Transaksi', stats.transactions,
                  Icons.swap_horiz_rounded, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('Kategori', stats.categories,
                  Icons.category_rounded, Colors.purple),
              _buildStatItem('Tabungan', stats.savings, Icons.savings_rounded,
                  Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                  'Rutin', stats.recurring, Icons.repeat_rounded, Colors.teal),
              _buildStatItem('Profil', stats.userProfiles, Icons.person_rounded,
                  Colors.indigo),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                  'Todo', stats.todos, Icons.checklist_rounded, Colors.pink),
              _buildStatItem('Notifikasi', stats.notifications,
                  Icons.notifications_rounded, Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ NEW: Debts row
          Row(
            children: [
              _buildStatItem('Hutang/Piutang', stats.debts,
                  Icons.receipt_long_rounded, Colors.deepOrange),
              const Expanded(child: SizedBox()), // Empty spacer
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.summarize_rounded, size: 18),
              const SizedBox(width: 8),
              const Text('Total:  ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats.total} item',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _restartApp() {
    Navigator.pop(context);
    SystemNavigator.pop();
  }
}

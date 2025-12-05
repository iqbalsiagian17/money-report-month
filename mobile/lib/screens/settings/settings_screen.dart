import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_report_monthly/providers/category_provider.dart';
import 'package:money_report_monthly/providers/wallet_provider.dart';
import 'package:money_report_monthly/screens/settings/backup_screen.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Money Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Monthly Edition',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Appearance
              const Text(
                'Tampilan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                children: [
                  SwitchListTile(
                    title: const Text('Mode Gelap'),
                    subtitle: const Text('Aktifkan dark mode'),
                    secondary: const Icon(Icons.dark_mode),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Warna Tema'),
                    subtitle: const Text('Pilih warna utama aplikasi'),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () => _showColorPicker(context, themeProvider),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Security
              const Text(
                'Keamanan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                children: [
                  SwitchListTile(
                    title: const Text('Kunci Aplikasi'),
                    subtitle: Text(authProvider.isLockEnabled
                        ? 'Aplikasi terkunci dengan PIN'
                        : 'Nonaktif'),
                    secondary: const Icon(Icons.lock),
                    value: authProvider.isLockEnabled,
                    onChanged: (value) {
                      if (value) {
                        _showSetPinDialog(context);
                      } else {
                        authProvider.removePin();
                      }
                    },
                  ),
                  if (authProvider.isLockEnabled) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Sidik Jari'),
                      subtitle: const Text('Gunakan fingerprint untuk membuka'),
                      secondary: const Icon(Icons.fingerprint),
                      value: authProvider.useBiometric,
                      onChanged: (value) => authProvider.setUseBiometric(value),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.password),
                      title: const Text('Ubah PIN'),
                      onTap: () => _showChangePinDialog(context),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Data Management
              const Text(
                'Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                children: [
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Kelola Kategori'),
                    subtitle: const Text('Tambah, edit, hapus kategori'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.categories),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text('Kelola Dompet'),
                    subtitle: const Text('Atur dompet dan saldo'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.wallets),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: const Text('Transaksi Rutin'),
                    subtitle: const Text('Atur pemasukan/pengeluaran otomatis'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.recurring),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.backup, color: Colors.purple.shade700),
                    ),
                    title: const Text('Backup & Restore'),
                    subtitle: const Text('Export dan import data'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BackupScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notifications
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                children: [
                  SwitchListTile(
                    title: const Text('Pengingat Harian'),
                    subtitle: const Text('Reminder jam 10, 13, 17, 20'),
                    secondary: const Icon(Icons.notifications),
                    value: true,
                    onChanged: (value) async {
                      if (value) {
                        await NotificationService().scheduleDailyReminders();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengingat harian diaktifkan'),
                          ),
                        );
                      } else {
                        await NotificationService().cancelAll();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengingat harian dinonaktifkan'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About
              const Text(
                'Tentang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Versi Aplikasi'),
                    subtitle: const Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Dibuat dengan'),
                    subtitle: const Text('Flutter & Hive'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text(
                      'Reset Semua Data',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('Hapus semua data aplikasi'),
                    onTap: () => _confirmResetData(context),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna Tema'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: themeProvider.availableColors.map((color) {
            final isSelected = color.value == themeProvider.primaryColor.value;
            return InkWell(
              onTap: () {
                themeProvider.setPrimaryColor(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSetPinDialog(BuildContext context) {
    String pin = '';
    String confirmPin = '';
    int step = 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(step == 1 ? 'Buat PIN Baru' : 'Konfirmasi PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step == 1 ? 'Masukkan 6 digit PIN' : 'Masukkan ulang PIN Anda',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final currentPin = step == 1 ? pin : confirmPin;
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < currentPin.length
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              _buildPinKeypad(
                onKeyPressed: (key) {
                  setState(() {
                    if (step == 1) {
                      if (pin.length < 6) pin += key;
                      if (pin.length == 6) step = 2;
                    } else {
                      if (confirmPin.length < 6) confirmPin += key;
                      if (confirmPin.length == 6) {
                        if (pin == confirmPin) {
                          context.read<AuthProvider>().setPin(pin);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PIN berhasil dibuat!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          confirmPin = '';
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PIN tidak cocok, coba lagi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  });
                },
                onBackspace: () {
                  setState(() {
                    if (step == 1 && pin.isNotEmpty) {
                      pin = pin.substring(0, pin.length - 1);
                    } else if (step == 2 && confirmPin.isNotEmpty) {
                      confirmPin =
                          confirmPin.substring(0, confirmPin.length - 1);
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    _showSetPinDialog(context);
  }

  Widget _buildPinKeypad({
    required Function(String) onKeyPressed,
    required VoidCallback onBackspace,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3']
              .map((e) => _buildPinKey(e, onKeyPressed))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6']
              .map((e) => _buildPinKey(e, onKeyPressed))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9']
              .map((e) => _buildPinKey(e, onKeyPressed))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 56),
            _buildPinKey('0', onKeyPressed),
            SizedBox(
              width: 56,
              height: 56,
              child: IconButton(
                onPressed: onBackspace,
                icon: const Icon(Icons.backspace_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinKey(String value, Function(String) onPressed) {
    return SizedBox(
      width: 56,
      height: 56,
      child: TextButton(
        onPressed: () => onPressed(value),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.grey[200],
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _confirmResetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Semua Data? '),
        content: const Text(
          'Semua data transaksi, dompet, tabungan, dan pengaturan akan dihapus permanen.Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear all Hive boxes
              await Hive.box('wallets').clear();
              await Hive.box('transactions').clear();
              await Hive.box('categories').clear();
              await Hive.box('savings').clear();
              await Hive.box('budgets').clear();
              await Hive.box('recurring').clear();
              await Hive.box('settings').clear();

              // Re-initialize default data
              await context.read<WalletProvider>().initDefaultWallets();
              await context.read<CategoryProvider>().initDefaultCategories();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua data berhasil direset'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

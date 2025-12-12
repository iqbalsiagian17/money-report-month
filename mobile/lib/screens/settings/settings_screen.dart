import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/notification_service.dart';
import 'backup_screen.dart';

// Import widgets
import 'widgets/settings/profile_section.dart';
import 'widgets/settings/setting_card.dart';
import 'widgets/settings/color_picker_dialog.dart';
import 'widgets/settings/pin_dialog.dart';
import 'widgets/settings/reset_data_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;

  String _getLimitSummary(UserProvider userProvider) {
    final parts = <String>[];
    if (userProvider.isDailyLimitEnabled) {
      parts.add('Harian aktif');
    }
    if (userProvider.isWeekendLimitEnabled) {
      parts.add('Weekend aktif');
    }
    if (parts.isEmpty) {
      return 'Belum ada limit aktif';
    }
    return parts.join(' • ');
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // ANDROID
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Consumer3<ThemeProvider, AuthProvider, UserProvider>(
          builder: (context, themeProvider, authProvider, userProvider, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Profile Section
                ProfileSection(userProvider: userProvider),
                const SizedBox(height: 24),

                // Appearance
                const SettingSectionTitle(title: 'Tampilan'),
                const SizedBox(height: 12),
                _buildAppearanceCard(context, themeProvider),
                const SizedBox(height: 24),

                // Security
                const SettingSectionTitle(title: 'Keamanan'),
                const SizedBox(height: 12),
                _buildSecurityCard(context, authProvider),
                const SizedBox(height: 24),

                // Data Management
                const SettingSectionTitle(title: 'Data & Limit'),
                const SizedBox(height: 12),
                _buildDataCard(context, userProvider),
                const SizedBox(height: 24),

                // Notifications
                const SettingSectionTitle(title: 'Notifikasi'),
                const SizedBox(height: 12),
                _buildNotificationCard(context),
                const SizedBox(height: 24),

                // About
                const SettingSectionTitle(title: 'Tentang'),
                const SizedBox(height: 12),
                _buildAboutCard(context),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(
      BuildContext context, ThemeProvider themeProvider) {
    return SettingCard(
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
    );
  }

  Widget _buildSecurityCard(BuildContext context, AuthProvider authProvider) {
    return SettingCard(
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
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSetPinDialog(context),
          ),
        ],
      ],
    );
  }

  Widget _buildDataCard(BuildContext context, UserProvider userProvider) {
    return SettingCard(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune, color: Colors.blue),
          ),
          title: const Text('Pengaturan Limit'),
          subtitle: Text(
            _getLimitSummary(userProvider),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.limitSettings),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Kelola Kategori'),
          subtitle: const Text('Tambah, edit, hapus kategori'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.categories),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('Kelola Dompet'),
          subtitle: const Text('Atur dompet dan saldo'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.wallets),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.repeat),
          title: const Text('Transaksi Rutin'),
          subtitle: const Text('Atur pemasukan/pengeluaran otomatis'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.recurring),
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
              MaterialPageRoute(builder: (context) => const BackupScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context) {
    return SettingCard(
      children: [
        SwitchListTile(
          title: const Text('Pengingat Harian'),
          subtitle: const Text('Reminder jam 10, 13, 17, 20'),
          secondary: const Icon(Icons.notifications),
          value: _notificationEnabled,
          onChanged: (value) async {
            setState(() => _notificationEnabled = value);
            if (value) {
              await NotificationService().scheduleDailyReminders();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengingat harian diaktifkan')),
                );
              }
            } else {
              await NotificationService().cancelAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Pengingat harian dinonaktifkan')),
                );
              }
            }
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.edit_notifications),
          title: const Text('Atur Notifikasi Custom'),
          subtitle: const Text('Tambah pengingat sendiri'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.notificationSettings),
        ),
      ],
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return SettingCard(
      children: [
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('Versi Aplikasi'),
          subtitle: Text('1.0.0'),
        ),
        const Divider(height: 1),
        const ListTile(
          leading: Icon(Icons.code),
          title: Text('Dibuat dengan'),
          subtitle: Text('Flutter & Hive'),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Reset Semua Data',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text('Hapus semua data aplikasi'),
          onTap: () => _showResetDialog(context),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(themeProvider: themeProvider),
    );
  }

  void _showSetPinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SetPinDialog(),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ResetDataDialog(),
    );
  }
}

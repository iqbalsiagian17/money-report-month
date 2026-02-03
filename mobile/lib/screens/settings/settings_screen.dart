import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'backup_screen.dart'; // Direct import for backup

// Import widgets
import 'widgets/settings/settings_header.dart';
import 'widgets/settings/settings_tile.dart';
import 'widgets/settings/settings_section.dart';
import 'widgets/settings/settings_options.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer3<ThemeProvider, AuthProvider, UserProvider>(
        builder: (context, themeProvider, authProvider, userProvider, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SettingsHeader(userProvider: userProvider),
              ),

              // Settings Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Settings
                    _QuickSettings(
                      themeProvider: themeProvider,
                      authProvider: authProvider,
                    ),
                    const SizedBox(height: 24),

                    // Data & Management
                    SettingsSection(
                      title: 'Kelola Data',
                      children: [
                        SettingsTile(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: Colors.blue,
                          title: 'Dompet',
                          subtitle: 'Kelola saldo & dompet',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.wallets),
                        ),
                        SettingsTile(
                          icon: Icons.category_rounded,
                          iconColor: Colors.purple,
                          title: 'Kategori',
                          subtitle: 'Atur kategori transaksi',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.categories),
                        ),
                        SettingsTile(
                          icon: Icons.repeat_rounded,
                          iconColor: Colors.orange,
                          title: 'Transaksi Rutin',
                          subtitle: 'Pemasukan & pengeluaran otomatis',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.recurring),
                        ),
                        SettingsTile(
                          icon: Icons.savings_rounded,
                          iconColor: Colors.green,
                          title: 'Target Tabungan',
                          subtitle: 'Kelola goal keuangan',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.savings),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Preferences
                    SettingsSection(
                      title: 'Preferensi',
                      children: [
                        SettingsTile(
                          icon: Icons.tune_rounded,
                          iconColor: Colors.teal,
                          title: 'Pengaturan Limit',
                          subtitle: _getLimitSummary(userProvider),
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.limitSettings),
                        ),
                        SettingsTile(
                          icon: Icons.notifications_rounded,
                          iconColor: Colors.amber,
                          title: 'Notifikasi',
                          subtitle: 'Atur pengingat keuangan',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.notificationSettings),
                        ),
                        SettingsTile(
                          icon: Icons.palette_rounded,
                          iconColor: Colors.pink,
                          title: 'Tampilan',
                          subtitle: 'Tema & warna aplikasi',
                          trailing:
                              _ColorDot(color: themeProvider.primaryColor),
                          onTap: () => SettingsOptions.showAppearance(
                              context, themeProvider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Security & Backup
                    SettingsSection(
                      title: 'Keamanan',
                      children: [
                        SettingsTile(
                          icon: Icons.lock_rounded,
                          iconColor: Colors.indigo,
                          title: 'Kunci Aplikasi',
                          subtitle: authProvider.isLockEnabled
                              ? 'PIN aktif'
                              : 'Nonaktif',
                          trailing: _StatusBadge(
                              isActive: authProvider.isLockEnabled),
                          onTap: () => SettingsOptions.showSecurity(
                              context, authProvider),
                        ),
                        SettingsTile(
                          icon: Icons.receipt_long_rounded,
                          iconColor: Colors.deepOrange,
                          title: 'Hutang & Piutang',
                          subtitle: 'Kelola catatan hutang piutang',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.debts),
                        ),
                        SettingsTile(
                          icon: Icons.backup_rounded,
                          iconColor: Colors.cyan,
                          title: 'Backup & Restore',
                          subtitle: 'Export dan import data',
                          onTap: () {
                            // Direct navigation to BackupScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BackupScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // About
                    SettingsSection(
                      title: 'Lainnya',
                      children: [
                        SettingsTile(
                          icon: Icons.info_rounded,
                          iconColor: Colors.grey,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Versi 1.0.0',
                          onTap: () => SettingsOptions.showAbout(context),
                        ),
                        SettingsTile(
                          icon: Icons.delete_forever_rounded,
                          iconColor: Colors.red,
                          title: 'Reset Data',
                          subtitle: 'Hapus semua data',
                          onTap: () =>
                              SettingsOptions.showResetConfirm(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLimitSummary(UserProvider userProvider) {
    final parts = <String>[];
    if (userProvider.isDailyLimitEnabled) parts.add('Harian');
    if (userProvider.isWeekendLimitEnabled) parts.add('Weekend');
    if (parts.isEmpty) return 'Belum ada limit aktif';
    return '${parts.join(' & ')} aktif';
  }
}

// ================= QUICK SETTINGS =================
// ================= QUICK SETTINGS =================
class _QuickSettings extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AuthProvider authProvider;

  const _QuickSettings({
    required this.themeProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ✅ Gunakan widget dengan animasi
          _AnimatedQuickSettingButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            label: isDark ? 'Light' : 'Dark',
            isActive: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              themeProvider.toggleTheme();
            },
          ),
          _AnimatedQuickSettingButton(
            icon: authProvider.isLockEnabled
                ? Icons.lock_rounded
                : Icons.lock_open_rounded,
            label: authProvider.isLockEnabled ? 'Locked' : 'Unlocked',
            isActive: authProvider.isLockEnabled,
            onTap: () {
              HapticFeedback.lightImpact();
              SettingsOptions.showSecurity(context, authProvider);
            },
          ),
          _AnimatedQuickSettingButton(
            icon: Icons.notifications_rounded,
            label: 'Notif',
            isActive: true,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRoutes.notificationSettings);
            },
          ),
        ],
      ),
    );
  }
}

// ✅ NEW: Animated button dengan transisi smooth
class _AnimatedQuickSettingButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedQuickSettingButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_AnimatedQuickSettingButton> createState() =>
      _AnimatedQuickSettingButtonState();
}

class _AnimatedQuickSettingButtonState
    extends State<_AnimatedQuickSettingButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    widget.icon,
                    key: ValueKey(widget.icon),
                    size: 22,
                    color: widget.isActive
                        ? primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.isActive
                        ? primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HELPER WIDGETS =================
class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'ON' : 'OFF',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

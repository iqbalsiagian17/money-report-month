import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_report_monthly/screens/home/widget/balance_card_advanced_sheet.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/balance_card_provider.dart';
import '../../settings/widgets/settings/settings_options.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: Hive.box<UserProfile>('user_profile').listenable(),
      builder: (context, box, _) {
        final profile = box.isNotEmpty ? box.getAt(0) : null;
        final name = profile?.name ?? 'User';

        final greeting = _getGreeting();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              // AVATAR (CLICKABLE)
              GestureDetector(
                onTap: () {
                  SettingsOptions.showProfile(context, userProvider);
                },
                child: _UserAvatar(photoPath: profile?.photoPath),
              ),

              const SizedBox(width: 14),

              // NAME & GREETING
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting dengan icon
                    Row(
                      children: [
                        Icon(
                          greeting.icon,
                          size: 14,
                          color: greeting.iconColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            greeting.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ✅ EDIT BALANCE CARD BUTTON
              _EditBalanceCardButton(isDark: isDark),
            ],
          ),
        );
      },
    );
  }

  // ================= GREETING BERDASARKAN WAKTU =================
  _GreetingData _getGreeting() {
    final hour = DateTime.now().hour;
    final random = Random();

    // Greeting berdasarkan waktu
    if (hour >= 5 && hour < 12) {
      // Pagi (05:00 - 11:59)
      final morningGreetings = [
        _GreetingData(
          text: 'Selamat pagi',
          icon: Icons.wb_sunny_rounded,
          iconColor: Colors.orange,
        ),
        _GreetingData(
          text: 'Pagi yang cerah',
          icon: Icons.light_mode_rounded,
          iconColor: Colors.amber,
        ),
        _GreetingData(
          text: 'Semangat pagi',
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.deepOrange,
        ),
        _GreetingData(
          text: 'Mulai hari produktif',
          icon: Icons.rocket_launch_rounded,
          iconColor: Colors.blue,
        ),
      ];
      return morningGreetings[random.nextInt(morningGreetings.length)];
    } else if (hour >= 12 && hour < 15) {
      // Siang (12:00 - 14:59)
      final noonGreetings = [
        _GreetingData(
          text: 'Selamat siang',
          icon: Icons.wb_sunny_rounded,
          iconColor: Colors.orange,
        ),
        _GreetingData(
          text: 'Tetap semangat',
          icon: Icons.bolt_rounded,
          iconColor: Colors.amber,
        ),
        _GreetingData(
          text: 'Jangan lupa istirahat',
          icon: Icons.coffee_rounded,
          iconColor: Colors.brown,
        ),
        _GreetingData(
          text: 'Lanjutkan aktivitasmu',
          icon: Icons.trending_up_rounded,
          iconColor: Colors.green,
        ),
      ];
      return noonGreetings[random.nextInt(noonGreetings.length)];
    } else if (hour >= 15 && hour < 18) {
      // Sore (15:00 - 17:59)
      final afternoonGreetings = [
        _GreetingData(
          text: 'Selamat sore',
          icon: Icons.wb_twilight_rounded,
          iconColor: Colors.orange,
        ),
        _GreetingData(
          text: 'Sore yang indah',
          icon: Icons.cloud_rounded,
          iconColor: Colors.blueGrey,
        ),
        _GreetingData(
          text: 'Hampir selesai hari ini',
          icon: Icons.task_alt_rounded,
          iconColor: Colors.green,
        ),
        _GreetingData(
          text: 'Yuk catat transaksi',
          icon: Icons.edit_note_rounded,
          iconColor: Colors.blue,
        ),
      ];
      return afternoonGreetings[random.nextInt(afternoonGreetings.length)];
    } else {
      // Malam (18:00 - 04:59)
      final nightGreetings = [
        _GreetingData(
          text: 'Selamat malam',
          icon: Icons.nightlight_rounded,
          iconColor: Colors.indigo,
        ),
        _GreetingData(
          text: 'Malam yang tenang',
          icon: Icons.bedtime_rounded,
          iconColor: Colors.deepPurple,
        ),
        _GreetingData(
          text: 'Istirahat yang cukup',
          icon: Icons.self_improvement_rounded,
          iconColor: Colors.teal,
        ),
        _GreetingData(
          text: 'Cek keuangan hari ini',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: Colors.green,
        ),
      ];
      return nightGreetings[random.nextInt(nightGreetings.length)];
    }
  }
}

// ================= GREETING DATA CLASS =================
class _GreetingData {
  final String text;
  final IconData icon;
  final Color iconColor;

  _GreetingData({
    required this.text,
    required this.icon,
    required this.iconColor,
  });
}

// ================= EDIT BALANCE CARD BUTTON =================
class _EditBalanceCardButton extends StatelessWidget {
  final bool isDark;

  const _EditBalanceCardButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCustomizeSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[800]
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.grey[700]!
                : Theme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.credit_card_rounded,
              size: 20,
              color: isDark ? Colors.grey[400] : Theme.of(context).primaryColor,
            ),
            // Edit badge
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Update method
  void _showCustomizeSheet(BuildContext context) {
    final provider = context.read<BalanceCardProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AdvancedCustomizeSheet(provider: provider), // ✅ Use advanced
    );
  }
}

// ================= USER AVATAR =================
class _UserAvatar extends StatelessWidget {
  final String? photoPath;

  const _UserAvatar({this.photoPath});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildImage(isDark),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final imageProvider = _imageProvider();

    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        fit: BoxFit.cover,
        width: 48,
        height: 48,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(isDark);
        },
      );
    }

    return _buildPlaceholder(isDark);
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Icon(
        Icons.person_rounded,
        size: 26,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
      ),
    );
  }

  ImageProvider? _imageProvider() {
    if (photoPath == null || photoPath!.isEmpty) return null;

    if (photoPath!.startsWith('http')) {
      return NetworkImage(photoPath!);
    }

    if (photoPath!.startsWith('assets/')) {
      return AssetImage(photoPath!);
    }

    final file = File(photoPath!);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return null;
  }
}

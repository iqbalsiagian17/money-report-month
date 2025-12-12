import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final bool isFirstTime;

  const ProfileHeader({
    super.key,
    required this.isFirstTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 40),

        // Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('👋', style: TextStyle(fontSize: 36)),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Center(
          child: Text(
            isFirstTime ? 'Selamat Datang!' : 'Edit Profil',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Center(
          child: Text(
            isFirstTime
                ? 'Yuk kenalan dulu sebelum mulai'
                : 'Ubah pengaturan profilmu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }
}

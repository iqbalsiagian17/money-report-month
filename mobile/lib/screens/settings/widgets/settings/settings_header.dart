import 'package:flutter/material.dart';
import '../../../../providers/user_provider.dart';
import 'settings_options.dart';
import 'dart:io';

class SettingsHeader extends StatelessWidget {
  final UserProvider userProvider;

  const SettingsHeader({
    super.key,
    required this.userProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      ),
      child: Column(
        children: [
          // Title Row
          Row(
            children: [
              Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              // Profile Avatar
              GestureDetector(
                onTap: () => SettingsOptions.showProfile(context, userProvider),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildAvatar(userProvider),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profile Card
          GestureDetector(
            onTap: () => SettingsOptions.showProfile(context, userProvider),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _buildProfilePreview(userProvider),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProvider.profile?.name ?? 'Pengguna',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap untuk edit profil',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserProvider userProvider) {
    final photoPath = userProvider.profile?.photoPath;

    if (photoPath != null && photoPath.isNotEmpty) {
      return Image.file(
        File(photoPath),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      );
    }

    return Center(
      child: Text(
        _getInitials(userProvider.profile?.name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProfilePreview(UserProvider userProvider) {
    final photoPath = userProvider.profile?.photoPath;

    if (photoPath != null && photoPath.isNotEmpty) {
      return Image.file(
        File(photoPath),
        width: 52,
        height: 52,
        fit: BoxFit.cover,
      );
    }

    return Icon(
      Icons.person_rounded,
      color: Colors.blue,
      size: 26,
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

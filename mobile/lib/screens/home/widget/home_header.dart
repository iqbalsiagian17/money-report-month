import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile.dart';
import '../../../providers/user_provider.dart';
import '../../settings/widgets/settings/settings_options.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: Hive.box<UserProfile>('user_profile').listenable(),
      builder: (context, box, _) {
        final profile = box.isNotEmpty ? box.getAt(0) : null;
        final name = profile?.name ?? 'User';

        // ⬇️ greeting random (tapi konsisten per rebuild)
        final greeting = _randomGreeting();

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

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ================= GREETING RANDOM =================
  String _randomGreeting() {
    final greetings = [
      'Halo 👋',
      'Hai 😊',
      'Selamat datang ✨',
      'Apa kabar hari ini?',
      'Semoga harimu menyenangkan 🌤️',
      'Yuk catat keuangan hari ini 💰',
      'Siap mengatur keuangan? 📊',
      'Tetap hemat ya 😉',
      'Semangat terus 🔥',
      'Selamat beraktivitas 🚀',
      'Jangan lupa catat transaksi 🧾',
      'Keuangan rapi, hidup tenang 😌',
      'Hari baru, catatan baru 📒',
      'Ayo mulai hari produktifmu 💪',
      'Uang terkontrol, hati pun tenang 🧠',
      'Sedikit demi sedikit jadi bukit ⛰️',
      'Catat sekarang, tenang kemudian 🧘',
      'Mulai hari dengan perencanaan 💡',
    ];

    final random = Random();
    return greetings[random.nextInt(greetings.length)];
  }
}

class _UserAvatar extends StatelessWidget {
  final String? photoPath;

  const _UserAvatar({this.photoPath});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: _imageProvider(),
      child: _imageProvider() == null
          ? const Icon(Icons.person, color: Colors.grey)
          : null,
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

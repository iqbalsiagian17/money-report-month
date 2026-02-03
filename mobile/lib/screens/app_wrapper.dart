import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import 'splash_screen.dart';
import 'lock_screen.dart';
import 'home/home_screen.dart';
import 'onboarding/onboarding_welcome_screen.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isHiveReady = false;
  bool _hasOnboarded = false;
  bool _hasUserProfile = false;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    // Ensure boxes are open
    if (!Hive.isBoxOpen('app_state')) {
      await Hive.openBox('app_state');
    }
    if (!Hive.isBoxOpen('user_profile')) {
      await Hive.openBox<UserProfile>('user_profile');
    }

    final appStateBox = Hive.box('app_state');
    final userBox = Hive.box<UserProfile>('user_profile');

    if (mounted) {
      setState(() {
        _hasOnboarded = appStateBox.get('has_onboarded', defaultValue: false);
        _hasUserProfile = userBox.isNotEmpty;
        _isHiveReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Hanya listen ke AuthProvider, BUKAN ThemeProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 1️⃣ Auth belum siap
        if (!authProvider.isInitialized) {
          return const SplashScreen();
        }

        // 2️⃣ Lock screen
        if (authProvider.isLockEnabled && !authProvider.isAuthenticated) {
          return const LockScreen();
        }

        // 3️⃣ Hive belum siap
        if (!_isHiveReady) {
          return const SplashScreen();
        }

        // 4️⃣ Belum onboarding
        if (!_hasOnboarded || !_hasUserProfile) {
          return const OnboardingWelcomeScreen();
        }

        // 5️⃣ Home screen
        return const HomeScreen();
      },
    );
  }
}

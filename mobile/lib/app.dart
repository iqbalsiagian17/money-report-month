import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_report_monthly/models/user_profile.dart';
import 'package:money_report_monthly/screens/app_wrapper.dart';
import 'package:money_report_monthly/screens/onboarding/onboarding_welcome_screen.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/home/home_screen.dart';

class MoneyReportApp extends StatelessWidget {
  const MoneyReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Dompetku',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(themeProvider.primaryColor),
          darkTheme: AppTheme.darkTheme(themeProvider.primaryColor),
          themeMode: themeProvider.themeMode,
          routes: AppRoutes.routes,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,
          home: const AppWrapper(),
        );
      },
    );
  }

  Widget _getHomeScreen(AuthProvider authProvider) {
    // 1️⃣ Splash dulu
    if (!authProvider.isInitialized) {
      return const SplashScreen();
    }

    // 2️⃣ Lock screen
    if (authProvider.isLockEnabled && !authProvider.isAuthenticated) {
      return const LockScreen();
    }

    // 3️⃣ TUNGGU HIVE SIAP
    return FutureBuilder(
      future: _ensureHiveReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        final appStateBox = Hive.box('app_state');
        final userBox = Hive.box<UserProfile>('user_profile');

        final hasOnboarded =
            appStateBox.get('has_onboarded', defaultValue: false);

        if (!hasOnboarded || userBox.isEmpty) {
          return const OnboardingWelcomeScreen();
        }

        return const HomeScreen();
      },
    );
  }

  Future<void> _ensureHiveReady() async {
    if (!Hive.isBoxOpen('app_state')) {
      await Hive.openBox('app_state');
    }
    if (!Hive.isBoxOpen('user_profile')) {
      await Hive.openBox<UserProfile>('user_profile');
    }
  }
}

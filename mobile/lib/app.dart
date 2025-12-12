import 'package:flutter/material.dart';
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
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        return MaterialApp(
          title: 'Money Report Monthly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(themeProvider.primaryColor),
          darkTheme: AppTheme.darkTheme(themeProvider.primaryColor),
          themeMode: themeProvider.themeMode,
          routes: AppRoutes.routes,
          home: _getHomeScreen(authProvider),
        );
      },
    );
  }

  Widget _getHomeScreen(AuthProvider authProvider) {
    if (!authProvider.isInitialized) {
      return const SplashScreen();
    }

    if (authProvider.isLockEnabled && !authProvider.isAuthenticated) {
      return const LockScreen();
    }

    return const HomeScreen();
  }
}

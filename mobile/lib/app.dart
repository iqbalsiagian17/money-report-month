import 'package:flutter/material.dart';
import 'package:money_report_monthly/screens/app_wrapper.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/theme_provider.dart';

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


}

import 'package:flutter/material.dart';
import 'package:money_report_monthly/screens/settings/limit_settings_screen.dart';
import 'package:money_report_monthly/screens/settings/notification_settings_screen.dart';

import '../screens/home/home_screen.dart';
import '../screens/lock_screen.dart';
import '../screens/wallet/wallet_list_screen.dart';
import '../screens/transaction/add_income_screen.dart';
import '../screens/transaction/add_expense_screen.dart';
import '../screens/transaction/transaction_history_screen.dart';
import '../screens/analysis/analysis_screen.dart';
import '../screens/saving/saving_list_screen.dart';
import '../screens/recurring/recurring_screen.dart';
import '../screens/category/category_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String lock = '/lock';
  static const String notificationSettings = '/notification-settings';
  static const String limitSettings = '/limit-settings';
  static const String wallets = '/wallets';
  static const String walletDetail = '/wallet-detail';
  static const String addIncome = '/add-income';
  static const String addExpense = '/add-expense';
  static const String transactions = '/transactions';
  static const String analysis = '/analysis';
  static const String savings = '/savings';
  static const String budget = '/budget';
  static const String recurring = '/recurring';
  static const String categories = '/categories';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    notificationSettings: (context) => const NotificationSettingsScreen(),
    limitSettings: (context) => const LimitSettingsScreen(),
    lock: (context) => const LockScreen(),
    wallets: (context) => const WalletListScreen(),
    addIncome: (context) => const AddIncomeScreen(),
    addExpense: (context) => const AddExpenseScreen(),
    transactions: (context) => const TransactionHistoryScreen(),
    analysis: (context) => const AnalysisScreen(),
    savings: (context) => const SavingListScreen(),
    recurring: (context) => const RecurringScreen(),
    categories: (context) => const CategoryScreen(),
    settings: (context) => const SettingsScreen(),
  };
}

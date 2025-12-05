import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'models/wallet.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'models/saving_goal.dart';
import 'models/budget.dart';
import 'models/recurring_transaction.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/saving_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale for DateFormat (Indonesia)
  await initializeDateFormatting('id_ID', null);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(WalletTypeAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(SavingGoalAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(RecurringTypeAdapter());
  Hive.registerAdapter(RecurringTransactionAdapter());

  // Open Boxes
  await Hive.openBox<Wallet>('wallets');
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<SavingGoal>('savings');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<RecurringTransaction>('recurring');
  await Hive.openBox('settings');

  // Initialize Notifications
  await NotificationService().initialize();
  await NotificationService().scheduleDailyReminders();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SavingProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const MoneyReportApp(),
    ),
  );
}

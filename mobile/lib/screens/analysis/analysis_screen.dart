import 'package:flutter/material.dart';
import 'package:money_report_monthly/models/transaction.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import 'package:flutter/services.dart';

// Import widgets
import 'widgets/period_selector.dart';
import 'widgets/comparison_card.dart';
import 'widgets/income_expense_chart.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/day_of_week_chart.dart';
import 'widgets/statistics_card.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisPeriod _selectedPeriod = AnalysisPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // Dynamic berdasarkan theme
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analisis Keuangan'),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        body: Consumer2<TransactionProvider, CategoryProvider>(
          builder: (context, txProvider, categoryProvider, _) {
            final comparisonData = _getComparisonData(txProvider);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                PeriodSelector(
                  selectedPeriod: _selectedPeriod,
                  onChanged: (period) =>
                      setState(() => _selectedPeriod = period),
                ),
                const SizedBox(height: 20),
                ComparisonCard(
                  data: comparisonData,
                  period: _selectedPeriod,
                ),
                const SizedBox(height: 20),
                StatisticsCard(txProvider: txProvider),
                const SizedBox(height: 20),
                IncomeExpenseChart(
                  income: _selectedPeriod == AnalysisPeriod.weekly
                      ? txProvider.thisWeekIncome
                      : txProvider.thisMonthIncome,
                  expense: _selectedPeriod == AnalysisPeriod.weekly
                      ? txProvider.thisWeekExpense
                      : txProvider.thisMonthExpense,
                ),
                const SizedBox(height: 20),
                CategoryBreakdown(
                  txProvider: txProvider,
                  categoryProvider: categoryProvider,
                ),
                const SizedBox(height: 20),
                DayOfWeekChart(txProvider: txProvider),
                const SizedBox(height: 100),
              ],
            );
          },
        ),
      ),
    );
  }

  ComparisonData _getComparisonData(TransactionProvider txProvider) {
    if (_selectedPeriod == AnalysisPeriod.weekly) {
      return ComparisonData(
        currentIncome: txProvider.thisWeekIncome,
        currentExpense: txProvider.thisWeekExpense,
        previousIncome: txProvider.lastWeekIncome,
        previousExpense: txProvider.lastWeekExpense,
        currentLabel: 'Minggu Ini',
        previousLabel: 'Minggu Lalu',
      );
    } else {
      return ComparisonData(
        currentIncome: txProvider.thisMonthIncome,
        currentExpense: txProvider.thisMonthExpense,
        previousIncome: _getLastMonthIncome(txProvider),
        previousExpense: _getLastMonthExpense(txProvider),
        currentLabel: 'Bulan Ini',
        previousLabel: 'Bulan Lalu',
      );
    }
  }

  double _getLastMonthIncome(TransactionProvider txProvider) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);

    return txProvider.transactions
        .where((t) =>
            t.dateTime.month == lastMonth.month &&
            t.dateTime.year == lastMonth.year &&
            t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double _getLastMonthExpense(TransactionProvider txProvider) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);

    return txProvider.transactions
        .where((t) =>
            t.dateTime.month == lastMonth.month &&
            t.dateTime.year == lastMonth.year &&
            t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }
}

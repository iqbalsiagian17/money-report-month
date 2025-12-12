import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_report_monthly/widgets/bottom_sheet/app_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/user_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../screens/transaction/widgets/shared/currency_input_formatter.dart';

// Widgets
import 'widgets/limit/status_card.dart';
import 'widgets/limit/category_section.dart';
import 'widgets/limit/info_box.dart';
import 'widgets/limit/unlimited_header.dart';

class LimitSettingsScreen extends StatefulWidget {
  const LimitSettingsScreen({super.key});

  @override
  State<LimitSettingsScreen> createState() => _LimitSettingsScreenState();
}

class _LimitSettingsScreenState extends State<LimitSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // ANDROID
        statusBarBrightness: Brightness.light, // IOS
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Limit'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Harian', icon: Icon(Icons.today, size: 20)),
              Tab(text: 'Weekend', icon: Icon(Icons.weekend, size: 20)),
              Tab(text: 'Bebas', icon: Icon(Icons.all_inclusive, size: 20)),
            ],
          ),
        ),
        body: Consumer3<UserProvider, CategoryProvider, TransactionProvider>(
          builder: (context, userProvider, categoryProvider, txProvider, _) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDailyLimitTab(
                  context,
                  userProvider,
                  categoryProvider,
                  txProvider,
                  isDark,
                ),
                _buildWeekendLimitTab(
                  context,
                  userProvider,
                  categoryProvider,
                  txProvider,
                  isDark,
                ),
                _buildUnlimitedTab(
                  context,
                  userProvider,
                  categoryProvider,
                  isDark,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= DAILY =================
  Widget _buildDailyLimitTab(
    BuildContext context,
    UserProvider userProvider,
    CategoryProvider categoryProvider,
    TransactionProvider txProvider,
    bool isDark,
  ) {
    final spent = txProvider.getTodayExpenseByCategories(
      userProvider.dailyLimitCategories,
    );
    final limit = userProvider.dailyLimit;
    final percent = limit > 0 ? (spent / limit * 100).clamp(0.0, 100.0) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LimitStatusCard(
          title: 'Limit Harian',
          subtitle: 'Berlaku setiap hari (Senin - Minggu)',
          icon: Icons.today,
          color: Colors.blue,
          isEnabled: userProvider.isDailyLimitEnabled,
          spent: spent,
          limit: limit,
          percentage: percent,
          onToggle: (value) async {
            if (value && userProvider.dailyLimitCategories.isEmpty) {
              _showWarning(context);
              return;
            }
            await userProvider.toggleDailyLimit(value);
          },
          onEditLimit: () => _showEditLimitBottomSheet(
            context,
            'Limit Harian',
            limit,
            userProvider.setDailyLimit,
          ),
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        LimitCategorySection(
          title: 'Kategori Limit Harian',
          subtitle: 'Kategori yang dihitung dalam limit harian',
          icon: Icons.category,
          color: Colors.blue,
          selectedCategoryIds: userProvider.dailyLimitCategories,
          allCategories: categoryProvider.expenseCategories,
          onCategoryToggle: (id, selected) async {
            selected
                ? await userProvider.addDailyLimitCategory(id)
                : await userProvider.removeDailyLimitCategory(id);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        LimitInfoBox(
          icon: Icons.lightbulb_outline,
          text:
              'Kategori ini akan dihitung dalam limit harian ${_formatCurrency(limit)}/hari.',
          color: Colors.blue,
        ),
      ],
    );
  }

  // ================= WEEKEND =================
  Widget _buildWeekendLimitTab(
    BuildContext context,
    UserProvider userProvider,
    CategoryProvider categoryProvider,
    TransactionProvider txProvider,
    bool isDark,
  ) {
    final spent = txProvider.getCurrentWeekendExpenseByCategories(
      userProvider.weekendLimitCategories,
    );
    final limit = userProvider.weekendLimit;
    final percent = limit > 0 ? (spent / limit * 100).clamp(0.0, 100.0) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LimitStatusCard(
          title: 'Limit Weekend',
          subtitle: 'Berlaku setiap Sabtu - Minggu',
          icon: Icons.weekend,
          color: Colors.purple,
          isEnabled: userProvider.isWeekendLimitEnabled,
          spent: spent,
          limit: limit,
          percentage: percent,
          onToggle: (value) async {
            if (value && userProvider.weekendLimitCategories.isEmpty) {
              _showWarning(context);
              return;
            }
            await userProvider.toggleWeekendLimit(value);
          },
          onEditLimit: () => _showEditLimitBottomSheet(
            context,
            'Limit Weekend',
            limit,
            userProvider.setWeekendLimit,
          ),
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        LimitCategorySection(
          title: 'Kategori Limit Weekend',
          subtitle: 'Kategori yang dihitung dalam limit weekend',
          icon: Icons.category,
          color: Colors.purple,
          selectedCategoryIds: userProvider.weekendLimitCategories,
          allCategories: categoryProvider.expenseCategories,
          onCategoryToggle: (id, selected) async {
            selected
                ? await userProvider.addWeekendLimitCategory(id)
                : await userProvider.removeWeekendLimitCategory(id);
          },
          isDark: isDark,
        ),
      ],
    );
  }

  // ================= UNLIMITED =================
  Widget _buildUnlimitedTab(
    BuildContext context,
    UserProvider userProvider,
    CategoryProvider categoryProvider,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const UnlimitedHeader(),
        const SizedBox(height: 24),
        LimitCategorySection(
          title: 'Kategori Tanpa Limit',
          subtitle: 'Kategori ini tidak dihitung ke limit manapun',
          icon: Icons.category,
          color: Colors.green,
          selectedCategoryIds: userProvider.unlimitedCategories,
          allCategories: categoryProvider.expenseCategories,
          onCategoryToggle: (id, selected) async {
            selected
                ? await userProvider.addUnlimitedCategory(id)
                : await userProvider.removeUnlimitedCategory(id);
          },
          isDark: isDark,
        ),
      ],
    );
  }

  // ================= EDIT LIMIT BOTTOM SHEET =================
  void _showEditLimitBottomSheet(
    BuildContext context,
    String title,
    double currentLimit,
    Function(double) onSave,
  ) {
    final controller = TextEditingController(
      text: NumberFormat.decimalPattern('id_ID').format(currentLimit.toInt()),
    );

    AppBottomSheet.showForm<bool>(
      context: context,
      title: title,
      submitText: 'Simpan',
      builder: (context, _) {
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: const InputDecoration(
            labelText: 'Limit',
            prefixText: 'Rp ',
          ),
          validator: (value) {
            final amount = CurrencyInputFormatter.getNumericValue(value ?? '');
            if (amount <= 0) return 'Limit harus lebih dari 0';
            return null;
          },
        );
      },
      onSubmit: () async {
        final value = CurrencyInputFormatter.getNumericValue(controller.text);
        if (value <= 0) return null;
        onSave(value);
        return true;
      },
    );
  }

  void _showWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih kategori terlebih dahulu!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

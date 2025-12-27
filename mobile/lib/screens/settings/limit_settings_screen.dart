import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/user_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../screens/transaction/widgets/shared/currency_input_formatter.dart';
import '../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../widgets/snack_helper.dart';

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Limit'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Harian', icon: Icon(Icons.today_rounded, size: 20)),
              Tab(text: 'Weekend', icon: Icon(Icons.weekend_rounded, size: 20)),
              Tab(
                  text: 'Bebas',
                  icon: Icon(Icons.all_inclusive_rounded, size: 20)),
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
          icon: Icons.today_rounded,
          color: Colors.blue,
          isEnabled: userProvider.isDailyLimitEnabled,
          spent: spent,
          limit: limit,
          percentage: percent,
          onToggle: (value) async {
            if (value && userProvider.dailyLimitCategories.isEmpty) {
              SnackHelper.warning(
                context,
                'Pilih kategori terlebih dahulu sebelum mengaktifkan limit',
                title: 'Perhatian',
              );
              return;
            }
            await userProvider.toggleDailyLimit(value);
            if (context.mounted) {
              SnackHelper.success(
                context,
                value
                    ? 'Limit harian diaktifkan'
                    : 'Limit harian dinonaktifkan',
              );
            }
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
          icon: Icons.category_rounded,
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
          icon: Icons.lightbulb_outline_rounded,
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
          icon: Icons.weekend_rounded,
          color: Colors.purple,
          isEnabled: userProvider.isWeekendLimitEnabled,
          spent: spent,
          limit: limit,
          percentage: percent,
          onToggle: (value) async {
            if (value && userProvider.weekendLimitCategories.isEmpty) {
              SnackHelper.warning(
                context,
                'Pilih kategori terlebih dahulu sebelum mengaktifkan limit',
                title: 'Perhatian',
              );
              return;
            }
            await userProvider.toggleWeekendLimit(value);
            if (context.mounted) {
              SnackHelper.success(
                context,
                value
                    ? 'Limit weekend diaktifkan'
                    : 'Limit weekend dinonaktifkan',
              );
            }
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
          icon: Icons.category_rounded,
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
        const SizedBox(height: 16),
        LimitInfoBox(
          icon: Icons.lightbulb_outline_rounded,
          text:
              'Limit weekend berlaku total untuk Sabtu & Minggu, bukan per hari.',
          color: Colors.purple,
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
          icon: Icons.category_rounded,
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
        const SizedBox(height: 16),
        LimitInfoBox(
          icon: Icons.info_outline_rounded,
          text:
              'Pengeluaran di kategori ini tidak akan mempengaruhi perhitungan limit harian atau weekend.',
          color: Colors.green,
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
      subtitle: 'Atur jumlah maksimal pengeluaran',
      submitText: 'Simpan',
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Saat ini: ${_formatCurrency(currentLimit)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input Field
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Jumlah Limit',
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              validator: (value) {
                final amount =
                    CurrencyInputFormatter.getNumericValue(value ?? '');
                if (amount <= 0) return 'Limit harus lebih dari 0';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Quick Amount Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickAmountButton(
                  label: '50rb',
                  amount: 50000,
                  onTap: () => controller.text = '50.000',
                ),
                _QuickAmountButton(
                  label: '100rb',
                  amount: 100000,
                  onTap: () => controller.text = '100.000',
                ),
                _QuickAmountButton(
                  label: '150rb',
                  amount: 150000,
                  onTap: () => controller.text = '150.000',
                ),
                _QuickAmountButton(
                  label: '200rb',
                  amount: 200000,
                  onTap: () => controller.text = '200.000',
                ),
                _QuickAmountButton(
                  label: '300rb',
                  amount: 300000,
                  onTap: () => controller.text = '300.000',
                ),
                _QuickAmountButton(
                  label: '500rb',
                  amount: 500000,
                  onTap: () => controller.text = '500.000',
                ),
              ],
            ),
          ],
        );
      },
      onSubmit: () async {
        final value = CurrencyInputFormatter.getNumericValue(controller.text);
        if (value <= 0) {
          SnackHelper.error(context, 'Limit harus lebih dari 0');
          return null;
        }
        await onSave(value);
        if (context.mounted) {
          SnackHelper.success(
            context,
            'Limit berhasil diubah menjadi ${_formatCurrency(value)}',
          );
        }
        return true;
      },
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

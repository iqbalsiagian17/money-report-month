import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/category_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/double_back_to_exit.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/bottom_sheet/app_bottom_sheet.dart';
import '../../widgets/bottom_sheet/variants/options_bottom_sheet.dart';
import '../analysis/analysis_screen.dart';
import '../settings/settings_screen.dart';
import '../transaction/transaction_history_screen.dart';
import 'package:flutter/services.dart';

// Import home widgets
import 'widget/home_header.dart';
import 'widget/balance_card.dart';
import 'widget/limit_status_card.dart';
import 'widget/quick_actions_grid.dart';
import 'widget/recent_transactions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const _HomeContent(),
    const TransactionHistoryScreen(),
    const AnalysisScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final walletProvider = context.read<WalletProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    if (walletProvider.wallets.isEmpty) {
      await walletProvider.initDefaultWallets();
    }
    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.initDefaultCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // ⬅️ STATUS BAR ICON HITAM
      child: DoubleBackToExit(
        message: 'Tekan sekali lagi untuk keluar',
        duration: const Duration(seconds: 2),
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            onFabTap: () => _showAddTransactionSheet(context),
            showFab: true,
            items: const [
              BottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Beranda',
              ),
              BottomNavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Riwayat',
              ),
              BottomNavItem(
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics_rounded,
                label: 'Analisis',
              ),
              BottomNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Pengaturan',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ MENGGUNAKAN GLOBAL BOTTOM SHEET ============
  void _showAddTransactionSheet(BuildContext context) {
    AppBottomSheet.showOptions<String>(
      context: context,
      title: 'Tambah Transaksi',
      subtitle: 'Pilih jenis transaksi yang ingin dicatat',
      options: const [
        BottomSheetOption(
          title: 'Pemasukan',
          subtitle: 'Catat uang masuk',
          icon: Icons.arrow_downward_rounded,
          iconColor: Colors.green,
          value: 'income',
        ),
        BottomSheetOption(
          title: 'Pengeluaran',
          subtitle: 'Catat uang keluar',
          icon: Icons.arrow_upward_rounded,
          iconColor: Colors.red,
          value: 'expense',
        ),
      ],
    ).then((value) {
      if (value == null || !context.mounted) return;

      switch (value) {
        case 'income':
          Navigator.pushNamed(context, AppRoutes.addIncome);
          break;
        case 'expense':
          Navigator.pushNamed(context, AppRoutes.addExpense);
          break;
      }
    });
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Home Header (Fixed at top)
            const SliverToBoxAdapter(
              child: HomeHeader(),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const BalanceCard(),
                  const SizedBox(height: 20),
                  const LimitStatusCard(),
                  const SizedBox(height: 20),
                  const QuickActionsGrid(),
                  const SizedBox(height: 20),
                  const RecentTransactions(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

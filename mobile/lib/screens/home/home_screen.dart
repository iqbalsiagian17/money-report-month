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
import 'widget/todo_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _entranceController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _navAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _navAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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

  // Method untuk switch tab
  void _switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build screens di dalam build() agar bisa pass callback
    final screens = <Widget>[
      _HomeContent(
        entranceController: _entranceController,
        headerAnimation: _headerAnimation,
        contentAnimation: _contentAnimation,
        onViewAllTransactions: () => _switchToTab(1), // Index 1 = Riwayat
      ),
      const TransactionHistoryScreen(),
      const AnalysisScreen(),
      const SettingsScreen(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: DoubleBackToExit(
        message: 'Tekan sekali lagi untuk keluar',
        duration: const Duration(seconds: 2),
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _navAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 80 * (1 - _navAnimation.value)),
                child: Opacity(
                  opacity: _navAnimation.value.clamp(0.0, 1.0),
                  child: BottomNavBar(
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
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    HapticFeedback.lightImpact();
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
        BottomSheetOption(
          title: 'Pemindahan Dana',
          subtitle: 'Pindah saldo antar dompet',
          icon: Icons.sync_alt_rounded,
          iconColor: Colors.blue,
          value: 'transfer',
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
        case 'transfer':
          Navigator.pushNamed(context, AppRoutes.transfer);
          break;
      }
    });
  }
}

class _HomeContent extends StatefulWidget {
  final AnimationController entranceController;
  final Animation<double> headerAnimation;
  final Animation<double> contentAnimation;
  final VoidCallback? onViewAllTransactions;

  const _HomeContent({
    required this.entranceController,
    required this.headerAnimation,
    required this.contentAnimation,
    this.onViewAllTransactions,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();

    _cardControllers = List.generate(
      5,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _cardAnimations = _cardControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    widget.contentAnimation.addListener(_onContentAnimationUpdate);
  }

  void _onContentAnimationUpdate() {
    if (widget.contentAnimation.value > 0.3 &&
        !_cardControllers[0].isAnimating &&
        _cardControllers[0].value == 0) {
      _startCardAnimations();
    }
  }

  void _startCardAnimations() async {
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        _cardControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    widget.contentAnimation.removeListener(_onContentAnimationUpdate);
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        color: const Color(0xFF1A1A2E),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Animated Header
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: widget.headerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -30 * (1 - widget.headerAnimation.value)),
                    child: Opacity(
                      opacity: widget.headerAnimation.value.clamp(0.0, 1.0),
                      child: const HomeHeader(),
                    ),
                  );
                },
              ),
            ),

            // Animated Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Balance Card
                  _buildAnimatedCard(0, const BalanceCard()),
                  const SizedBox(height: 20),

                  // Todo Status Card
                  _buildAnimatedCard(3, const TodoStatusCard()),
                  const SizedBox(height: 20),

                  // Quick Actions
                  _buildAnimatedCard(2, const QuickActionsGrid()),
                  const SizedBox(height: 20),

                  // Limit Status Card
                  _buildAnimatedCard(1, const LimitStatusCard()),
                  const SizedBox(height: 20),

                  // Recent Transactions - dengan callback
                  _buildAnimatedCard(
                    4,
                    RecentTransactions(
                      onViewAllTap: widget.onViewAllTransactions,
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardAnimations[index].value)),
          child: Opacity(
            opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

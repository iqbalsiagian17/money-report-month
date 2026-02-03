import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';

import 'widget/debt_summary.dart';
import 'widget/debt_card.dart';
import 'widget/debt_form_sheet.dart';
import 'widget/debt_filter.dart';

class DebtListScreen extends StatefulWidget {
  const DebtListScreen({super.key});

  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DebtType? _selectedType;
  DebtStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedType = null; // Semua
          break;
        case 1:
          _selectedType = DebtType.receivable; // Piutang
          break;
        case 2:
          _selectedType = DebtType.payable; // Hutang
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          final filteredDebts = provider.filterDebts(
            type: _selectedType,
            status: _selectedStatus,
            searchQuery: _searchQuery,
          );

          return CustomScrollView(
            slivers: [
              // AppBar
              _buildAppBar(context, isDark),

              // Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: DebtSummary(
                    totalReceivables: provider.totalReceivables,
                    totalPayables: provider.totalPayables,
                    overdueCount: provider.overdueDebts.length,
                    isDark: isDark,
                  ),
                ),
              ),

              // Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DebtFilterTabs(
                    tabController: _tabController,
                    isDark: isDark,
                  ),
                ),
              ),

              // Status Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: DebtStatusFilter(
                    selectedStatus: _selectedStatus,
                    onChanged: (status) {
                      setState(() => _selectedStatus = status);
                    },
                    isDark: isDark,
                  ),
                ),
              ),

              // List
              if (filteredDebts.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(isDark),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final debt = filteredDebts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DebtCard(debt: debt),
                        );
                      },
                      childCount: filteredDebts.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Hutang & Piutang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)]
                  : [Colors.white, const Color(0xFFF8F9FA)],
            ),
          ),
        ),
      ),
      actions: [
        // Search button
        IconButton(
          onPressed: () => _showSearchDialog(context),
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    String message;
    IconData icon;

    if (_selectedType == DebtType.receivable) {
      message = 'Belum ada piutang';
      icon = Icons.call_received_rounded;
    } else if (_selectedType == DebtType.payable) {
      message = 'Belum ada hutang';
      icon = Icons.call_made_rounded;
    } else {
      message = 'Belum ada hutang/piutang';
      icon = Icons.receipt_long_rounded;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]!.withOpacity(0.3)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + untuk menambahkan',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => DebtFormSheet.show(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama atau keterangan...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

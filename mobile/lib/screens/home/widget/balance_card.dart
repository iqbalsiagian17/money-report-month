import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_report_monthly/screens/home/widget/balance_card_styles/balance_card_advanced_sheet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../providers/wallet_provider.dart';
import '../../../providers/balance_card_provider.dart';
import '../../../models/balance_card_style.dart';
import 'balance_card_styles/gradient_card.dart';
import 'balance_card_styles/glass_card.dart';
import 'balance_card_styles/minimal_card.dart';
import 'balance_card_styles/neon_card.dart';
import 'balance_card_styles/credit_card.dart';
import 'balance_card_styles/modern_card.dart';
import 'balance_card_styles/custom_card.dart'; // ✅ NEW

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Consumer2<WalletProvider, BalanceCardProvider>(
      builder: (context, walletProvider, cardProvider, _) {
        final style = cardProvider.currentStyle;

        return GestureDetector(
          onLongPress: () => _showCustomizeSheet(context, cardProvider),
          child: _buildCard(
            walletProvider,
            style,
          ),
        );
      },
    );
  }

  Widget _buildCard(WalletProvider walletProvider, BalanceCardStyle style) {
    final balance = walletProvider.totalBalance;
    final walletCount = walletProvider.wallets.length;

    final commonProps = BalanceCardProps(
      balance: balance,
      walletCount: walletCount,
      isBalanceVisible: _isBalanceVisible,
      style: style,
      onToggleVisibility: () {
        HapticFeedback.lightImpact();
        setState(() => _isBalanceVisible = !_isBalanceVisible);
      },
    );

    switch (style.type) {
      case BalanceCardType.gradient:
        return GradientBalanceCard(props: commonProps);
      case BalanceCardType.glass:
        return GlassBalanceCard(props: commonProps);
      case BalanceCardType.minimal:
        return MinimalBalanceCard(props: commonProps);
      case BalanceCardType.neon:
        return NeonBalanceCard(props: commonProps);
      case BalanceCardType.card:
        return CreditCardBalanceCard(props: commonProps);
      case BalanceCardType.modern:
        return ModernBalanceCard(props: commonProps);
      case BalanceCardType.custom: // ✅ NEW
        return CustomBalanceCard(props: commonProps);
    }
  }

  void _showCustomizeSheet(BuildContext context, BalanceCardProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomizeBalanceSheet(provider: provider),
    );
  }
}

// ============================================
// Common Props Class
// ============================================
class BalanceCardProps {
  final double balance;
  final int walletCount;
  final bool isBalanceVisible;
  final BalanceCardStyle style;
  final VoidCallback onToggleVisibility;

  BalanceCardProps({
    required this.balance,
    required this.walletCount,
    required this.isBalanceVisible,
    required this.style,
    required this.onToggleVisibility,
  });

  String get formattedBalance => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(balance);

  String get currentMonth =>
      DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
}

// ============================================
// Customize Sheet - SIMPLE VERSION
// ============================================
class _CustomizeBalanceSheet extends StatelessWidget {
  final BalanceCardProvider provider;

  const _CustomizeBalanceSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Quick Presets
                _QuickPresetTile(
                  title: 'Gunakan Preset',
                  subtitle: '6 style siap pakai',
                  icon: Icons.dashboard_customize_rounded,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Show simple grid
                    _showSimplePresets(context, provider);
                  },
                ),
                const SizedBox(height: 12),

                // Advanced Custom
                _QuickPresetTile(
                  title: 'Custom Advanced',
                  subtitle: 'Atur warna, bentuk, efek sendiri',
                  icon: Icons.tune_rounded,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Show advanced sheet
                    _showAdvancedSheet(context, provider);
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSimplePresets(BuildContext context, BalanceCardProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SimplePresetsSheet(provider: provider),
    );
  }

  void _showAdvancedSheet(BuildContext context, BalanceCardProvider provider) {
    // Import advanced sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedCustomizeSheet(provider: provider),
    );
  }
}

// Quick Preset Tile
class _QuickPresetTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickPresetTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Presets Sheet
class _SimplePresetsSheet extends StatelessWidget {
  final BalanceCardProvider provider;

  const _SimplePresetsSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Text(
                  'Pilih Preset Style',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: Consumer<BalanceCardProvider>(
              builder: (context, provider, _) {
                final styles = [
                  (
                    'Gradient',
                    BalanceCardType.gradient,
                    Icons.gradient_rounded,
                    Colors.blue
                  ),
                  (
                    'Glass',
                    BalanceCardType.glass,
                    Icons.blur_on_rounded,
                    Colors.cyan
                  ),
                  (
                    'Minimal',
                    BalanceCardType.minimal,
                    Icons.rectangle_rounded,
                    Colors.grey
                  ),
                  (
                    'Neon',
                    BalanceCardType.neon,
                    Icons.light_mode_rounded,
                    Colors.purple
                  ),
                  (
                    'Card',
                    BalanceCardType.card,
                    Icons.credit_card_rounded,
                    Colors.indigo
                  ),
                  (
                    'Modern',
                    BalanceCardType.modern,
                    Icons.auto_awesome_rounded,
                    Colors.pink
                  ),
                ];

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: styles.length,
                  itemBuilder: (context, index) {
                    final (label, type, icon, color) = styles[index];
                    final isSelected = provider.currentStyle.type == type;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        provider.updateType(type);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    color.withOpacity(0.2),
                                    color.withOpacity(0.1),
                                  ],
                                )
                              : null,
                          color:
                              isSelected ? null : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                size: 32,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? color : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

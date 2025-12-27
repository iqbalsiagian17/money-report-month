import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/wallet.dart';

class WalletBalanceCard extends StatelessWidget {
  final Wallet wallet;

  const WalletBalanceCard({
    super.key,
    required this.wallet,
  });

  // ============ HELPER FUNCTIONS ============

  IconData _getWalletIcon(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return Icons.payments_rounded;
      case WalletType.bank:
        return Icons.account_balance_rounded;
      case WalletType.emoney:
        return Icons.smartphone_rounded;
    }
  }

  Color _getWalletColor(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return const Color(0xFF2E7D32);
      case WalletType.bank:
        return const Color(0xFF1565C0);
      case WalletType.emoney:
        return const Color(0xFFE65100);
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatBalanceNumber(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}jt';
    } else {
      return NumberFormat('#,###', 'id_ID').format(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletColor = _getWalletColor(wallet.type);
    final walletIcon = _getWalletIcon(wallet.type);
    final isNegative = wallet.balance < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            walletColor,
            walletColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: walletColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row - Icon & Type Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Wallet Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  walletIcon,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              // Type Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      walletIcon,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      wallet.typeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Wallet Name
          Text(
            wallet.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Balance Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SALDO',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Balance Amount
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Negative indicator
                      if (isNegative)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 4),
                          child: Icon(
                            Icons.remove,
                            color: Colors.red[200],
                            size: 24,
                          ),
                        ),

                      // Currency symbol
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Rp',
                          style: TextStyle(
                            color: isNegative ? Colors.red[200] : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Amount
                      Text(
                        _formatBalanceNumber(wallet.balance.abs()),
                        style: TextStyle(
                          color: isNegative ? Colors.red[200] : Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Full amount (if compact)
                if (wallet.balance.abs() >= 100000) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(wallet.balance),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Exclude indicator
          if (wallet.excludeFromTotal) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_off_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tidak termasuk total saldo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Quick Action Hints
          Row(
            children: [
              _buildQuickStat(
                icon: Icons.arrow_downward_rounded,
                label: 'Masuk',
                iconColor: Colors.greenAccent,
              ),
              _buildDivider(),
              _buildQuickStat(
                icon: Icons.arrow_upward_rounded,
                label: 'Keluar',
                iconColor: Colors.redAccent,
              ),
              _buildDivider(),
              _buildQuickStat(
                icon: Icons.swap_horiz_rounded,
                label: 'Transfer',
                iconColor: Colors.lightBlueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

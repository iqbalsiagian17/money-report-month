import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/routes.dart';
import '../../../providers/wallet_provider.dart';
import '../../../models/wallet.dart';

class MyWalletsSection extends StatelessWidget {
  const MyWalletsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dompet Saya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.wallets),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Kelola',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.wallets.isEmpty)
              _EmptyWallets(isDark: isDark)
            else
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.wallets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final wallet = provider.wallets[index];
                    return _WalletCard(
                      wallet: wallet,
                      currencyFormat: currencyFormat,
                      isDark: isDark,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  final NumberFormat currencyFormat;
  final bool isDark;

  const _WalletCard({
    required this.wallet,
    required this.currencyFormat,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final walletData = _getWalletTypeData(wallet.type);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: walletData.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    wallet.icon ?? walletData.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      walletData.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: walletData.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            currencyFormat.format(wallet.balance),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: wallet.balance >= 0
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.red,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  _WalletTypeData _getWalletTypeData(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return _WalletTypeData(
          icon: '💵',
          label: 'Tunai',
          color: const Color(0xFF4CAF50),
        );
      case WalletType.bank:
        return _WalletTypeData(
          icon: '🏦',
          label: 'Bank',
          color: const Color(0xFF2196F3),
        );
      case WalletType.emoney:
        return _WalletTypeData(
          icon: '💳',
          label: 'E-Money',
          color: const Color(0xFFFF9800),
        );
    }
  }
}

class _WalletTypeData {
  final String icon;
  final String label;
  final Color color;

  _WalletTypeData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _EmptyWallets extends StatelessWidget {
  final bool isDark;

  const _EmptyWallets({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada dompet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.wallets),
            child: Text(
              'Tambah Dompet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

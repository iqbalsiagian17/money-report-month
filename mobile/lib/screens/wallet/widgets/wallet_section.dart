import 'package:flutter/material.dart';
import '../../../models/wallet.dart';
import 'wallet_tile.dart';

class WalletSection extends StatelessWidget {
  final String title;
  final String icon;
  final List<Wallet> wallets;
  final Function(Wallet) onWalletTap;

  const WalletSection({
    super.key,
    required this.title,
    required this.icon,
    required this.wallets,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${wallets.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...wallets.map((wallet) => WalletTile(
              wallet: wallet,
              onTap: () => onWalletTap(wallet),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}

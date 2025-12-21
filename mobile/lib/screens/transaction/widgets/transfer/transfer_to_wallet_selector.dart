import 'package:flutter/material.dart';
import '../../../../models/wallet.dart';

class TransferToWalletSelector extends StatelessWidget {
  final List<Wallet> wallets;
  final String? selectedWalletId;
  final ValueChanged<String?> onChanged;

  const TransferToWalletSelector({
    super.key,
    required this.wallets,
    required this.selectedWalletId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedWalletId,
      decoration: const InputDecoration(
        labelText: 'Ke Dompet',
        prefixIcon: Icon(Icons.arrow_forward_rounded),
        border: OutlineInputBorder(),
      ),
      items: wallets.map((wallet) {
        return DropdownMenuItem<String>(
          value: wallet.id,
          child: Row(
            children: [
              _WalletIcon(icon: wallet.icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  wallet.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Pilih dompet tujuan' : null,
    );
  }
}

class _WalletIcon extends StatelessWidget {
  final String? icon;
  const _WalletIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        icon ?? '💼',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

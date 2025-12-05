import 'package:hive/hive.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
enum WalletType {
  @HiveField(0)
  cash,
  @HiveField(1)
  bank,
  @HiveField(2)
  emoney,
}

@HiveType(typeId: 1)
class Wallet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  WalletType type;

  @HiveField(3)
  double balance;

  @HiveField(4)
  String? icon;

  @HiveField(5)
  DateTime createdAt;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0,
    this.icon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case WalletType.cash:
        return 'Cash';
      case WalletType.bank:
        return 'Bank';
      case WalletType.emoney:
        return 'E-Money';
    }
  }
}

import 'package:hive/hive.dart';

part 'debt.g.dart';

// ✅ UPDATED: Gunakan typeId yang belum dipakai
@HiveType(typeId: 13)
enum DebtType {
  @HiveField(0)
  receivable, // Piutang (orang lain hutang ke kita)

  @HiveField(1)
  payable, // Hutang (kita hutang ke orang lain)
}

@HiveType(typeId: 14)
enum DebtStatus {
  @HiveField(0)
  pending, // Belum lunas

  @HiveField(1)
  partial, // Sebagian dibayar

  @HiveField(2)
  paid, // Lunas
}

@HiveType(typeId: 15)
class Debt extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DebtType type;

  @HiveField(2)
  String personName;

  @HiveField(3)
  String? personPhone;

  @HiveField(4)
  double amount;

  @HiveField(5)
  double paidAmount;

  @HiveField(6)
  String? description;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? dueDate;

  @HiveField(9)
  DebtStatus status;

  @HiveField(10)
  String? walletId;

  @HiveField(11)
  List<DebtPayment> payments;

  Debt({
    required this.id,
    required this.type,
    required this.personName,
    this.personPhone,
    required this.amount,
    this.paidAmount = 0,
    this.description,
    DateTime? createdAt,
    this.dueDate,
    this.status = DebtStatus.pending,
    this.walletId,
    List<DebtPayment>? payments,
  })  : createdAt = createdAt ?? DateTime.now(),
        payments = payments ?? [];

  double get remainingAmount => amount - paidAmount;

  double get progress => amount > 0 ? (paidAmount / amount).clamp(0.0, 1.0) : 0;

  bool get isPaid => status == DebtStatus.paid || remainingAmount <= 0;

  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid;

  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  void updateStatus() {
    if (remainingAmount <= 0) {
      status = DebtStatus.paid;
    } else if (paidAmount > 0) {
      status = DebtStatus.partial;
    } else {
      status = DebtStatus.pending;
    }
  }

  void addPayment(DebtPayment payment) {
    payments.add(payment);
    paidAmount += payment.amount;
    updateStatus();
  }
}

@HiveType(typeId: 16)
class DebtPayment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? note;

  @HiveField(4)
  String? walletId;

  DebtPayment({
    required this.id,
    required this.amount,
    DateTime? date,
    this.note,
    this.walletId,
  }) : date = date ?? DateTime.now();
}

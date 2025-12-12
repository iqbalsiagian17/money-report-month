import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/saving_goal.dart';
import '../../../models/wallet.dart';

class SavingCard extends StatelessWidget {
  final SavingGoal saving;
  final Wallet? wallet;
  final VoidCallback onTap;
  final VoidCallback onDeposit;

  const SavingCard({
    super.key,
    required this.saving,
    required this.wallet,
    required this.onTap,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final progressPercent = (saving.progress * 100).round();
    final isCompleted = saving.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, isCompleted, isDark),
                const SizedBox(height: 18),

                // Progress Bar
                _buildProgressBar(context, isCompleted),
                const SizedBox(height: 14),

                // Amount Info
                _buildAmountInfo(currencyFormat, progressPercent, isCompleted,
                    context, isDark),

                // Deposit Button
                if (!isCompleted) ...[
                  const SizedBox(height: 16),
                  _buildDepositButton(context),
                ],

                // Target Date
                if (saving.targetDate != null && !isCompleted) ...[
                  const SizedBox(height: 12),
                  _buildTargetDate(isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompleted, bool isDark) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCompleted
                  ? [
                      Colors.green.withOpacity(0.2),
                      Colors.green.withOpacity(0.1)
                    ]
                  : [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.savings_rounded,
            color: isCompleted ? Colors.green : Theme.of(context).primaryColor,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saving.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    wallet?.icon ?? '💰',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    wallet?.name ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                const Text(
                  'Tercapai',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, bool isCompleted) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: saving.progress.clamp(0.0, 1.0),
        minHeight: 10,
        backgroundColor: Colors.grey.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation(
          isCompleted ? Colors.green : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildAmountInfo(
    NumberFormat format,
    int progressPercent,
    bool isCompleted,
    BuildContext context,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terkumpul',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              format.format(saving.currentAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isCompleted ? Colors.green : Theme.of(context).primaryColor)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$progressPercent%',
            style: TextStyle(
              color:
                  isCompleted ? Colors.green : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Target',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Text(
              format.format(saving.targetAmount),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepositButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onDeposit,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Theme.of(context).primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(Icons.add_rounded, color: Theme.of(context).primaryColor),
        label: Text(
          'Setor Tabungan',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetDate(bool isDark) {
    final daysRemaining = saving.targetDate!.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue
                ? Icons.warning_amber_rounded
                : Icons.calendar_today_rounded,
            size: 14,
            color: isOverdue ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            isOverdue
                ? 'Lewat ${daysRemaining.abs()} hari'
                : '$daysRemaining hari lagi',
            style: TextStyle(
              fontSize: 12,
              color: isOverdue ? Colors.red : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

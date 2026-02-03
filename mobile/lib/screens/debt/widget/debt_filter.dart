import 'package:flutter/material.dart';
import '../../../models/debt.dart';

class DebtFilterTabs extends StatelessWidget {
  final TabController tabController;
  final bool isDark;

  const DebtFilterTabs({
    super.key,
    required this.tabController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: isDark ? Colors.white : Colors.black87,
        unselectedLabelColor: Colors.grey[500],
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Piutang'),
          Tab(text: 'Hutang'),
        ],
      ),
    );
  }
}

class DebtStatusFilter extends StatelessWidget {
  final DebtStatus? selectedStatus;
  final ValueChanged<DebtStatus?> onChanged;
  final bool isDark;

  const DebtStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'Semua',
            value: null,
            icon: Icons.list_rounded,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Pending',
            value: DebtStatus.pending,
            icon: Icons.schedule_rounded,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Sebagian',
            value: DebtStatus.partial,
            icon: Icons.timelapse_rounded,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Lunas',
            value: DebtStatus.paid,
            icon: Icons.check_circle_rounded,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required DebtStatus? value,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = selectedStatus == value;
    final chipColor = color ?? Theme.of(context).primaryColor;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? chipColor : Colors.grey[500],
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? chipColor : Colors.grey[600],
      ),
      backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
      selectedColor: chipColor.withOpacity(0.15),
      checkmarkColor: chipColor,
      showCheckmark: false,
      side: BorderSide(
        color: isSelected ? chipColor.withOpacity(0.3) : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (_) => onChanged(isSelected ? null : value),
    );
  }
}

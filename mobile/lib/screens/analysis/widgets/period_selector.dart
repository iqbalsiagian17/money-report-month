import 'package:flutter/material.dart';

enum AnalysisPeriod { weekly, monthly }

class PeriodSelector extends StatelessWidget {
  final AnalysisPeriod selectedPeriod;
  final ValueChanged<AnalysisPeriod> onChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Mingguan',
            icon: Icons.view_week_rounded,
            isSelected: selectedPeriod == AnalysisPeriod.weekly,
            onTap: () => onChanged(AnalysisPeriod.weekly),
          ),
          _PeriodButton(
            label: 'Bulanan',
            icon: Icons.calendar_month_rounded,
            isSelected: selectedPeriod == AnalysisPeriod.monthly,
            onTap: () => onChanged(AnalysisPeriod.monthly),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  bool _isCurrentMonth() {
    final now = DateTime.now();
    return selectedMonth.year == now.year && selectedMonth.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentMonth = _isCurrentMonth();
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Previous Month Button
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
              ));
            },
            isDark: isDark,
            primaryColor: primaryColor,
          ),

          // Month Display
          Expanded(
            child: GestureDetector(
              onTap: () => _showMonthPicker(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Calendar Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 20,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Month & Year
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MMMM', 'id_ID').format(selectedMonth),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat('yyyy').format(selectedMonth),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (isCurrentMonth) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Aktif',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Dropdown hint
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next Month Button
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              ));
            },
            isDark: isDark,
            primaryColor: primaryColor,
            enabled: !isCurrentMonth,
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MonthPickerSheet(
        selectedMonth: selectedMonth,
        onChanged: (date) {
          onChanged(date);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color primaryColor;
  final bool enabled;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.primaryColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: enabled
                ? (isDark ? Colors.grey[800] : Colors.grey[50])
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: enabled
                ? Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  )
                : null,
          ),
          child: Icon(
            icon,
            color: enabled
                ? (isDark ? Colors.white : Colors.grey[700])
                : Colors.grey[300],
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ============ MONTH PICKER BOTTOM SHEET ============
class _MonthPickerSheet extends StatefulWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;
  final bool isDark;

  const _MonthPickerSheet({
    required this.selectedMonth,
    required this.onChanged,
    required this.isDark,
  });

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _selectedYear;
  late int _selectedMonthIndex;

  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedMonth.year;
    _selectedMonthIndex = widget.selectedMonth.month - 1;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pilih Bulan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Year Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedYear--);
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  '$_selectedYear',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: _selectedYear < now.year
                      ? () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedYear++);
                        }
                      : null,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: _selectedYear < now.year ? null : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Month Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final isSelected = _selectedMonthIndex == index &&
                    _selectedYear == widget.selectedMonth.year;
                final isFuture =
                    _selectedYear == now.year && index > now.month - 1;
                final isCurrent =
                    _selectedYear == now.year && index == now.month - 1;

                return GestureDetector(
                  onTap: isFuture
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          widget.onChanged(DateTime(_selectedYear, index + 1));
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : isCurrent
                              ? primaryColor.withOpacity(0.1)
                              : (widget.isDark
                                  ? Colors.grey[850]
                                  : Colors.grey[50]),
                      borderRadius: BorderRadius.circular(10),
                      border: isCurrent && !isSelected
                          ? Border.all(color: primaryColor)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _months[index].substring(0, 3),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isCurrent
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isFuture
                              ? Colors.grey[300]
                              : isSelected
                                  ? Colors.white
                                  : isCurrent
                                      ? primaryColor
                                      : (widget.isDark
                                          ? Colors.white
                                          : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Select
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _QuickSelectButton(
                    label: 'Bulan Ini',
                    icon: Icons.today_rounded,
                    onTap: () {
                      widget.onChanged(DateTime(now.year, now.month));
                    },
                    isDark: widget.isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickSelectButton(
                    label: 'Bulan Lalu',
                    icon: Icons.history_rounded,
                    onTap: () {
                      final lastMonth = DateTime(now.year, now.month - 1);
                      widget.onChanged(lastMonth);
                    },
                    isDark: widget.isDark,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }
}

class _QuickSelectButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickSelectButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const DateTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _DatePickerField(
            selectedDate: selectedDate,
            onChanged: onDateChanged,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimePickerField(
            selectedTime: selectedTime,
            onChanged: onTimeChanged,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final bool isDark;

  const _DatePickerField({
    required this.selectedDate,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal',
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) onChanged(date);
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onChanged;
  final bool isDark;

  const _TimePickerField({
    required this.selectedTime,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Waktu',
          prefixIcon: const Icon(Icons.access_time_rounded),
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(selectedTime.format(context)),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) onChanged(time);
  }
}

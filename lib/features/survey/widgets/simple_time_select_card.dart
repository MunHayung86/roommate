import 'package:flutter/material.dart';

import 'simple_dropdown.dart';

class SimpleTimeSelectCard extends StatelessWidget {
  const SimpleTimeSelectCard({
    super.key,
    required this.title,
    required this.selectedPeriod,
    required this.selectedHour,
    required this.selectedMinute,
    required this.periods,
    required this.hours,
    required this.minutes,
    required this.onPeriodChanged,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  final String title;
  final String? selectedPeriod;
  final int? selectedHour;
  final int? selectedMinute;
  final List<String> periods;
  final List<int> hours;
  final List<int> minutes;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCFD1D8), width: 2),
        ),
        child: Row(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SimpleDropdown<String>(
              value: selectedPeriod,
              hint: '오전/오후',
              items: periods,
              labelBuilder: (String item) => item,
              onChanged: onPeriodChanged,
              width: 92,
            ),
            const SizedBox(width: 6),
            SimpleDropdown<int>(
              value: selectedHour,
              hint: '시',
              items: hours,
              labelBuilder: (int item) => item.toString().padLeft(2, '0'),
              onChanged: onHourChanged,
              width: 70,
            ),
            const SizedBox(width: 6),
            SimpleDropdown<int>(
              value: selectedMinute,
              hint: '분',
              items: minutes,
              labelBuilder: (int item) => item.toString().padLeft(2, '0'),
              onChanged: onMinuteChanged,
              width: 70,
            ),
          ],
        ),
      ),
    );
  }
}

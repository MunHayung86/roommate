import 'package:flutter/material.dart';

class SurveyOptionButton extends StatelessWidget {
  const SurveyOptionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E2E9), width: 1),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard Variable',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.25,
                letterSpacing: -0.5,
                color: Color(0xFF17171B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

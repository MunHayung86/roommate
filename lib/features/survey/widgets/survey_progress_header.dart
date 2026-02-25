import 'package:flutter/material.dart';

class SurveyProgressHeader extends StatelessWidget {
  const SurveyProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.onBack,
  });

  final int currentIndex;
  final int totalCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final double progress = (currentIndex + 1) / totalCount;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              splashRadius: 20,
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${currentIndex + 1} / $totalCount',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7E7E89),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE2DFF5),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E63F7)),
          ),
        ),
      ],
    );
  }
}

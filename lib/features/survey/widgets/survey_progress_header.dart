import 'package:flutter/material.dart';

class SurveyProgressHeader extends StatelessWidget {
  const SurveyProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.onBack,
    this.showBackButton = true,
  });

  final int currentIndex;
  final int totalCount;
  final VoidCallback onBack;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final double progress = (currentIndex + 1) / totalCount;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            if (showBackButton)
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: GestureDetector(
                  onTap: onBack,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset('assets/images/back.png'),
                  ),
                ),
              )
            else
              const SizedBox(width: 38),
            if (showBackButton)
              const SizedBox(width: 0)
            else
              const SizedBox(width: 0),
            Expanded(
              child: Center(
                child: Text(
                  '${currentIndex + 1} / $totalCount',
                  style: const TextStyle(
                    fontFamily: 'Pretendard Variable',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                    color: Color(0xFF7E7E89),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 38),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: 354,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0x1A6C5CE7),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

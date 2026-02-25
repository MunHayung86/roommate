import 'dart:math' as math;

import 'package:flutter/material.dart';

class SimpleTimeSelectCard extends StatelessWidget {
  const SimpleTimeSelectCard({
    super.key,
    required this.title,
    required this.rangeStartMinutes,
    required this.rangeEndMinutes,
    required this.isEditingRangeStart,
    required this.onEditingRangeStartChanged,
    required this.onRangeStartMinutesChanged,
    required this.onRangeEndMinutesChanged,
    required this.dialSize,
  });

  final String title;
  final int rangeStartMinutes;
  final int rangeEndMinutes;
  final bool isEditingRangeStart;
  final ValueChanged<bool> onEditingRangeStartChanged;
  final ValueChanged<int> onRangeStartMinutesChanged;
  final ValueChanged<int> onRangeEndMinutesChanged;
  final double dialSize;

  static int _angularDistanceMinutes(int a, int b) {
    final int diff = (a - b).abs();
    return math.min(diff, 720 - diff);
  }

  void _updateByDialPosition(Offset localPosition, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Offset delta = localPosition - center;

    final double radians = math.atan2(delta.dy, delta.dx);
    double angleFromTop = radians + (math.pi / 2);
    if (angleFromTop < 0) {
      angleFromTop += 2 * math.pi;
    }

    final double rawTotalMinutes = (angleFromTop / (2 * math.pi)) * 720;
    const int step = 10;
    final int quantizedTotalMinutes = ((rawTotalMinutes / step).round() * step) % 720;

    final int toStart = _angularDistanceMinutes(quantizedTotalMinutes, rangeStartMinutes);
    final int toEnd = _angularDistanceMinutes(quantizedTotalMinutes, rangeEndMinutes);

    final bool editStart = toStart <= toEnd;
    onEditingRangeStartChanged(editStart);

    if (editStart) {
      onRangeStartMinutesChanged(quantizedTotalMinutes);
    } else {
      onRangeEndMinutesChanged(quantizedTotalMinutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int activeMinutes = isEditingRangeStart ? rangeStartMinutes : rangeEndMinutes;

    int displayHour = (activeMinutes ~/ 60) % 12;
    if (displayHour == 0) {
      displayHour = 12;
    }
    final int minute = activeMinutes % 60;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E2E9), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title.isNotEmpty) ...<Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF17171B),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Center(
              child: SizedBox(
                width: dialSize,
                height: dialSize,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Size size = Size(constraints.maxWidth, constraints.maxHeight);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (TapDownDetails details) {
                        _updateByDialPosition(details.localPosition, size);
                      },
                      onPanStart: (DragStartDetails details) {
                        _updateByDialPosition(details.localPosition, size);
                      },
                      onPanUpdate: (DragUpdateDetails details) {
                        _updateByDialPosition(details.localPosition, size);
                      },
                      child: CustomPaint(
                        painter: _TimeDialPainter(
                          activeMinutes: activeMinutes,
                          startMinutes: rangeStartMinutes,
                          endMinutes: rangeEndMinutes,
                          isEditingStart: isEditingRangeStart,
                          fillColor: const Color(0x336C5CE7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeDialPainter extends CustomPainter {
  const _TimeDialPainter({
    required this.activeMinutes,
    required this.startMinutes,
    required this.endMinutes,
    required this.isEditingStart,
    required this.fillColor,
  });

  final int activeMinutes;
  final int startMinutes;
  final int endMinutes;
  final bool isEditingStart;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2;

    final Rect arcRect = Rect.fromCircle(center: center, radius: radius * 0.98);
    final double dialStartAngle = -math.pi / 2;
    final double startAngle = dialStartAngle + (2 * math.pi * (startMinutes / 720));
    final int minuteDiff = (endMinutes - startMinutes) % 720;
    final double sweepAngle = (minuteDiff / 720) * (2 * math.pi);

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    if (sweepAngle > 0) {
      canvas.drawArc(arcRect, startAngle, sweepAngle, true, fillPaint);
    }

    final double startRatio = startMinutes / 720;
    final double endRatio = endMinutes / 720;

    final Paint minorTickPaint = Paint()
      ..color = const Color(0xFFC5C6D3)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final Paint majorTickPaint = Paint()
      ..color = const Color(0xFF7A73E8)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i += 1) {
      final double tickRatio = i / 60;
      final bool inFilledRange = _isInClockwiseRange(tickRatio, startRatio, endRatio);
      if (inFilledRange) {
        continue;
      }

      final bool isMajor = i % 5 == 0;
      final double angle = dialStartAngle + (2 * math.pi * (i / 60));
      final double tickLength = isMajor ? 20 : 12;

      final Offset start = Offset(
        center.dx + math.cos(angle) * (radius - tickLength),
        center.dy + math.sin(angle) * (radius - tickLength),
      );
      final Offset end = Offset(
        center.dx + math.cos(angle) * (radius - 2),
        center.dy + math.sin(angle) * (radius - 2),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : minorTickPaint);
    }

    final Paint startHandlePaint = Paint()
      ..color = isEditingStart ? const Color(0xFF6C5CE7) : const Color(0xFF8D85EF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Paint endHandlePaint = Paint()
      ..color = isEditingStart ? const Color(0xFF8D85EF) : const Color(0xFF6C5CE7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    _drawHandle(
      canvas: canvas,
      center: center,
      radius: radius,
      ratio: startRatio,
      paint: startHandlePaint,
      baseAngle: dialStartAngle,
    );
    _drawHandle(
      canvas: canvas,
      center: center,
      radius: radius,
      ratio: endRatio,
      paint: endHandlePaint,
      baseAngle: dialStartAngle,
    );

    final Paint activeDotPaint = Paint()..color = const Color(0xFF6C5CE7);
    final double activeAngle = dialStartAngle + (2 * math.pi * (activeMinutes / 720));
    final Offset activeDot = Offset(
      center.dx + math.cos(activeAngle) * (radius - 26),
      center.dy + math.sin(activeAngle) * (radius - 26),
    );
    canvas.drawCircle(activeDot, 3.5, activeDotPaint);
  }

  @override
  bool shouldRepaint(covariant _TimeDialPainter oldDelegate) {
    return oldDelegate.activeMinutes != activeMinutes ||
        oldDelegate.startMinutes != startMinutes ||
        oldDelegate.endMinutes != endMinutes ||
        oldDelegate.isEditingStart != isEditingStart ||
        oldDelegate.fillColor != fillColor;
  }

  bool _isInClockwiseRange(double value, double start, double end) {
    if (start <= end) {
      return value >= start && value <= end;
    }
    return value >= start || value <= end;
  }

  void _drawHandle({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double ratio,
    required Paint paint,
    required double baseAngle,
  }) {
    final double angle = baseAngle + (2 * math.pi * ratio);
    final Offset start = Offset(
      center.dx + math.cos(angle) * (radius - 24),
      center.dy + math.sin(angle) * (radius - 24),
    );
    final Offset end = Offset(
      center.dx + math.cos(angle) * (radius - 2),
      center.dy + math.sin(angle) * (radius - 2),
    );
    canvas.drawLine(start, end, paint);
  }
}

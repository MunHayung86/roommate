import 'package:flutter/material.dart';

import '../models/survey_question.dart';
import '../widgets/simple_time_select_card.dart';
import '../widgets/survey_option_button.dart';
import '../widgets/survey_progress_header.dart';

class LifestyleSurveyPage extends StatefulWidget {
  const LifestyleSurveyPage({
    super.key,
    required this.questions,
    this.onCompleted,
  });

  final List<SurveyQuestion> questions;
  final ValueChanged<Map<String, String>>? onCompleted;

  @override
  State<LifestyleSurveyPage> createState() => _LifestyleSurveyPageState();
}

class _LifestyleSurveyPageState extends State<LifestyleSurveyPage> {
  static const List<int> _hours = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  static const List<int> _minutes = <int>[0, 10, 20, 30, 40, 50];
  static const List<String> _periods = <String>['오전', '오후'];

  int _currentIndex = 0;
  final Map<String, String> _answers = <String, String>{};
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  int _displayHour(TimeOfDay time) {
    final int hour = time.hour % 12;
    return hour == 0 ? 12 : hour;
  }

  String _periodLabel(TimeOfDay time) {
    return time.hour < 12 ? '오전' : '오후';
  }

  int _to24Hour({required int displayHour, required String period}) {
    final int normalizedHour = displayHour % 12;
    return period == '오전' ? normalizedHour : normalizedHour + 12;
  }

  SurveyQuestion get _currentQuestion => widget.questions[_currentIndex];

  Future<void> _tryCompleteSleepQuestion() async {
    if (_bedTime == null || _wakeTime == null) {
      return;
    }

    _answers[_currentQuestion.id] = '취침 ${_formatTime(_bedTime!)} / 기상 ${_formatTime(_wakeTime!)}';
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _goToNextQuestion();
  }

  Future<void> _updateBedPeriod(String period) async {
    final TimeOfDay current = _bedTime ?? const TimeOfDay(hour: 23, minute: 0);
    setState(() {
      _bedTime = TimeOfDay(
        hour: _to24Hour(displayHour: _displayHour(current), period: period),
        minute: current.minute,
      );
    });
    await _tryCompleteSleepQuestion();
  }

  Future<void> _updateBedHour(int hour) async {
    final TimeOfDay current = _bedTime ?? const TimeOfDay(hour: 23, minute: 0);
    setState(() {
      _bedTime = TimeOfDay(
        hour: _to24Hour(displayHour: hour, period: _periodLabel(current)),
        minute: current.minute,
      );
    });
    await _tryCompleteSleepQuestion();
  }

  Future<void> _updateBedMinute(int minute) async {
    final TimeOfDay current = _bedTime ?? const TimeOfDay(hour: 23, minute: 0);
    setState(() {
      _bedTime = TimeOfDay(hour: current.hour, minute: minute);
    });
    await _tryCompleteSleepQuestion();
  }

  Future<void> _updateWakePeriod(String period) async {
    final TimeOfDay current = _wakeTime ?? const TimeOfDay(hour: 7, minute: 0);
    setState(() {
      _wakeTime = TimeOfDay(
        hour: _to24Hour(displayHour: _displayHour(current), period: period),
        minute: current.minute,
      );
    });
    await _tryCompleteSleepQuestion();
  }

  Future<void> _updateWakeHour(int hour) async {
    final TimeOfDay current = _wakeTime ?? const TimeOfDay(hour: 7, minute: 0);
    setState(() {
      _wakeTime = TimeOfDay(
        hour: _to24Hour(displayHour: hour, period: _periodLabel(current)),
        minute: current.minute,
      );
    });
    await _tryCompleteSleepQuestion();
  }

  Future<void> _updateWakeMinute(int minute) async {
    final TimeOfDay current = _wakeTime ?? const TimeOfDay(hour: 7, minute: 0);
    setState(() {
      _wakeTime = TimeOfDay(hour: current.hour, minute: minute);
    });
    await _tryCompleteSleepQuestion();
  }

  void _onOptionSelected(String option) {
    _answers[_currentQuestion.id] = option;
    _goToNextQuestion();
  }

  void _goToPreviousQuestion() {
    if (_currentIndex == 0) {
      return;
    }

    setState(() {
      _currentIndex -= 1;
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex >= widget.questions.length - 1) {
      widget.onCompleted?.call(Map<String, String>.from(_answers));
      setState(() {
        _currentIndex = widget.questions.length;
      });
      return;
    }

    setState(() {
      _currentIndex += 1;
    });
  }

  String _formatTime(TimeOfDay time) {
    final String hour = _displayHour(time).toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '${_periodLabel(time)} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final bool isComplete = _currentIndex >= widget.questions.length;

    return Scaffold(
      body: SafeArea(
        child: isComplete ? _buildCompleteView() : _buildSurveyView(),
      ),
    );
  }

  Widget _buildSurveyView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SurveyProgressHeader(
            currentIndex: _currentIndex,
            totalCount: widget.questions.length,
            onBack: _goToPreviousQuestion,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _currentQuestion.title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF17171B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _currentQuestion.requiresTimeInput
                ? _buildSleepTimeInput()
                : ListView.separated(
                    itemCount: _currentQuestion.options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = _currentQuestion.options[index];
                      return SurveyOptionButton(
                        label: option,
                        onTap: () => _onOptionSelected(option),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTimeInput() {
    return Column(
      children: <Widget>[
        SimpleTimeSelectCard(
          title: '취침 시간',
          selectedHour: _bedTime == null ? null : _displayHour(_bedTime!),
          selectedPeriod: _bedTime == null ? null : _periodLabel(_bedTime!),
          periods: _periods,
          selectedMinute: _bedTime?.minute,
          hours: _hours,
          minutes: _minutes,
          onPeriodChanged: _updateBedPeriod,
          onHourChanged: _updateBedHour,
          onMinuteChanged: _updateBedMinute,
        ),
        const SizedBox(height: 10),
        SimpleTimeSelectCard(
          title: '기상 시간',
          selectedHour: _wakeTime == null ? null : _displayHour(_wakeTime!),
          selectedPeriod: _wakeTime == null ? null : _periodLabel(_wakeTime!),
          periods: _periods,
          selectedMinute: _wakeTime?.minute,
          hours: _hours,
          minutes: _minutes,
          onPeriodChanged: _updateWakePeriod,
          onHourChanged: _updateWakeHour,
          onMinuteChanged: _updateWakeMinute,
        ),
      ],
    );
  }

  Widget _buildCompleteView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.check_circle_rounded, color: Color(0xFF6E63F7), size: 66),
            const SizedBox(height: 16),
            const Text(
              '설문이 완료되었어요',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '총 ${_answers.length}개 응답 저장',
              style: const TextStyle(fontSize: 16, color: Color(0xFF666670)),
            ),
          ],
        ),
      ),
    );
  }
}

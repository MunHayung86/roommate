import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../survey_service.dart';
import '../models/survey_question.dart';
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
  final SurveyService _surveyService = SurveyService();
  int _currentIndex = 0;
  final Map<String, String> _answers = <String, String>{};
  List<_RecommendedRule> _recommendedRules = <_RecommendedRule>[];
  int? _editingRuleIndex;
  String _editingRuleDraft = '';
  bool _isEditingBedTime = true;
  bool _isSubmittingSurvey = false;
  bool _isWaitingForMembers = false;
  bool _isSaving = false;
  TimeOfDay? _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay? _wakeTime = const TimeOfDay(hour: 7, minute: 0);

  int _displayHour(TimeOfDay time) {
    final int hour = time.hour % 12;
    return hour == 0 ? 12 : hour;
  }

  String _periodLabel(TimeOfDay time) {
    return time.hour < 12 ? '오전' : '오후';
  }

  SurveyQuestion get _currentQuestion => widget.questions[_currentIndex];

  void _syncSleepAnswer() {
    if (!_currentQuestion.requiresTimeInput) {
      return;
    }

    if (_bedTime == null || _wakeTime == null) {
      _answers.remove(_currentQuestion.id);
      return;
    }

    _answers[_currentQuestion.id] = '취침 ${_formatTime(_bedTime!)} / 기상 ${_formatTime(_wakeTime!)}';
  }

  Future<void> _onOptionSelected(String option) async {
    final String questionId = _currentQuestion.id;
    setState(() {
      _answers[questionId] = option;
    });

    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) {
      return;
    }

    if (_currentIndex >= widget.questions.length) {
      return;
    }

    if (_currentQuestion.id != questionId) {
      return;
    }

    if (_answers[questionId] != option) {
      return;
    }

    await _goToNextQuestion();
  }

  void _goToPreviousQuestion() {
    if (_currentIndex == 0) {
      return;
    }

    setState(() {
      _currentIndex -= 1;
    });
  }

  Future<void> _goToNextQuestion() async {
    if (_currentIndex >= widget.questions.length - 1) {
      await _completeSurvey();
      return;
    }

    setState(() {
      _currentIndex += 1;
    });
  }

  bool _canGoNext() {
    if (_currentQuestion.requiresTimeInput) {
      return _bedTime != null && _wakeTime != null;
    }
    return _answers.containsKey(_currentQuestion.id);
  }

  Future<void> _onNextPressed() async {
    if (!_canGoNext()) {
      return;
    }
    _syncSleepAnswer();
    await _goToNextQuestion();
  }

  String _formatTime(TimeOfDay time) {
    final String hour = _displayHour(time).toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '${_periodLabel(time)} $hour:$minute';
  }

  Future<void> _setManualTime({
    required bool isBedTime,
    required TimeOfDay time,
  }) async {
    setState(() {
      if (isBedTime) {
        _bedTime = time;
        _isEditingBedTime = true;
      } else {
        _wakeTime = time;
        _isEditingBedTime = false;
      }
    });

    _syncSleepAnswer();
  }

  List<_RecommendedRule> _generateRecommendedRules(Map<String, String> answers) {
    final List<String> ruleTexts = <String>[
      '손님 초대 시 사전에 룸메이트에게 알립니다.',
      '공용 물건 사용 후 원래 자리에 돌려놓습니다.',
      '개인 통화는 이어폰 사용을 권장합니다.',
    ];

    final String? food = answers['food_in_room'];
    if (food == '냄새 강한 음식은 불가') {
      ruleTexts.add('냄새가 강한 음식은 공용공간에서만 섭취합니다.');
    } else if (food == '방 안 음식 자체 불호') {
      ruleTexts.add('방 안에서는 음식 섭취를 하지 않습니다.');
    }

    final String? alarm = answers['alarm_style'];
    if (alarm == '2~3회 이내로만 울렸으면 좋겠다') {
      ruleTexts.add('아침 알람은 최대 2~3회 이내로 설정합니다.');
    }

    final String? keyboard = answers['keyboard_sound'];
    if (keyboard == '밤 시간대 제한 필요') {
      ruleTexts.add('밤 시간대에는 키보드/타자 소음을 최소화합니다.');
    }

    final String? standLight = answers['stand_light_after_quiet'];
    if (standLight == '낮은 밝기로만 사용 가능') {
      ruleTexts.add('취침 시간 이후 조명은 낮은 밝기로만 사용합니다.');
    } else if (standLight == '사용 금지') {
      ruleTexts.add('취침 시간 이후에는 스탠드 조명을 사용하지 않습니다.');
    }

    final String? returnHome = answers['return_home_style'];
    if (returnHome == '새벽 1~2시 귀가 잦음' || returnHome == '일정이 불규칙함') {
      ruleTexts.add('늦은 귀가 시에는 미리 메시지로 공유합니다.');
    }

    if (answers.containsKey('sleep_time')) {
      ruleTexts.add('서로의 취침/기상 시간을 존중해 소음을 줄입니다.');
    }

    final List<String> uniqueTexts = ruleTexts.toSet().toList();
    return List<_RecommendedRule>.generate(
      uniqueTexts.length,
      (int index) => _RecommendedRule(
        text: uniqueTexts[index],
        isSelected: index < 3,
      ),
    );
  }

  void _toggleRule(int index) {
    setState(() {
      final _RecommendedRule current = _recommendedRules[index];
      _recommendedRules[index] = current.copyWith(isSelected: !current.isSelected);
    });
  }

  void _startEditRule(int index) {
    setState(() {
      _editingRuleIndex = index;
      _editingRuleDraft = _recommendedRules[index].text;
    });
  }

  void _cancelEditRule() {
    setState(() {
      _editingRuleIndex = null;
      _editingRuleDraft = '';
    });
  }

  void _confirmEditRule() {
    final int? index = _editingRuleIndex;
    if (index == null) {
      return;
    }
    final String trimmed = _editingRuleDraft.trim();
    if (trimmed.isEmpty) {
      return;
    }
    setState(() {
      _recommendedRules[index] = _recommendedRules[index].copyWith(text: trimmed);
      _editingRuleIndex = null;
      _editingRuleDraft = '';
    });
  }

  Future<void> _completeSurvey() async {
    if (_isSubmittingSurvey) {
      return;
    }

    final Map<String, String> finalAnswers = Map<String, String>.from(_answers);
    final List<_RecommendedRule> generatedRules = _generateRecommendedRules(finalAnswers);

    setState(() {
      _isSubmittingSurvey = true;
    });

    try {
      await _surveyService.saveSurveyAnswers(answers: finalAnswers);
      final bool isAllCompleted = await _surveyService.areAllMembersSurveyCompleted();

      if (!mounted) {
        return;
      }

      widget.onCompleted?.call(finalAnswers);
      setState(() {
        _currentIndex = widget.questions.length;
        _recommendedRules = generatedRules;
        _isWaitingForMembers = !isAllCompleted;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설문 저장에 실패했어요. 잠시 후 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingSurvey = false;
        });
      }
    }
  }

  Future<void> _saveSurveyResult() async {
    if (_isSaving) {
      return;
    }

    final List<String> selectedRules = _recommendedRules
        .where((rule) => rule.isSelected)
        .map((rule) => rule.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (selectedRules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1개 이상의 규칙을 선택해 주세요.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _surveyService.saveSelectedRules(selectedRules: selectedRules);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설문 저장에 실패했어요. 잠시 후 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isComplete = _currentIndex >= widget.questions.length;
    final bool showWaiting = isComplete && _isWaitingForMembers;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: showWaiting
            ? _buildWaitingView()
            : isComplete
                ? _buildCompleteView()
                : _buildSurveyView(),
      ),
    );
  }

  Widget _buildSurveyView() {
    final List<String> titleParts = _currentQuestion.title.split('\n');
    final String titleEmoji = titleParts.first.trim();
    final String titleText = titleParts.length > 1
        ? titleParts.sublist(1).join('\n').trim()
        : _currentQuestion.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SurveyProgressHeader(
            currentIndex: _currentIndex,
            totalCount: widget.questions.length,
            onBack: _goToPreviousQuestion,
            showBackButton: !_currentQuestion.requiresTimeInput,
          ),
          const SizedBox(height: 28),
          Text(
            titleEmoji,
            style: const TextStyle(fontSize: 38, height: 1),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Text(
              titleText,
              style: const TextStyle(
                fontFamily: 'Pretendard Variable',
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 1.45,
                letterSpacing: -1,
                color: Color(0xFF17171B),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_currentIndex == 1) ...<Widget>[
            const Text(
              '설문 결과는 언제든지 수정할 수 있어요!',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0,
                color: Color(0xFF717182),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
          if (_currentQuestion.requiresTimeInput) ...<Widget>[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _canGoNext() ? const Color(0xFF6C5CE7) : const Color(0xFFCFCFE6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _canGoNext() && !_isSubmittingSurvey ? _onNextPressed : null,
                child: _isSubmittingSurvey
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '다음',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepTimeInput() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _SleepTimeValueCard(
            title: '취침 시간',
            isActive: _isEditingBedTime,
            initialTime: _bedTime ?? const TimeOfDay(hour: 23, minute: 0),
            onTap: () {
              setState(() {
                _isEditingBedTime = true;
              });
            },
            onTimeChanged: (TimeOfDay time) => _setManualTime(isBedTime: true, time: time),
          ),
          const SizedBox(height: 8),
          _SleepTimeValueCard(
            title: '기상 시간',
            isActive: !_isEditingBedTime,
            initialTime: _wakeTime ?? const TimeOfDay(hour: 7, minute: 0),
            onTap: () {
              setState(() {
                _isEditingBedTime = false;
              });
            },
            onTimeChanged: (TimeOfDay time) => _setManualTime(isBedTime: false, time: time),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingView() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _surveyService.watchCurrentUserRoom(),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.hasData) {
          final Map<String, dynamic>? roomData = snapshot.data?.data();
          final bool isAllCompleted =
              _surveyService.isAllMembersCompletedFromData(roomData);

          if (isAllCompleted) {
            return _buildCompleteView();
          }
        }

        final List<dynamic> memberIds =
            (snapshot.data?.data()?['memberIds'] as List<dynamic>?) ?? <dynamic>[];
        final List<dynamic> completedIds = (snapshot.data
                ?.data()?['surveyCompletedMemberIds'] as List<dynamic>?) ??
            <dynamic>[];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 24),
              const Text(
                '설문 완료 대기 중',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1D24),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '다른 룸메이트가 설문을 완료하면\n방 규칙 정하기 화면이 열려요.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF717182),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      '설문 완료 인원',
                      style: TextStyle(fontSize: 15, color: Color(0xFF1E1D24)),
                    ),
                    Text(
                      '${completedIds.length} / ${memberIds.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                ),
              ),
              const SizedBox(height: 34),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompleteView() {
    final int selectedCount = _recommendedRules.where((rule) => rule.isSelected).length;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            children: <Widget>[
              const Text(
                '방 규칙 정하기',
                style: TextStyle(
                  fontFamily: 'Pretendard Variable',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0,
                  color: Color(0xFF0A0A0A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '설문 결과를 바탕으로 추천된 규칙이에요.',
                style: TextStyle(
                  fontFamily: 'Pretendard Variable',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0,
                  color: Color(0xFF717182),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '채택할 규칙을 선택하고, 필요하면 수정하세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard Variable',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.457,
                  letterSpacing: 0,
                  color: Color(0xFF717182),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x1A6C5CE7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$selectedCount개 채택됨',
                      style: const TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 1,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ...List<Widget>.generate(_recommendedRules.length, (int index) {
                final _RecommendedRule rule = _recommendedRules[index];
                final bool isEditing = _editingRuleIndex == index;
                final Color borderColor =
                    rule.isSelected ? const Color(0xFF6C5CE7) : const Color(0xFFE2E2E9);

                if (isEditing) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8FC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF6C5CE7), width: 2),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFCFCDF8)),
                            ),
                            child: TextField(
                              controller: TextEditingController(text: _editingRuleDraft)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: _editingRuleDraft.length),
                                ),
                              minLines: 2,
                              maxLines: 4,
                              onChanged: (String value) {
                                _editingRuleDraft = value;
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                                fontSize: 14.4,
                                height: 1.5,
                                letterSpacing: 0,
                                color: Color(0xFF1E1D24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: _cancelEditRule,
                                child: Container(
                                  width: 54,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFFEFF0F3),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF7B8090),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: _confirmEditRule,
                                child: Container(
                                  width: 60,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFF6C5CE7),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _toggleRule(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _toggleRule(index),
                            child: Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor),
                                color: rule.isSelected
                                    ? const Color(0xFF6C5CE7)
                                    : Colors.transparent,
                              ),
                              child: rule.isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rule.text,
                              style: const TextStyle(
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w400,
                                fontSize: 14.4,
                                height: 1.5,
                                letterSpacing: 0,
                                color: Color(0xFF1E1D24),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _startEditRule(index),
                            visualDensity: VisualDensity.compact,
                            icon: Image.asset(
                              'assets/images/pen.png',
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20.32),
          child: Center(
            child: Container(
              width: 354,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x406C5CE7),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color(0x406C5CE7),
                    offset: Offset(0, 10),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _saveSurveyResult,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '저장하기',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

class _RecommendedRule {
  const _RecommendedRule({
    required this.text,
    required this.isSelected,
  });

  final String text;
  final bool isSelected;

  _RecommendedRule copyWith({
    String? text,
    bool? isSelected,
  }) {
    return _RecommendedRule(
      text: text ?? this.text,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class _SleepTimeValueCard extends StatelessWidget {
  const _SleepTimeValueCard({
    required this.title,
    required this.isActive,
    required this.initialTime,
    required this.onTap,
    required this.onTimeChanged,
  });

  final String title;
  final bool isActive;
  final TimeOfDay initialTime;
  final VoidCallback onTap;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFFE2E2E9),
          ),
          color: const Color(0xFFF9F9FC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF717182),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E2E9)),
              ),
              child: _InlineTimeEditor(
                key: ValueKey<String>(title),
                time: initialTime,
                onChanged: onTimeChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineTimeEditor extends StatefulWidget {
  const _InlineTimeEditor({
    super.key,
    required this.time,
    required this.onChanged,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<_InlineTimeEditor> createState() => _InlineTimeEditorState();
}

class _InlineTimeEditorState extends State<_InlineTimeEditor> {
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  late String _period;

  @override
  void initState() {
    super.initState();
    _hourController = TextEditingController();
    _minuteController = TextEditingController();
    _syncFromTime(widget.time);
  }

  @override
  void didUpdateWidget(covariant _InlineTimeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time) {
      _syncFromTime(widget.time);
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

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

  void _syncFromTime(TimeOfDay time) {
    _period = _periodLabel(time);
    _hourController.text = _displayHour(time).toString();
    _minuteController.text = time.minute.toString().padLeft(2, '0');
  }

  void _emitIfValid() {
    final int? hour = int.tryParse(_hourController.text);
    final int? minute = int.tryParse(_minuteController.text);
    if (hour == null || minute == null) {
      return;
    }
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
      return;
    }
    widget.onChanged(
      TimeOfDay(hour: _to24Hour(displayHour: hour, period: _period), minute: minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _period,
            icon: const Icon(Icons.expand_more_rounded, size: 18),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A30),
            ),
            items: const <String>['오전', '오후']
                .map(
                  (String p) => DropdownMenuItem<String>(
                    value: p,
                    child: Text(p),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value == null) {
                return;
              }
              setState(() {
                _period = value;
              });
              _emitIfValid();
            },
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: TextField(
            controller: _hourController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A30),
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => _emitIfValid(),
          ),
        ),
        const Text(
          ':',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF2A2A30)),
        ),
        SizedBox(
          width: 36,
          child: TextField(
            controller: _minuteController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A30),
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => _emitIfValid(),
          ),
        ),
      ],
    );
  }
}

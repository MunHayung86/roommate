import '../models/survey_question.dart';

const List<SurveyQuestion> kLifestyleQuestions = <SurveyQuestion>[
  SurveyQuestion(
    id: 'sleep_time',
    title: '수면 시간',
    requiresTimeInput: true,
  ),
  SurveyQuestion(
    id: 'food_in_room',
    title: '방 안에서 음식은?',
    options: <String>['식사 가능', '간식만 가능', '냄새 강한 음식은 불가', '방 안 음식 자체 불호'],
  ),
  SurveyQuestion(
    id: 'phone_call_in_room',
    title: '방 안에서 통화는?',
    options: <String>['자유롭게 가능', '이어폰 사용 시 가능', '5분 이내 통화 가능', '방 안 통화 불가'],
  ),
  SurveyQuestion(
    id: 'vacuum_frequency',
    title: '청소기 사용은 어느 정도가 적당하다고 생각하나요?',
    options: <String>['주 2회', '주 1회', '격주 1회', '더러워질 때'],
  ),
  SurveyQuestion(
    id: 'ventilation_frequency',
    title: '환기는 얼마나 자주 하는 게 좋나요?',
    options: <String>['매일', '이틀에 한 번', '주 1~2회', '필요할 때만'],
  ),
  SurveyQuestion(
    id: 'alarm_style',
    title: '알람 설정 스타일은?',
    options: <String>['2~3회 이내로만 울렸으면 좋겠다', '여러 번 울려도 괜찮다', '진동 위주가 좋다', '알람 사용 금지'],
  ),
  SurveyQuestion(
    id: 'keyboard_sound',
    title: '방 안에서 타자(키보드 소리)는?',
    options: <String>['자유롭게 가능', '조용한 키보드만 가능', '밤 시간대 제한 필요', '가급적 자제'],
  ),
  SurveyQuestion(
    id: 'stand_light_after_quiet',
    title: '침묵 시간 이후 스탠드 조명 사용은?',
    options: <String>['제한 없이 사용 가능', '사용 금지', '낮은 밝기로만 사용 가능'],
  ),
  SurveyQuestion(
    id: 'return_home_style',
    title: '귀가 스타일은?',
    options: <String>['밤 10시 이전 귀가', '12시 전후', '새벽 1~2시 귀가 잦음', '일정이 불규칙함'],
  ),
  SurveyQuestion(
    id: 'scent_sensitivity',
    title: '향/냄새에 대한 민감도는?',
    options: <String>['향수/디퓨저 불호', '강한 향만 불호', '상관 없음', '오히려 향 나는 걸 좋아함'],
  ),
];

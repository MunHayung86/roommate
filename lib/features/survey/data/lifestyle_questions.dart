import '../models/survey_question.dart';

const List<SurveyQuestion> kLifestyleQuestions = <SurveyQuestion>[
  SurveyQuestion(
    id: 'sleep_time',
    title: '🕒 \n다이얼을 돌려 수면시간을 알려주세요',
    requiresTimeInput: true,
  ),
  SurveyQuestion(
    id: 'food_in_room',
    title: '🍗 \n방에서 음식, \n얼마나 허용하면 좋을까요?',
    options: <String>['식사 가능', '간식만 가능', '냄새 강한 음식은 불가', '방에서 취식 금지'],
  ),
  SurveyQuestion(
    id: 'phone_call_in_room',
    title: '📞 \n방에서 전화를 해도 \n괜찮다고 생각하시나요?',
    options: <String>['자유롭게 가능', '이어폰 끼고 전화 가능', '5분 이내의 짧은 통화는 가능', '방 안 통화 불가'],
  ),
  SurveyQuestion(
    id: 'vacuum_frequency',
    title: '🧹 \n청결을 위한 청소,  \n얼마나 자주 하시나요?',
    options: <String>['주 2회 이상', '주 1회', '격주 1회', '가끔, 더러워질 때'],
  ),
  SurveyQuestion(
    id: 'ventilation_frequency',
    title: '🪟 \n신선한 공기를 위한 환기는  \n얼마나 자주 하시나요?',
    options: <String>['매일', '이틀에 한 번', '주 1~2회', '필요할 때만'],
  ),
  SurveyQuestion(
    id: 'alarm_style',
    title: '⏰ \n아침마다 들리는 알람 소리,  \n어떻게 울리면 좋을까요?',
    options: <String>['소리 알람도 여러 번 울려도 됨', '소리 알람은 2~3회 이내로 울리길 희망', '진동 알람은 여러 번 울려도 됨', '진동 알람도 2~3회 이내로 울리길 희망'],
  ),
  SurveyQuestion(
    id: 'keyboard_sound',
    title: '💻 \n키보드 사용은  \n어떻게 하면 좋을까요?',
    options: <String>['자유롭게 가능', '조용한 키보드만 가능', '밤 시간대 제한 필요', '가급적 자제'],
  ),
  SurveyQuestion(
    id: 'stand_light_after_quiet',
    title: '🔦 \n취침을 위한 소등 이후,  \n스탠드를 어떻게 사용하면 좋을까요?',
    options: <String>['제한 없이 사용 가능', '사용 금지', '낮은 밝기로만 사용 가능', '특정 시간 이후에는 완전 소등을 희망'],
  ),
  SurveyQuestion(
    id: 'return_home_style',
    title: '🏠 \n평소 귀가시간은 어떻게 되시나요?',
    options: <String>['밤 10시 이전 귀가', '12시 전후로 귀가', '새벽 1시 이후 귀가', '기타, 일정이 불규칙함'],
  ),
  SurveyQuestion(
    id: 'scent_sensitivity',
    title: '🧴 \n향수나 디퓨저 등의 자극에  \n얼마나 민감하신가요?',
    options: <String>['향수/디퓨저 불호', '강한 향만 불호', '상관 없음', '오히려 향 나는 걸 좋아함'],
  ),
];

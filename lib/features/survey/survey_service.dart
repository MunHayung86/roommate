import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SurveyService {
  SurveyService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> saveSurveyAnswers({
    required Map<String, String> answers,
  }) async {
    final ({User user, DocumentReference<Map<String, dynamic>> userRef, DocumentReference<Map<String, dynamic>> roomRef}) context =
        await _resolveContext();
    final User user = context.user;
    final DocumentReference<Map<String, dynamic>> userRef = context.userRef;
    final DocumentReference<Map<String, dynamic>> roomRef = context.roomRef;
    final DocumentReference<Map<String, dynamic>> roomSurveyRef =
        roomRef.collection('surveys').doc(user.uid);

    final WriteBatch batch = _firestore.batch();

    batch.set(
      userRef,
      <String, dynamic>{
        'surveyAnswers': answers,
        'hasCompletedSurvey': true,
        'surveyUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      roomSurveyRef,
      <String, dynamic>{
        'uid': user.uid,
        'answers': answers,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      roomRef,
      <String, dynamic>{
        'surveyCompletedMemberIds': FieldValue.arrayUnion(<String>[user.uid]),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> saveSelectedRules({
    required List<String> selectedRules,
  }) async {
    final ({User user, DocumentReference<Map<String, dynamic>> userRef, DocumentReference<Map<String, dynamic>> roomRef}) context =
        await _resolveContext();
    final User user = context.user;
    final DocumentReference<Map<String, dynamic>> userRef = context.userRef;
    final DocumentReference<Map<String, dynamic>> roomRef = context.roomRef;
    final DocumentReference<Map<String, dynamic>> roomSurveyRef =
        roomRef.collection('surveys').doc(user.uid);

    final WriteBatch batch = _firestore.batch();

    batch.set(
      userRef,
      <String, dynamic>{
        'selectedRules': selectedRules,
        'rulesUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      roomSurveyRef,
      <String, dynamic>{
        'selectedRules': selectedRules,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      roomRef,
      <String, dynamic>{
        'rules': selectedRules,
        'rulesGenerated': true,
        'rulesUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<bool> areAllMembersSurveyCompleted() async {
    final ({User user, DocumentReference<Map<String, dynamic>> userRef, DocumentReference<Map<String, dynamic>> roomRef}) context =
        await _resolveContext();
    final DocumentSnapshot<Map<String, dynamic>> roomSnapshot = await context.roomRef.get();
    return _isAllMembersCompleted(roomSnapshot.data());
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserRoom() async* {
    final ({User user, DocumentReference<Map<String, dynamic>> userRef, DocumentReference<Map<String, dynamic>> roomRef}) context =
        await _resolveContext();
    yield* context.roomRef.snapshots();
  }

  bool isAllMembersCompletedFromData(Map<String, dynamic>? roomData) {
    return _isAllMembersCompleted(roomData);
  }

  bool _isAllMembersCompleted(Map<String, dynamic>? roomData) {
    final List<dynamic> memberIds = (roomData?['memberIds'] as List<dynamic>?) ?? <dynamic>[];
    final List<dynamic> completedIds =
        (roomData?['surveyCompletedMemberIds'] as List<dynamic>?) ?? <dynamic>[];

    if (memberIds.isEmpty) {
      return false;
    }
    return completedIds.length >= memberIds.length;
  }

  /// 방에 속한 모든 멤버의 설문 답변 수집 (rooms/{roomId}/surveys)
  Future<List<Map<String, String>>> getRoomSurveyAnswers() async {
    final context = await _resolveContext();
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await context.roomRef.collection('surveys').get();
    final List<Map<String, String>> list = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final raw = data['answers'];
      if (raw is! Map) continue;
      final Map<String, String> answers = {};
      raw.forEach((k, v) {
        if (k is String && v != null) answers[k] = v.toString();
      });
      if (answers.isNotEmpty) list.add(answers);
    }
    return list;
  }

  /// 항목별로 가장 많이 나온 답(다수결)을 하나씩 골라 하나의 Map으로 반환
  Map<String, String> aggregateAnswersByMajority(
    List<Map<String, String>> answersList,
  ) {
    if (answersList.isEmpty) return {};
    final Map<String, Map<String, int>> counts = {};
    for (final answers in answersList) {
      answers.forEach((String key, String value) {
        counts.putIfAbsent(key, () => {});
        counts[key]![value] = (counts[key]![value] ?? 0) + 1;
      });
    }
    final Map<String, String> result = {};
    counts.forEach((key, valueCounts) {
      String? maxValue;
      int maxCount = 0;
      valueCounts.forEach((value, count) {
        if (count > maxCount) {
          maxCount = count;
          maxValue = value;
        }
      });
      if (maxValue != null) result[key] = maxValue!;
    });
    return result;
  }

  /// 집계된 답변 Map을 바탕으로 추천 규칙 문장 리스트 생성 (방 전체 다수결 반영)
  List<String> generateRecommendedRulesFromAnswers(
    Map<String, String> answers,
  ) {
    final List<String> ruleTexts = <String>[];

    final String? food = answers['food_in_room'];
    if (food == '냄새 강한 음식은 불가') {
      ruleTexts.add('냄새가 강한 음식은 공용공간에서만 섭취합니다.');
    } else if (food == '방에서 취식 금지' || food == '방 안 음식 자체 불호') {
      ruleTexts.add('방 안에서는 음식 섭취를 하지 않습니다.');
    }

    final String? phone = answers['phone_call_in_room'];
    if (phone == '방 안 통화 불가') {
      ruleTexts.add('방에서는 통화를 금지합니다.');
    } else if (phone == '5분 이내의 짧은 통화는 가능') {
      ruleTexts.add('방 안에서는 5분 이내의 짧은 통화만 가능합니다.');
    } else if (phone == '이어폰 끼고 전화 가능') {
      ruleTexts.add('방 안 통화 시 이어폰을 사용합니다.');
    }

    final String? vacuum = answers['vacuum_frequency'];
    if (vacuum == '주 2회 이상') {
      ruleTexts.add('청소는 주 2회 이상 진행합니다.');
    } else if (vacuum == '주 1회') {
      ruleTexts.add('청소는 주 1회 이상 진행합니다.');
    } else if (vacuum == '격주 1회') {
      ruleTexts.add('청소는 격주 1회 이상 진행합니다.');
    } else if (vacuum == '가끔, 더러워질 때') {
      ruleTexts.add('눈에 띄게 더러워지면 청소합니다.');
    }

    final String? ventilation = answers['ventilation_frequency'];
    if (ventilation == '매일') {
      ruleTexts.add('환기는 매일 진행합니다.');
    } else if (ventilation == '이틀에 한 번') {
      ruleTexts.add('환기는 이틀에 한 번 이상 진행합니다.');
    } else if (ventilation == '주 1~2회') {
      ruleTexts.add('환기는 주 1~2회 이상 진행합니다.');
    } else if (ventilation == '필요할 때만') {
      ruleTexts.add('필요할 때 환기합니다.');
    }

    final String? alarm = answers['alarm_style'];
    if (alarm == '소리 알람은 2~3회 이내로 울리길 희망' ||
        alarm == '진동 알람도 2~3회 이내로 울리길 희망' ||
        alarm == '2~3회 이내로만 울렸으면 좋겠다') {
      ruleTexts.add('아침 알람은 최대 2~3회 이내로 설정합니다.');
    }

    final String? keyboard = answers['keyboard_sound'];
    if (keyboard == '밤 시간대 제한 필요') {
      ruleTexts.add('밤 시간대에는 키보드/타자 소음을 최소화합니다.');
    } else if (keyboard == '가급적 자제') {
      ruleTexts.add('방 안에서는 키보드 사용을 가급적 자제합니다.');
    }

    final String? standLight = answers['stand_light_after_quiet'];
    if (standLight == '낮은 밝기로만 사용 가능') {
      ruleTexts.add('취침 시간 이후 조명은 낮은 밝기로만 사용합니다.');
    } else if (standLight == '사용 금지') {
      ruleTexts.add('취침 시간 이후에는 스탠드 조명을 사용하지 않습니다.');
    }

    final String? returnHome = answers['return_home_style'];
    if (returnHome == '새벽 1시 이후 귀가' ||
        returnHome == '기타, 일정이 불규칙함' ||
        returnHome == '새벽 1~2시 귀가 잦음' ||
        returnHome == '일정이 불규칙함') {
      ruleTexts.add('늦은 귀가 시에는 미리 메시지로 공유합니다.');
    }

    if (answers.containsKey('sleep_time') && answers['sleep_time']!.isNotEmpty) {
      ruleTexts.add('서로의 취침/기상 시간을 존중해 소음을 줄입니다.');
    }

    final String? scent = answers['scent_sensitivity'];
    if (scent == '향수/디퓨저 불호') {
      ruleTexts.add('방 안에서는 향수·디퓨저 사용을 자제합니다.');
    } else if (scent == '강한 향만 불호') {
      ruleTexts.add('강한 향은 방 안에서 자제합니다.');
    }

    return ruleTexts.toSet().toList();
  }

  Future<({User user, DocumentReference<Map<String, dynamic>> userRef, DocumentReference<Map<String, dynamic>> roomRef})>
      _resolveContext() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인한 사용자 정보가 없습니다.');
    }

    final DocumentReference<Map<String, dynamic>> userRef =
        _firestore.collection('users').doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();
    final String? roomId = userSnapshot.data()?['roomId'] as String?;

    if (roomId == null || roomId.isEmpty) {
      throw Exception('참여 중인 방 정보가 없습니다.');
    }

    final DocumentReference<Map<String, dynamic>> roomRef =
        _firestore.collection('rooms').doc(roomId);

    return (user: user, userRef: userRef, roomRef: roomRef);
  }
}

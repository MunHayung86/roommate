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

  Future<void> saveSurveyAndRules({
    required Map<String, String> answers,
    required List<String> selectedRules,
  }) async {
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
    final DocumentReference<Map<String, dynamic>> roomSurveyRef =
        roomRef.collection('surveys').doc(user.uid);

    // 기존 방 규칙과 이번에 선택한 규칙을 합쳐 하나의 룸 규칙 세트로 만든다.
    final DocumentSnapshot<Map<String, dynamic>> roomSnapshot =
        await roomRef.get();
    final List<dynamic> existingRulesDynamic =
        (roomSnapshot.data()?['rules'] as List<dynamic>?) ?? <dynamic>[];
    final List<String> existingRules =
        existingRulesDynamic.map((dynamic e) => e.toString()).toList();
    final List<String> mergedRules = <String>[
      ...existingRules,
      ...selectedRules,
    ].toSet().toList();

    final WriteBatch batch = _firestore.batch();

    batch.set(
      userRef,
      <String, dynamic>{
        'surveyAnswers': answers,
        'selectedRules': selectedRules,
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
        'selectedRules': selectedRules,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      roomRef,
      <String, dynamic>{
        'rules': mergedRules,
        'rulesGenerated': true,
        'rulesUpdatedAt': FieldValue.serverTimestamp(),
        'surveyCompletedMemberIds': FieldValue.arrayUnion(<String>[user.uid]),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}

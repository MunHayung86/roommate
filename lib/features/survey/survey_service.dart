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
        'rules': mergedRules,
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

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// rooms 컬렉션 구조
  /// rooms/{roomId} {
  ///   name: String,
  ///   motto: String,
  ///   inviteCode: String,        // 6자리 초대 코드 (유니크)
  ///   ownerId: String,           // 방 만든 uid
  ///   memberIds: List<String>,   // 현재 멤버 uid 목록
  ///   surveyCompletedMemberIds: List<String>,
  ///   rulesGenerated: bool,
  ///   createdAt: Timestamp
  /// }

  Future<String> createRoom({
    required String name,
    required String motto,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인한 사용자 정보가 없습니다.');
    }

    final String inviteCode = await _generateUniqueInviteCode();

    final DocumentReference<Map<String, dynamic>> roomRef =
        await _firestore.collection('rooms').add(<String, dynamic>{
      'name': name,
      'motto': motto,
      'inviteCode': inviteCode,
      'ownerId': user.uid,
      'memberIds': <String>[user.uid],
      'surveyCompletedMemberIds': <String>[],
      'rulesGenerated': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(user.uid).set(
      <String, dynamic>{
        'roomId': roomRef.id,
      },
      SetOptions(merge: true),
    );

    return inviteCode;
  }

  /// 초대 코드로 방에 참여
  Future<void> joinRoomByInviteCode(String inviteCode) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인한 사용자 정보가 없습니다.');
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('rooms')
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('해당 코드를 가진 방을 찾을 수 없습니다.');
    }

    final DocumentSnapshot<Map<String, dynamic>> roomDoc = snapshot.docs.first;
    final String roomId = roomDoc.id;

    final WriteBatch batch = _firestore.batch();

    // 방의 memberIds 배열에 사용자 추가
    batch.update(roomDoc.reference, <String, dynamic>{
      'memberIds': FieldValue.arrayUnion(<String>[user.uid]),
    });

    // 유저 문서에 roomId 저장 (추후 확장 시 joinedRoomIds로 바꿀 수 있음)
    final DocumentReference<Map<String, dynamic>> userRef =
        _firestore.collection('users').doc(user.uid);

    batch.set(
      userRef,
      <String, dynamic>{
        'roomId': roomId,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// 현재 사용자가 속한 방 정보 가져오기
  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserRoom() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    final String? roomId = userDoc.data()?['roomId'] as String?;

    if (roomId == null) {
      return null;
    }

    return _firestore.collection('rooms').doc(roomId).get();
  }

  Future<String> _generateUniqueInviteCode() async {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random rand = Random();

    while (true) {
      final String code = String.fromCharCodes(
        Iterable<int>.generate(
          6,
          (_) => chars.codeUnitAt(rand.nextInt(chars.length)),
        ),
      );

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('rooms')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return code;
      }
    }
  }
}



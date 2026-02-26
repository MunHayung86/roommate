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
  ///   memberIds: `List<String>`,   // 현재 멤버 uid 목록
  ///   surveyCompletedMemberIds: `List<String>`,
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

  /// 방 규칙 업데이트 (직접 규칙 생성/수정 시)
  Future<void> updateRoomRules(String roomId, List<String> rules) async {
    await _firestore.collection('rooms').doc(roomId).update(<String, dynamic>{
      'rules': rules,
      'rulesUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 현재 사용자가 속한 방 정보 가져오기
  /// [fromServer] true면 캐시 없이 서버에서 최신 데이터를 가져옵니다.
  Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserRoom({
    bool fromServer = false,
  }) async {
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

    if (fromServer) {
      return _firestore
          .collection('rooms')
          .doc(roomId)
          .get(const GetOptions(source: Source.server));
    }
    return _firestore.collection('rooms').doc(roomId).get();
  }

  /// 방 멤버 목록 (uid, nickname, photoUrl [, wakeupTime, isAlarmOn])
  Future<List<Map<String, dynamic>>> getRoomMembers(
    String roomId, {
    bool includeWakeup = false,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> roomDoc =
        await _firestore.collection('rooms').doc(roomId).get();

    if (!roomDoc.exists) return [];

    final List<dynamic> memberIdsRaw =
        (roomDoc.data()?['memberIds'] as List<dynamic>?) ?? [];
    final List<String> orderedMemberIds =
        memberIdsRaw.map((id) => id.toString()).toList();

    // Safety net: some rooms may have stale memberIds.
    // Also collect users that currently point to this room via users.roomId.
    final QuerySnapshot<Map<String, dynamic>> roomUsersSnapshot = await _firestore
        .collection('users')
        .where('roomId', isEqualTo: roomId)
        .get();

    final Map<String, Map<String, dynamic>> roomUsersByUid = {
      for (final doc in roomUsersSnapshot.docs) doc.id: doc.data(),
    };
    for (final uid in roomUsersByUid.keys) {
      if (!orderedMemberIds.contains(uid)) {
        orderedMemberIds.add(uid);
      }
    }

    if (orderedMemberIds.isEmpty) return [];

    final List<Map<String, dynamic>> members = [];
    for (final uid in orderedMemberIds) {
      Map<String, dynamic>? data = roomUsersByUid[uid];
      if (data == null) {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(uid).get();
        if (!userDoc.exists) continue;
        data = userDoc.data();
      }
      if (data == null) continue;

      final map = <String, dynamic>{
        'uid': uid,
        'nickname': data['nickname'] as String? ?? '알 수 없음',
        'photoUrl': data['photoUrl'] as String?,
      };
      if (includeWakeup) {
        map['wakeupTime'] = data['wakeupTime'] as String? ?? '--:--';
        map['isAlarmOn'] = data['alarmOn'] as bool? ?? false;
      }
      members.add(map);
    }
    return members;
  }

  /// 특정 멤버의 설문 응답 (users/{uid}.surveyAnswers). 없으면 null.
  Future<Map<String, String>?> getMemberSurveyAnswers(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    final raw = data['surveyAnswers'];
    if (raw is! Map) return null;
    final Map<String, String> result = {};
    raw.forEach((k, v) {
      if (k is String && v != null) result[k] = v.toString();
    });
    return result.isEmpty ? null : result;
  }

  /// 현재 유저 기상 시간·알람 설정 저장
  Future<void> setMyWakeup({required String wakeupTime, required bool alarmOn}) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('로그인한 사용자 정보가 없습니다.');
    await _firestore.collection('users').doc(user.uid).set(
      <String, dynamic>{
        'wakeupTime': wakeupTime,
        'alarmOn': alarmOn,
      },
      SetOptions(merge: true),
    );
  }

  /// 방 나가기 (현재 유저를 방에서 제거, users.roomId 제거)
  Future<void> leaveRoom() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('로그인한 사용자 정보가 없습니다.');

    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    final String? roomId = userDoc.data()?['roomId'] as String?;
    if (roomId == null) throw Exception('참여 중인 방이 없습니다.');

    final WriteBatch batch = _firestore.batch();

    batch.update(
      _firestore.collection('rooms').doc(roomId),
      <String, dynamic>{'memberIds': FieldValue.arrayRemove(<String>[user.uid])},
    );
    batch.set(
      _firestore.collection('users').doc(user.uid),
      <String, dynamic>{'roomId': FieldValue.delete()},
      SetOptions(merge: true),
    );

    await batch.commit();
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

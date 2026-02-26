/// 깨워줘 화면의 룸메이트 한 명 항목.
/// 나중에 Firestore 등에서 [roomId] 방 멤버의 기상 설정을 불러와 채울 수 있음.
class RoommateWakeupItem {
  const RoommateWakeupItem({
    required this.id,
    required this.name,
    required this.wakeupTime,
    this.isAlarmOn = false,
    this.profileImageUrl,
    this.isHighlighted = false,
  });

  /// Firestore document id 또는 고유 식별자
  final String id;

  /// 표시 이름 (예: 이서준)
  final String name;

  /// 기상 시간 "HH:mm" (예: "07:00")
  final String wakeupTime;

  /// 알람 켜짐 여부. true면 시계 아이콘, false면 zzz 아이콘
  final bool isAlarmOn;

  /// 프로필 이미지 URL (Firebase Storage 등). null이면 기본 asset 사용
  final String? profileImageUrl;

  /// 강조 카드 여부 (노란 배경 #FFF9DB). 깨워달라 요청 중인 룸메 등
  final bool isHighlighted;

  RoommateWakeupItem copyWith({
    String? id,
    String? name,
    String? wakeupTime,
    bool? isAlarmOn,
    String? profileImageUrl,
    bool? isHighlighted,
  }) {
    return RoommateWakeupItem(
      id: id ?? this.id,
      name: name ?? this.name,
      wakeupTime: wakeupTime ?? this.wakeupTime,
      isAlarmOn: isAlarmOn ?? this.isAlarmOn,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  /// Firestore Map → RoommateWakeupItem (연동 시 사용)
  static RoommateWakeupItem? fromMap(Map<String, dynamic>? data, {String? id}) {
    if (data == null) return null;
    return RoommateWakeupItem(
      id: id ?? data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      wakeupTime: data['wakeupTime'] as String? ?? '00:00',
      isAlarmOn: data['isAlarmOn'] as bool? ?? false,
      profileImageUrl: data['profileImageUrl'] as String?,
      isHighlighted: data['isHighlighted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'wakeupTime': wakeupTime,
      'isAlarmOn': isAlarmOn,
      'profileImageUrl': profileImageUrl,
      'isHighlighted': isHighlighted,
    };
  }
}

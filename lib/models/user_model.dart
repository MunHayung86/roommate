class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final String? roomId;

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.roomId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'roomId': roomId,
      'createdAt': DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      nickname: map['nickname'],
      roomId: map['roomId'],
    );
  }
}
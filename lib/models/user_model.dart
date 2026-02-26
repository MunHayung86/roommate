class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final String? photoUrl;
  final String? roomId;

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.photoUrl,
    this.roomId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'roomId': roomId,
      'createdAt': DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      nickname: map['nickname'],
      photoUrl: map['photoUrl'],
      roomId: map['roomId'],
    );
  }
}

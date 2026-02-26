import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(User user, String nickname) async {
    final userDoc =
        _firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    final UserModel newUser = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      nickname: nickname,
      photoUrl: user.photoURL,
    );

    if (!docSnapshot.exists) {
      await userDoc.set(newUser.toMap());
      return;
    }

    await userDoc.set(
      <String, dynamic>{
        'email': user.email ?? '',
        'nickname': nickname,
        'photoUrl': user.photoURL,
        'lastLoginAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

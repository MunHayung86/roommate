import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(User user, String nickname) async {
    final userDoc =
        _firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        nickname: nickname,
      );

      await userDoc.set(newUser.toMap());
    }
  }
}
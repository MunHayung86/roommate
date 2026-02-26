import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roommate/features/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

      // Always force account picker so users can switch accounts reliably.
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final String nickname =
            googleUser.displayName ?? user.displayName ?? '';
        await _authService.saveUserToFirestore(user, nickname);
      }

      if (!mounted) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final roomId = userDoc.data()?['roomId'] as String?;
      if (!mounted) return;
      if (roomId != null && roomId.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/room_select');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Text(
                '가장 편한 방법으로\n시작해요',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1E1D24),
                ),
              ),
              const SizedBox(height: 70),
              _buildButton(
                onPressed: (){},
                backgroundColor: const Color(0xffF0EFFD),
                textColor: const Color(0xff1E1D24),
                label: '휴대폰 번호로 계속하기',
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(child: Divider(color: Color(0xff191C1E), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff191C1E),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xff191C1E), thickness: 1)),
                ],
              ),
              const SizedBox(height: 35),
              _buildButton(
                onPressed: (){},
                backgroundColor: const Color(0xff06BE34),
                textColor: Colors.white,
                label: '네이버로 계속하기',
                leading: Image.asset('assets/images/Naver_logo.png', width: 30.36, height: 28.73),
              ),
              const SizedBox(height: 10),
              _buildButton(
                onPressed: (){},
                backgroundColor: const Color(0xffFCE405),
                textColor: const Color(0xff191919),
                label: '카카오로 계속하기',
                leading: Image.asset('assets/images/kko_logo.png', width: 20.31, height: 18.74),
              ),
              const SizedBox(height: 10),
              _buildButton(
                onPressed: _signInWithGoogle,
                backgroundColor: Colors.white,
                textColor: const Color(0xff1E1D24),
                label: 'Google로 계속하기',
                border: Border.all(color: Colors.grey.shade300),
                leading: Image.asset(
                  'assets/images/google_login.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (_, __, ___) => Icon(Icons.g_mobiledata, size: 24, color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 10),
              _buildButton(
                onPressed: (){},
                backgroundColor: const Color(0xff000000),
                textColor: Colors.white,
                label: 'Apple로 계속하기',
                leading: Image.asset('assets/images/apple_logo.png', width: 20, height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    required String label,
    Widget? leading,
    Border? border,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: border,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: leading != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 32),
                            child: leading,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

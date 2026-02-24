import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

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

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/room_select');
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      body: 
        Column(
          mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 700,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 330,
                  height: 60,
                  child: OutlinedButton(
                    // onPressed: _signInWithGoogle,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/room_select');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text('구글로 시작하기', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16, fontWeight: FontWeight.w500,),),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Image.asset('assets/images/google_login.png', width: 25, height: 25),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
      )
    );
  }
}
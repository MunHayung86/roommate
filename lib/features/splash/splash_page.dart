import 'dart:async';

import 'package:flutter/material.dart';

/// 앱 시작 화면. 일정 시간 후 로그인 화면으로 전환.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Duration _duration = Duration(milliseconds: 2300);

  @override
  void initState() {
    super.initState();
    Timer(_duration, _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.6, 1.0],
            colors: [
              Color.fromRGBO(108, 92, 231, 0),
              Color.fromRGBO(108, 92, 231, 0.101252),
              Color.fromRGBO(108, 92, 231, 0.4),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 28),
              Image.asset('assets/images/splash.png', width: 303),
            ],
          ),
        ),
      ),
    );
  }
}

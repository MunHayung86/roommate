import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roommate/features/auth/login_page.dart';
import 'package:roommate/features/navigation.dart';
import 'package:roommate/features/room/create_room_page.dart';
import 'package:roommate/features/room/join_room_page.dart';
import 'package:roommate/features/room/room_select_page.dart';
import 'package:roommate/features/room/share_room_code_page.dart';
import 'package:roommate/features/survey/survey_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'roommate',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const Navigation(),
        '/room_select': (context) => const RoomSelectPage(),
        '/create_room': (context) => const CreateRoomPage(),
        '/join_room': (context) => const JoinRoomPage(),
        '/share_room_code': (context) => const ShareRoomCodePage(),
        '/survey': (context) => const SurveyPage(),
      },
    );
  }
}
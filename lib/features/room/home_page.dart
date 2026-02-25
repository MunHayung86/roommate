import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roommate/features/room/room_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RoomService _roomService = RoomService();
  Future<DocumentSnapshot<Map<String, dynamic>>?>? _roomFuture;

  @override
  void initState() {
    super.initState();
    _roomFuture = _roomService.getCurrentUserRoom();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFE),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: _roomFuture,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('방 정보를 불러오지 못했어요.'),
            );
          }

          final DocumentSnapshot<Map<String, dynamic>>? roomDoc =
              snapshot.data;

          if (roomDoc == null || !roomDoc.exists) {
            return const Center(
              child: Text('아직 참여한 방이 없어요. 방을 생성하거나 참여해 주세요.'),
            );
          }

          final Map<String, dynamic>? data = roomDoc.data();
          final String roomName =
              (data?['name'] as String?) ?? '나의 방';
          final String motto =
              (data?['motto'] as String?) ?? '방 훈을 설정해 보세요.';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 70),
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 320,
                    height: 80,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 250, 235, 255),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        motto,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
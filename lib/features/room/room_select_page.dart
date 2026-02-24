import 'package:flutter/material.dart';

class RoomSelectPage extends StatefulWidget {
  const RoomSelectPage({super.key});

  @override
  State<RoomSelectPage> createState() => _RoomSelectPageState();
}

class _RoomSelectPageState extends State<RoomSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 300, width: double.infinity,),
              Text('함께 사는 공간', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Text('룸메이트와 더 나은 기숙사 생활을 시작해보세요', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 40,),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_room');
                }, 
                child: Text('새로운 방 만들기', style: TextStyle(fontSize: 16,))
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/join_room');
                }, 
                child: Text('기존 방 참여하기', style: TextStyle(fontSize: 16,))
              ),
            ],
          ),
          
        ),
      ),
    );
  }
}
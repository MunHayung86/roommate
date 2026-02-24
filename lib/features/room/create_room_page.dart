import 'package:flutter/material.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xffffffff),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),
              Text('새로운 방 만들기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              SizedBox(height: 8,),
              Text('방 정보를 입력해주세요', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 35,),
              Text('방 이름 (호수)', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 5,),
              TextField(
                decoration: InputDecoration(
                  hintText: '예: 302호',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xffdddddd)),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Text('방훈', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 5,),
              TextField(
                decoration: InputDecoration(
                  hintText: '예: 사람답게 살자',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xffdddddd)),
                  ),
                ),
              ),
              SizedBox(height: 30,),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/share_room_code');
                  }, 
                  child: Text('생성하기', style: TextStyle(fontSize: 16,))
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
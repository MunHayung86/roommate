import 'package:flutter/material.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
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
              Text('기존 방 참여하기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              SizedBox(height: 8,),
              Text('룸메이트에게 받은 코드를 입력하세요', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 35,),
              Text('방 코드', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 5,),
              TextField(
                decoration: InputDecoration(
                  hintText: '6자리 코드 입력',
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
                    Navigator.pushReplacementNamed(context, '/survey');
                  }, 
                  child: Text('참여하기', style: TextStyle(fontSize: 16,))
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}

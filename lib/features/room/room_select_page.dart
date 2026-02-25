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
              Text('함께 사는 공간,', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              Text('함께 만드는 규칙', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Text('룸메이트와 더 나은 기숙사 생활을 시작해보세요', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 43,),
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xff6C5CE7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(108, 92, 231, 0.25),
                      blurRadius: 6,
                      spreadRadius: -4,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(108, 92, 231, 0.25),
                      blurRadius: 8,
                      spreadRadius: -1,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: (){
                      Navigator.pushNamed(context, '/create_room');
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(  
                            'assets/images/new_room_icon.png',
                            width: 22,
                            height: 22,
                          ),
                          SizedBox(width: 12,),
                          Text(
                            '새로운 방 만들기',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,  
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),SizedBox(height: 16,),
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xff6C5CE7), width: 1.96),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: (){
                      Navigator.pushNamed(context, '/join_room');
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(  
                            'assets/images/join_room_icon.png',
                            width: 22,
                            height: 22,
                          ),
                          SizedBox(width: 12,),
                          Text(
                            '기존 방 참여하기',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff6C5CE7),
                              fontWeight: FontWeight.w500,  
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
        ),
      ),
    );
  }
}
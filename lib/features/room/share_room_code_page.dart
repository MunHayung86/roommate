import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareRoomCodePage extends StatefulWidget {
  final String roomCode;

  const ShareRoomCodePage({super.key, required this.roomCode});

  @override
  State<ShareRoomCodePage> createState() => _ShareRoomCodePageState();
}

class _ShareRoomCodePageState extends State<ShareRoomCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xffffffff),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 25),
              Text('방이 만들어졌어요!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
              SizedBox(height: 8,),
              Text('아래 코드를 룸메이트에게 공유하세요', style: TextStyle(fontSize: 16,),),
              SizedBox(height: 35,),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('방코드', style: TextStyle(fontSize: 14,),),
                    SizedBox(height: 10,),
                    Text(widget.roomCode, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.roomCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('코드가 복사되었습니다!')),
                      );
                    }, 
                    child: Text('코드 복사', style: TextStyle(fontSize: 16,))
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () {
                      // Share.share('같이 방 들어와요! 방 코드: ${widget.roomCode}');
                      SharePlus.instance.share(
                        ShareParams(
                          text: '같이 방 들어와요! 방 코드: ${widget.roomCode}',
                        ),
                      );
                    }, 
                    child: Text('공유하기', style: TextStyle(fontSize: 16,))
                  ),
                ],
              ),
              SizedBox(height: 40),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/survey');
                  },
                  child: Text('다음으로', style: TextStyle(fontSize: 16,))
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}

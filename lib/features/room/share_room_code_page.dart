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
  bool isCopied = false;

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    setState(() {
      isCopied = true;
    });
    // 3초 후 원래 상태로 돌아가게
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isCopied = false;
      });
    });
  }

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
              SizedBox(height: 18),
              Image.asset('assets/images/share_room_code.png', height: 48,),
              SizedBox(height: 30),
              Text('방이 만들어졌어요!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xff0a0a0a)),),
              SizedBox(height: 8,),
              Text('아래 코드를 룸메이트에게 공유하세요', style: TextStyle(fontSize: 16, color: Color(0xff717182)),),
              SizedBox(height: 32,),
              Container(
                width: 320,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('방코드', style: TextStyle(fontSize: 12, color: Color(0xff717182)),),
                    SizedBox(height: 4,),
                    Text(widget.roomCode, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xff6C5CE7),letterSpacing: 9.6),),
                  ],
                ),
              ),
              SizedBox(height: 24,),
              Row(
                children: [
                  Expanded(   
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1), width: 0.65),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _copyCode,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13.35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  isCopied
                                      ? 'assets/images/copy_check_icon.png'
                                      : 'assets/images/copy_code_icon.png',
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  isCopied ? '복사됨' : '코드 복사',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff1E1D24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Color.fromRGBO(108, 92, 231, 0.1),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: '방에 참여해 규칙을 정하세요! \n방 코드: ${widget.roomCode}',
                              subject: '방 초대 코드 공유',
                            ),
                          );
                        },
                        splashColor: Color.fromRGBO(108, 92, 231, 0.2), 
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13.35),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/share_link_icon.png', width: 18, height: 18),
                              SizedBox(width: 8),
                              Text(
                                '공유하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff6C5CE7),
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
              SizedBox(height: 40),
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:  Color(0xff6C5CE7),
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
                    onTap:(){
                      Navigator.pushReplacementNamed(context, '/survey');
                    },
                    child: Center(
                      child: Text(
                        '내 라이프스타일 설정하기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,  
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all( 
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(108, 92, 231, 0.05),
                      blurRadius: 15,
                      spreadRadius: -3,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(108, 92, 231, 0.1),
                      blurRadius: 6,
                      spreadRadius: -4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Center(
                      child: Text(
                        '이전 스타일로 시작하기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}

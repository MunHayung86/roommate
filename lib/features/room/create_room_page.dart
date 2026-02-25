import 'package:flutter/material.dart';
import 'package:roommate/features/room/room_service.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController roomMottoController = TextEditingController();
  final RoomService _roomService = RoomService();
  
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    roomNameController.addListener(_updateButtonState);
    roomMottoController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled =
          roomNameController.text.isNotEmpty && roomMottoController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    roomNameController.dispose();
    roomMottoController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Text('새로운 방 만들기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xff1E1D24)),),
              SizedBox(height: 8,),
              Text('방 정보를 입력해주세요', style: TextStyle(fontSize: 16, color: Color(0xff717182)),),
              SizedBox(height: 32,),
              Text('방 이름', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff717182)),),
              SizedBox(height: 5,),
              TextField(
                controller: roomNameController,
                decoration: InputDecoration(
                  hintText: '301호',
                  hintStyle: TextStyle(color: Color.fromRGBO(30, 29, 36, 0.5), fontSize: 16,),
                  filled: true,
                  fillColor: Color(0xffF5F5F7),
                  suffixIconColor: Color(0xffF5F5F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Text('방훈', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff717182)),),
              SizedBox(height: 5,),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: roomMottoController,
                      decoration: InputDecoration(
                        hintText: '서로 배려하며 즐겁게!',
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(30, 29, 36, 0.5),
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Color(0xffF5F5F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xffF0EFFD),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {},
                      child: Image.asset(
                        'assets/images/create_room_text_icon.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 88,),
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isButtonEnabled ? Color(0xff6C5CE7) : Color(0xffC4BEF5),
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
                    onTap: isButtonEnabled
                        ? () async {
                            final String name = roomNameController.text.trim();
                            final String motto = roomMottoController.text.trim();

                            try {
                              final String code = await _roomService.createRoom(
                                name: name,
                                motto: motto,
                              );

                              if (!mounted) return;

                              Navigator.pushNamed(
                                context,
                                '/share_room_code',
                                arguments: code,
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('방 생성에 실패했어요. 잠시 후 다시 시도해주세요.'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Center(
                      child: Text(
                        '생성하기',
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
            ],
          ),
        ),
      )
    );
  }
}
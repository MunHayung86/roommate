import 'package:flutter/material.dart';
import 'package:roommate/features/room/room_service.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController roomCodeController = TextEditingController();
  bool isButtonEnabled = false;
  String? _errorMessage;
  final RoomService _roomService = RoomService();

  @override
  void initState() {
    super.initState();
    roomCodeController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final input = roomCodeController.text.trim();
    final valid = RegExp(r'^[A-Za-z0-9]{6}$'); 
    setState(() {
      isButtonEnabled = valid.hasMatch(input);
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    roomCodeController.dispose();
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
              SizedBox(height: 25),
              Text(
                '방 코드로 참여하기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff1E1D24),
                ),
              ),
              Text(
                '룸메이트에게 받은 코드를 입력하세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff717182),
                ),
              ),
              SizedBox(height: 76),
              TextField(
                controller: roomCodeController,
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: '6자리 코드 입력',
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
              if (_errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
              ],
              SizedBox(height: 25),
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
                            final String code =
                                roomCodeController.text.trim().toUpperCase();
                            try {
                              await _roomService.joinRoomByInviteCode(code);

                              if (!mounted) return;
                              Navigator.pushReplacementNamed(context, '/home');
                            } catch (e) {
                              if (!mounted) return;
                              setState(() {
                                _errorMessage = '존재하지 않는 룸코드입니다.';
                              });
                            }
                          }
                        : null,
                    child: Center(
                      child: Text(
                        '참여하기',
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
      ),
    );
  }
}
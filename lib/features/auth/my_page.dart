import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roommate/features/room/room_service.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final RoomService _roomService = RoomService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _nickname = '';
  String _roomName = '';
  String? _photoUrl;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndRoom();
  }

  Future<void> _loadUserAndRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loaded = true);
      return;
    }
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();
    final nickname = data?['nickname'] as String? ?? user.displayName ?? '사용자';
    final roomId = data?['roomId'] as String?;
    String roomName = '';
    if (roomId != null) {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      roomName = roomDoc.data()?['name'] as String? ?? '';
    }
    if (!mounted) return;
    setState(() {
      _nickname = nickname;
      _roomName = roomName;
      _photoUrl = data?['photoUrl'] as String? ?? user.photoURL;
      _loaded = true;
    });
  }

  Future<void> _leaveRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('방 나가기'),
        content: const Text('정말 방을 나가시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('나가기', style: TextStyle(color: Color(0xffE7000B))),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _roomService.leaveRoom();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        '/room_select',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 나가기에 실패했어요. $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xffFBFBFE),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFE),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 74),
          Padding(
            padding: const EdgeInsets.fromLTRB(23.99, 0, 23.99, 0),
            child: const Text(
              '내 정보',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xff1E1D24),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(23.99, 30, 23.99, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: Color(0xffE5E7EB)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xffBFDBFE),
                                Color(0xffA5B4FC),
                                Color(0xffC4B5FD),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -1,
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _photoUrl != null && _photoUrl!.isNotEmpty
                                ? Image.network(
                                    _photoUrl!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text('😊', style: TextStyle(fontSize: 48)),
                                    ),
                                  )
                                : const Center(
                                    child: Text('😊', style: TextStyle(fontSize: 48)),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _nickname,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff0a0a0a),
                          ),
                        ),
                        Text(
                          _roomName.isEmpty ? '참여한 방 없음' : _roomName,
                          style: const TextStyle(fontSize: 16, color: Color(0xff6a7282)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _MenuButton(
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xffE5E7EB),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pushNamed(
                        '/survey',
                        arguments: true,
                      ).then((_) => _loadUserAndRoom());
                    },
                    iconPath: 'assets/images/mypage_icon_1.png',
                    label: '라이프스타일 다시 설정하기',
                    labelColor: const Color(0xff0A0A0A),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xffE5E7EB),
                    onTap: () {},
                    iconPath: 'assets/images/mypage_icon_2.png',
                    label: '알림 설정',
                    labelColor: const Color(0xff0A0A0A),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xffE5E7EB),
                    onTap: () {},
                    iconPath: 'assets/images/mypage_icon_3.png',
                    label: '개인정보 보호',
                    labelColor: const Color(0xff0A0A0A),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xffE5E7EB),
                    onTap: () {},
                    iconPath: 'assets/images/mypage_icon_4.png',
                    label: '도움말',
                    labelColor: const Color(0xff0A0A0A),
                  ),
                  const SizedBox(height: 24),
                  _MenuButton(
                    backgroundColor: const Color(0xffFEF2F2),
                    borderColor: const Color(0xffFFC9C9),
                    onTap: _leaveRoom,
                    iconPath: 'assets/images/mypage_icon_5.png',
                    label: '방 나가기',
                    labelColor: const Color(0xffE7000B),
                    centerLabel: true,
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _logout,
                        child: const Text(
                          '로그아웃',
                          style: TextStyle(
                            fontSize: 12.8,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffB0B8C1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 23),
                      Image.asset('assets/images/divider.png', width: 4, height: 24),
                      const SizedBox(width: 23),
                      const Text(
                        '회원 탈퇴',
                        style: TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffD1D5DB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    required this.iconPath,
    required this.label,
    required this.labelColor,
    this.centerLabel = false,
  });

  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;
  final String iconPath;
  final String label;
  final Color labelColor;
  final bool centerLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(width: 1.96, color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: centerLabel ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Image.asset(iconPath, width: 24, height: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
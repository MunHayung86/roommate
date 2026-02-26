import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFE),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 85),
          Padding(
            padding: const EdgeInsets.fromLTRB(23.99, 23.99, 23.99, 0),
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
                          child: const Center(
                            child: Text('😊', style: TextStyle(fontSize: 48)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '김민준',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff0a0a0a),
                          ),
                        ),
                        const Text(
                          '302호',
                          style: TextStyle(fontSize: 16, color: Color(0xff6a7282)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _MenuButton(
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xffE5E7EB),
                    onTap: () {},
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
                    onTap: () {},
                    iconPath: 'assets/images/mypage_icon_5.png',
                    label: '방 나가기',
                    labelColor: const Color(0xffE7000B),
                    centerLabel: true,
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '회원 탈퇴',
                        style: TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffB0B8C1),
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
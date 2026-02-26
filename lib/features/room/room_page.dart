import 'package:flutter/material.dart';
import 'package:roommate/features/room/roommate_lifestyle_detail_page.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  static const int _cardSize = 232;
  static const int _roommateCount = 3;

  late PageController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(
      viewportFraction: 0.65,
      initialPage: 5000,
    );
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFE),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 85),
            const Text(
              '룸메이트',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xff1E1D24),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final cardWidth = 232.0;

                  final viewportFraction = cardWidth / screenWidth;

                  return PageView.builder(
                    controller: PageController(
                      viewportFraction: viewportFraction,
                    ),
                    padEnds: false,
                    itemCount: _roommateCount,
                    itemBuilder: (context, index) {
                      final name =
                          index == 0 ? '이서연' : '룸메이트 ${index + 1}';
                      final status =
                          index == 0 ? '외출중' : null;

                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: cardWidth,
                            height: 232,
                            child: _RoommateCard(
                              name: name,
                              status: status,
                              onTap: () {
                                showLifestyleBottomSheet(context, name: name);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
              const Text(
                '📋 방 규칙',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff1E1D24),
                ),
              ),
              const SizedBox(height: 92),
              Center(
                child: Column(
                  children: [
                    const Text('😵', style: TextStyle(fontSize: 23)),
                    const SizedBox(height: 8),
                    const Text(
                      '아직 방 규칙이 없어요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff717182),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pushNamed(
                            '/survey',
                            arguments: true,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 114,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff6C5CE7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(108, 92, 231, 0.25),
                                blurRadius: 6,
                                spreadRadius: -4,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(108, 92, 231, 0.25),
                                blurRadius: 8,
                                spreadRadius: -1,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Text(
                            '방 규칙 만들기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RoommateCard extends StatelessWidget {
  const _RoommateCard({
    required this.name,
    required this.onTap,
    this.status,
  });

  final String name;
  final String? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(52),
        child: Container(
          width: 232,
          height: 232,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(52),
            border: Border.all(
              color: const Color(0xffE9ECEF),
              width: 0.65,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                          spreadRadius: -1
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                          spreadRadius: -2
                        ),
                      ],
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffBFDBFE),
                          Color(0xffA5B4FC),
                          Color(0xffC4B5FD),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '😊',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  if (status != null) ...[
                    Positioned(
                      right: -18,
                      bottom: -7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F5F7).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff717182),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 17),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff1E1D24),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text(
                '탭하여 라이프스타일 보기',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff717182),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

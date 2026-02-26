import 'package:flutter/material.dart';
import 'package:roommate/features/room/room_service.dart';
import 'package:roommate/features/room/roommate_lifestyle_detail_page.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  static const double _cardWidth = 232;

  final RoomService _roomService = RoomService();
  Future<void>? _loadFuture;
  List<Map<String, dynamic>> _members = [];
  List<dynamic> _rules = [];
  PageController? _memberPageController;
  double? _memberViewportFraction;
  int _selectedMemberIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadRoomAndMembers();
  }

  Future<void> _loadRoomAndMembers() async {
    final roomSnap = await _roomService.getCurrentUserRoom(fromServer: true);
    if (!mounted) return;
    if (roomSnap == null || !roomSnap.exists) {
      setState(() {
        _members = [];
        _rules = [];
      });
      return;
    }
    final data = roomSnap.data()!;
    _rules = (data['rules'] as List<dynamic>?) ?? [];
    final members = await _roomService.getRoomMembers(roomSnap.id);
    if (!mounted) return;
    setState(() {
      _members = members;
      if (_members.isEmpty) {
        _selectedMemberIndex = 0;
      } else if (_selectedMemberIndex >= _members.length) {
        _selectedMemberIndex = _members.length - 1;
      }
    });
  }

  PageController _getMemberPageController(double screenWidth) {
    final computedFraction = (_cardWidth / screenWidth).clamp(0.65, 1.0);
    if (_memberPageController == null ||
        _memberViewportFraction == null ||
        (_memberViewportFraction! - computedFraction).abs() > 0.001) {
      _memberPageController?.dispose();
      _memberViewportFraction = computedFraction;
      _memberPageController = PageController(
        viewportFraction: computedFraction,
        initialPage: _selectedMemberIndex,
      );
    }
    return _memberPageController!;
  }

  @override
  void dispose() {
    _memberPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBFE),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 57),
                        SizedBox(
                          height: 232,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (_members.isEmpty) {
                                return const Center(
                                  child: Text(
                                    '방에 참여한 룸메이트가 없어요',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff717182),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              final controller = _getMemberPageController(constraints.maxWidth);
                              final count = _members.length;
                              return PageView.builder(
                                controller: controller,
                                padEnds: true,
                                onPageChanged: (index) {
                                  setState(() {
                                    _selectedMemberIndex = index;
                                  });
                                },
                                itemCount: count,
                                itemBuilder: (context, index) {
                                  final m = _members[index];
                                  final name = m['nickname'] as String? ?? '알 수 없음';
                                  final photoUrl = m['photoUrl'] as String?;
                                  final uid = m['uid'] as String?;
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: SizedBox(
                                        width: _cardWidth,
                                        height: 232,
                                        child: _RoommateCard(
                                          name: name,
                                          photoUrl: photoUrl,
                                          status: '외출증',
                                          isSelected: index == _selectedMemberIndex,
                                          onTap: () {
                                            if (_selectedMemberIndex != index) {
                                              setState(() {
                                                _selectedMemberIndex = index;
                                              });
                                              controller.animateToPage(
                                                index,
                                                duration: const Duration(milliseconds: 260),
                                                curve: Curves.easeOutCubic,
                                              );
                                              return;
                                            }
                                            showLifestyleBottomSheet(
                                              context,
                                              name: name,
                                              memberUid: uid,
                                              photoUrl: photoUrl,
                                            );
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
                        const SizedBox(height: 57),
                        _buildRulesSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRulesSection() {
    if (_rules.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 방 규칙',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xff1E1D24),
            ),
          ),
          const SizedBox(height: 16),
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
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed('/survey', arguments: true)
                      .then((_) => _loadRoomAndMembers());
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 114, vertical: 16),
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
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '📋 방 규칙',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xff1E1D24),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xffECEAFC),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_rules.length}개',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6C5CE7),
                ),
              ),
            ),
            const Spacer(),
            const Text(
              '규칙 수정하기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(113, 113, 130, 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_rules.length, (index) {
          final rule = _rules[index].toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1), width: 0.65),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}.',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff6C5CE7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rule,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff1E1D24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _RoommateCard extends StatelessWidget {
  const _RoommateCard({
    required this.name,
    required this.onTap,
    required this.isSelected,
    this.photoUrl,
    this.status,
  });

  final String name;
  final String? photoUrl;
  final String? status;
  final VoidCallback onTap;
  final bool isSelected;

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
              color: isSelected ? const Color(0xff6C5CE7) : const Color(0xffE9ECEF),
              width: isSelected ? 2.0 : 0.65,
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
                    child: ClipOval(
                      child: photoUrl != null && photoUrl!.isNotEmpty
                          ? Image.network(
                              photoUrl!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text('😊', style: TextStyle(fontSize: 48)),
                              ),
                            )
                          : const Center(
                              child: Text('😊', style: TextStyle(fontSize: 48)),
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
                          color: const Color(0xffF5F5F7).withValues(alpha: 0.8),
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

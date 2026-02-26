import 'package:flutter/material.dart';
import 'package:roommate/features/room/room_service.dart';

/// 설문 응답 Map을 라이프스타일 표시용 리스트로 변환 (설문 id → emoji, label 매핑).
List<_LifestyleItem> surveyAnswersToLifestyleItems(Map<String, String> answers) {
  final List<_LifestyleItem> list = [];

  String bed = '--:--', wake = '--:--';
  final sleepVal = answers['sleep_time'];
  if (sleepVal != null && sleepVal.isNotEmpty) {
    final parts = sleepVal.split(' / ');
    for (final p in parts) {
      final t = p.trim();
      if (t.startsWith('취침')) bed = t.replaceFirst('취침', '').trim();
      if (t.startsWith('기상')) wake = t.replaceFirst('기상', '').trim();
    }
  }
  list.add(_LifestyleItem(emoji: '🌙', label: '취침 시간', value: bed));
  list.add(_LifestyleItem(emoji: '☀️', label: '기상 시간', value: wake));

  final Map<String, ({String emoji, String label})> keyToMeta = {
    'food_in_room': (emoji: '🍕', label: '음식'),
    'phone_call_in_room': (emoji: '📱', label: '통화'),
    'vacuum_frequency': (emoji: '🧹', label: '청소'),
    'ventilation_frequency': (emoji: '🌬️', label: '환기'),
    'alarm_style': (emoji: '⏰', label: '알람'),
    'keyboard_sound': (emoji: '⌨️', label: '키보드'),
    'stand_light_after_quiet': (emoji: '💡', label: '조명'),
    'return_home_style': (emoji: '🏠', label: '귀가'),
    'scent_sensitivity': (emoji: '🌸', label: '향/냄새'),
  };
  final order = [
    'food_in_room', 'phone_call_in_room', 'vacuum_frequency', 'ventilation_frequency',
    'alarm_style', 'keyboard_sound', 'stand_light_after_quiet', 'return_home_style', 'scent_sensitivity',
  ];
  for (final id in order) {
    final meta = keyToMeta[id]!;
    final value = answers[id] ?? '--';
    list.add(_LifestyleItem(emoji: meta.emoji, label: meta.label, value: value));
  }
  return list;
}

class LifestyleDetailPage extends StatelessWidget {
  const LifestyleDetailPage({
    super.key,
    required this.name,
    this.isMe = false,
  });

  final String name;
  final bool isMe;

  static const List<_LifestyleItem> defaultItems = [
    _LifestyleItem(emoji: '🌙', label: '취침 시간', value: '23:00'),
    _LifestyleItem(emoji: '☀️', label: '기상 시간', value: '07:00'),
    _LifestyleItem(emoji: '🍕', label: '음식', value: '냄새 강한 음식은 불가'),
    _LifestyleItem(emoji: '📱', label: '통화', value: '자유롭게 가능'),
    _LifestyleItem(emoji: '🧹', label: '청소', value: '격주 1회'),
    _LifestyleItem(emoji: '🌬️', label: '환기', value: '이틀에 한 번'),
    _LifestyleItem(emoji: '⏰', label: '알람', value: '여러 번 울려도 괜찮다'),
    _LifestyleItem(emoji: '⌨️', label: '키보드', value: '조용한 키보드만 가능'),
    _LifestyleItem(emoji: '💡', label: '조명', value: '사용 금지'),
    _LifestyleItem(emoji: '🏠', label: '귀가', value: '밤 10시 이전 귀가'),
    _LifestyleItem(emoji: '🌸', label: '향/냄새', value: '강한 향만 불호'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffF3F4F6),
                      border: Border.all(color: const Color(0xffE5E7EB)),
                    ),
                    child: const Center(child: Text('😊', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff0a0a0a),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '라이프스타일',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff717182),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xff374151), size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: defaultItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = defaultItems[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff6B7280),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.value,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff0a0a0a),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifestyleItem {
  const _LifestyleItem({
    required this.emoji,
    required this.label,
    required this.value,
  });
  final String emoji;
  final String label;
  final String value;
}

/// 바텀시트로 띄울 때 사용 (라운드 상단, 스크롤 가능). 배경(어두운 영역) 터치 시 닫힘.
/// [memberUid]가 있으면 해당 멤버의 설문(surveyAnswers)을 Firestore에서 불러와 표시.
void showLifestyleBottomSheet(
  BuildContext context, {
  required String name,
  String? memberUid,
  String? photoUrl,
}) {
  final roomService = RoomService();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => GestureDetector(
            onTap: () {},
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                    child: Row(
                      children: [
                        _buildSheetAvatar(photoUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff1E1D24),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '라이프스타일',
                                style: TextStyle(fontSize: 12, color: Color(0xff717182)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xff717182), size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Color.fromRGBO(0, 0, 0, 0.1), height: 0.65),
                  const SizedBox(height: 23),
                  Expanded(
                    child: FutureBuilder<Map<String, String>?>(
                      future: memberUid != null && memberUid.isNotEmpty
                          ? roomService.getMemberSurveyAnswers(memberUid)
                          : Future.value(null),
                      builder: (context, snapshot) {
                        List<_LifestyleItem> items;
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                          items = surveyAnswersToLifestyleItems(snapshot.data!);
                        } else {
                          items = LifestyleDetailPage.defaultItems;
                        }
                        if (snapshot.connectionState == ConnectionState.waiting && items == LifestyleDetailPage.defaultItems) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xffF5F5F7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.label,
                                          style: const TextStyle(fontSize: 12, color: Color(0xff717182)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.value,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff1E1D24)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSheetAvatar(String? photoUrl) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xffF3F4F6),
      border: Border.all(color: const Color(0xffE5E7EB)),
    ),
    child: ClipOval(
      child: photoUrl != null && photoUrl.isNotEmpty
          ? Image.network(
              photoUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Text('😊', style: TextStyle(fontSize: 24))),
            )
          : const Center(child: Text('😊', style: TextStyle(fontSize: 24))),
    ),
  );
}

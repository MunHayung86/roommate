import 'package:flutter/material.dart';
import 'package:roommate/features/wakeup/roommate_wakeup_item.dart';

class WakeupPage extends StatefulWidget {
  const WakeupPage({super.key});

  @override
  State<WakeupPage> createState() => _WakeupPageState();
}

class _WakeupPageState extends State<WakeupPage> {
  final List<int> _hours12 = List<int>.generate(12, (i) => i + 1); // 1..12
  final List<int> _minutes = List<int>.generate(60, (i) => i); // 0..59
  static const List<String> _ampm = ['오전', '오후'];

  int _selectedHour24 = 8; // 0-23, 8 = 8:00 AM
  int _selectedMinute = 0;
  bool _isOn = false; // alarm OFF by default per design

  final FixedExtentScrollController _hourController = FixedExtentScrollController(initialItem: 7);
  final FixedExtentScrollController _minuteController = FixedExtentScrollController(initialItem: 0);
  final FixedExtentScrollController _ampmController = FixedExtentScrollController(initialItem: 0);

  int get _hour12 => _selectedHour24 == 0 ? 12 : _selectedHour24 > 12 ? _selectedHour24 - 12 : _selectedHour24;
  int get _selectedHourIndex => _hour12 - 1;
  int get _selectedAmpmIndex => _selectedHour24 < 12 ? 0 : 1;

  /// 룸메이트 기상 현황 (목업)
  List<RoommateWakeupItem> get _roommateWakeupList => [
        const RoommateWakeupItem(
          id: '1',
          name: '이서준',
          wakeupTime: '07:00',
          isAlarmOn: true,
          isHighlighted: true,
        ),
        const RoommateWakeupItem(
          id: '2',
          name: '박지호',
          wakeupTime: '08:00',
          isAlarmOn: false,
          isHighlighted: false,
        ),
      ];

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    super.dispose();
  }

  void _onHourChanged(int index) {
    final hour12 = _hours12[index];
    setState(() {
      _selectedHour24 = _selectedHour24 < 12
          ? (hour12 == 12 ? 0 : hour12)
          : (hour12 == 12 ? 12 : hour12 + 12);
    });
  }

  void _onAmpmChanged(int index) {
    final isAm = index == 0;
    setState(() {
      _selectedHour24 = isAm ? (_hour12 == 12 ? 0 : _hour12) : (_hour12 == 12 ? 12 : _hour12 + 12);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 74, 20, 0),
            child: Text(
              '깨워줘제발 😴',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xff212529),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 29.73, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Container(
              width: double.infinity,
              height: 341.47,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffE9ECEF), width: 0.65),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 3,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 2,
                    spreadRadius: -1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: 24.65,
                    top: 24.65,
                    child: Text(
                      '나의 기상 설정',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 21 / 14,
                        letterSpacing: 0,
                        color: Color(0xff868E96),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24.65,
                    right: 24.65,
                    top: 44,
                    child: SizedBox(
                      height: 128,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 4,
                            child: ListWheelScrollView.useDelegate(
                              controller: _hourController,
                              itemExtent: 36,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: _onHourChanged,
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _hours12.length) return null;
                                  final isSelected = index == _selectedHourIndex;
                                    return Center(
                                      child: Text(
                                        '${_hours12[index]}',
                                        style: TextStyle(
                                          fontSize: isSelected ? 20 : 18,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          height: 1.0,
                                          color: isSelected ? const Color(0xff111111) : const Color(0xffE2E2E2),
                                        ),
                                      ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 0),
                          Flexible(
                            flex: 4,
                            child: ListWheelScrollView.useDelegate(
                              controller: _minuteController,
                              itemExtent: 36,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setState(() => _selectedMinute = _minutes[index]);
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _minutes.length) return null;
                                  final isSelected = index == _selectedMinute;
                                  final label = _minutes[index].toString().padLeft(2, '0');
                                    return Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: isSelected ? 20 : 18,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: isSelected ? const Color(0xff111111) : const Color(0xffE2E2E2),
                                        ),
                                      ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 0),
                          Flexible(
                            flex: 3,
                            child: ListWheelScrollView.useDelegate(
                              controller: _ampmController,
                              itemExtent: 36,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: _onAmpmChanged,
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _ampm.length) return null;
                                  final isSelected = index == _selectedAmpmIndex;
                                    return Center(
                                      child: Text(
                                        _ampm[index],
                                        style: TextStyle(
                                          fontSize: isSelected ? 16 : 14,
                                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                          color: isSelected ? const Color(0xff111111) : const Color(0xffE2E2E2),
                                        ),
                                      ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 1),
                          _buildAlarmToggleButton(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 224.35,
                    child: Center(
                      child: SizedBox(
                        width: 224.43,
                        height: 64.12,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xffE7E9F3),
                            borderRadius: BorderRadius.circular(42),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(220, 222, 236, 0.75),
                                blurRadius: 14,
                                spreadRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(32.06),
                              child: Ink(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xffFF8A85),
                                      Color(0xffFFB45B),
                                      Color(0xffF9B161),
                                      Color(0xffFFB45B),
                                      Color(0xffFF7774),
                                    ],
                                    stops: [0.0, 0.35, 0.5, 0.65, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(32.06),
                                  border: Border.all(
                                    color: Color(0xffffffff),
                                    width: 1.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(255, 255, 255, 0.9),
                                      offset: Offset(-5.4, -5.4),
                                      blurRadius: 10.7,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Color.fromRGBO(255, 255, 255, 0.75),
                                      offset: Offset(1.4, 1.4),
                                      blurRadius: 10.7,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Color.fromRGBO(224, 217, 243, 0.7),
                                      offset: Offset(2.7, 2.7),
                                      blurRadius: 21.5,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Color.fromRGBO(224, 217, 243, 0.5),
                                      offset: Offset(-10.7, -10.7),
                                      blurRadius: 21.5,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'SOS',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                      color: Color(0xFFFFFFFF),
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 298.47,
                    child: Center(
                      child: Text(
                        '긴급 요청으로 룸메에게 간절하게 부탁해요..!',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12.8,
                          fontWeight: FontWeight.w400,
                          height: 19.2 / 12.8,
                          letterSpacing: 0,
                          color: Color(0xff5C7CFA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 31),
            const Text(
              '룸메이트 현황',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff212529)),
            ),
            const SizedBox(height: 12),
            ..._roommateWakeupList.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RoommateWakeupCard(item: item),
                )),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: Color(0xffEDF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  SizedBox(width: 21.51),
                  Text('💡', style: TextStyle(fontSize: 14, color: Color(0xff212529)),),
                  SizedBox(width: 16),
                  Text('스위치가 켜진 룸메이트가 깨워달라고 해요!', style: TextStyle(fontSize: 12.8, color: Color(0xff364FC7)),),
                ],
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

  Widget _buildAlarmToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => _isOn = !_isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          color: _isOn
              ? const Color(0xffFFF4CF)
              : const Color(0xffFFFFFF),
          boxShadow: _isOn
              ? [
                  const BoxShadow(
                    color: Color.fromRGBO(255, 201, 74, 0.5),
                    blurRadius: 18,
                    spreadRadius: -4,
                    offset: Offset(4, 0),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'zZ',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: _isOn ? const Color(0xffFFAE00) : const Color(0xffA09F9A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isOn ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 6,
                fontWeight: FontWeight.w600,
                color: _isOn
                    ? const Color(0xffFFAE00)
                    : const Color(0xff717182).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 룸메이트 한 명 카드: [프로필] [이름] [아이콘] [시간]
class _RoommateWakeupCard extends StatelessWidget {
  const _RoommateWakeupCard({required this.item});

  final RoommateWakeupItem item;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = item.isHighlighted
        ? const Color(0xffFFF9DB)
        : Colors.white;
    final borderColor = item.isHighlighted
        ? const Color.fromRGBO(255, 212, 59, 0.3)
        : const Color(0xffE9ECEF);
    final timeColor = item.isAlarmOn
        ? const Color(0xff212529)
        : const Color(0xffCED4DA);

    return Container(
      width: double.infinity,
      height: 73,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff212529),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildStatusIcon(),
          const SizedBox(width: 12),
          SizedBox(width: 70),
          Text(
            item.wakeupTime,
            style: TextStyle(
              fontSize: 20,
              color: timeColor,
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (item.profileImageUrl != null && item.profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          item.profileImageUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 40,
      height: 40,
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
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: const Center(
        child: Text('😊', style: TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (item.isAlarmOn) {
      return Image.asset(
        'assets/images/clock_icon.png',
        width: 22,
        height: 22,
      );
    }
    return Image.asset(
      'assets/images/zzz_img.png',
      width: 18,
      height: 18,
    );
  }
}

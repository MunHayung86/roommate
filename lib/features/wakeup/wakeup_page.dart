import 'package:flutter/material.dart';

class WakeupPage extends StatefulWidget {
  const WakeupPage({super.key});

  @override
  State<WakeupPage> createState() => _WakeupPageState();
}

class _WakeupPageState extends State<WakeupPage> {
  final List<int> _hours = List<int>.generate(24, (i) => i);
  final List<int> _minutes = List<int>.generate(12, (i) => i * 5); // 0,5,10,...

  late int _selectedHour;
  late int _selectedMinute;
  bool _isOn = true;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = 7;
    _selectedMinute = 30;

    _hourController =
        FixedExtentScrollController(initialItem: _hours.indexOf(_selectedHour));
    _minuteController =
        FixedExtentScrollController(initialItem: _minutes.indexOf(_selectedMinute));
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final h = _selectedHour.toString().padLeft(2, '0');
    final m = _selectedMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            const Text(
              '깨워줘제발 😴',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xff212529),
              ),
            ),
            const SizedBox(height: 29.73),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24.65, 24.65, 24.65, 24),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '나의 기상 설정',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff868E96),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _hourController,
                            itemExtent: 40,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedHour = _hours[index];
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index >= _hours.length) {
                                  return null;
                                }
                                final label =
                                    _hours[index].toString().padLeft(2, '0');
                                return Center(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xffADB5BD),
                                      fontFamily: 'Consolas',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xffCED4DA),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _minuteController,
                            itemExtent: 40,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedMinute = _minutes[index];
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                if (index < 0 || index >= _minutes.length) {
                                  return null;
                                }
                                final label =
                                    _minutes[index].toString().padLeft(2, '0');
                                return Center(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xffADB5BD),
                                      fontFamily: 'Consolas',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isOn = !_isOn;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 60,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: _isOn
                                  ? const Color(0xffFFF4CF)
                                  : const Color(0xffF8F9FA),
                              boxShadow: _isOn
                                  ? [
                                      BoxShadow(
                                        color: const Color.fromARGB(133, 255, 201, 74)
                                            .withOpacity(0.6),
                                        blurRadius: 18,
                                        spreadRadius: -4,
                                        offset: const Offset(4, 0),
                                      ),
                                    ]
                                  : const [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.alarm_rounded,
                                  size: 26,
                                  color: _isOn
                                      ? const Color(0xffFFAE00)
                                      : const Color(0xffADB5BD),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _isOn ? 'ON' : 'OFF',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _isOn
                                        ? const Color(0xffFFAE00)
                                        : const Color(0xffADB5BD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                        color: Color(0xff212529),
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      '룸메이트들에게 깨워달라고 요청 중',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff4C6EF5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
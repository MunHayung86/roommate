import 'package:flutter/material.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFE),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 82, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '완료된 할 일',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff1E1D24),
                    ),
                  ),
                  const SizedBox(height: 35),
                  _DiligentCard(
                    title: '이번 주 가장 부지런한 룸메이트',
                    name: '김민수 🎉',
                  ),
                  const SizedBox(height: 31),
                  _ContributionCard(
                    rows: const [
                      _ContributionRowData(emoji: '😊', name: '김민수', count: 4, barColor: Color(0xff6C5CE7)),
                      _ContributionRowData(emoji: '😎', name: '나', count: 3, barColor: Color(0xff00B894)),
                      _ContributionRowData(emoji: '🤷', name: '이서연', count: 3, barColor: Color(0xffE17055)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '📋 완료 기록',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff717182),
                    ),
                  ),
                  const SizedBox(height: 19),
                ],
              ),
            ),
          ),
          _CompletionLogList(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _DiligentCard extends StatelessWidget {
  const _DiligentCard({
    required this.title,
    required this.name,
  });

  final String title;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xffFFF6D8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffFFD43B), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(255, 212, 59, 0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/best_icon.png', width: 40, height: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff717182),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff1E1D24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributionRowData {
  const _ContributionRowData({
    required this.emoji,
    required this.name,
    required this.count,
    required this.barColor,
  });
  final String emoji;
  final String name;
  final int count;
  final Color barColor;
}

class _ContributionCard extends StatelessWidget {
  const _ContributionCard({required this.rows});

  final List<_ContributionRowData> rows;

  static const int _maxCount = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.05), width: 0.65),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 2,
            spreadRadius: -1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '🏆 기여도',
                style: TextStyle(
                  fontSize: 13.6,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff717182),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...rows.map((r) {
            final ratio = r.count / _maxCount;
            return Padding(
              padding: EdgeInsets.only(bottom: r == rows.last ? 0 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffF3F4F6),
                      border: Border.all(color: const Color(0xffE5E7EB)),
                    ),
                    child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                r.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff1E1D24),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              '${r.count}회',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff6C5CE7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xffF0EEFC),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth * ratio;
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: w,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: r.barColor,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CompletionLogList extends StatelessWidget {
  static final List<_LogGroup> _mockLog = [
    _LogGroup(
      dateLabel: '오늘',
      tasks: [
        _LogItem(emoji: '😊', task: '환기하기', who: '김민수'),
        _LogItem(emoji: '😊', task: '방 쓸기', who: '이서연'),
      ],
    ),
    _LogGroup(
      dateLabel: '어제',
      tasks: [
        _LogItem(emoji: '🏠', task: '쓰레기통 비우기', who: '나'),
        _LogItem(emoji: '😊', task: '분리수거', who: '김민수'),
      ],
    ),
    _LogGroup(dateLabel: '2월 22일', tasks: [
      _LogItem(emoji: '🏠', task: '공용공간 정리', who: '이서연'),
    ]),
    _LogGroup(dateLabel: '2월 21일', tasks: [
      _LogItem(emoji: '😊', task: '환기하기', who: '나'),
    ]),
    _LogGroup(dateLabel: '2월 20일', tasks: [
      _LogItem(emoji: '😊', task: '방 쓸기', who: '김민수'),
    ]),
    _LogGroup(dateLabel: '2월 19일', tasks: [
      _LogItem(emoji: '🏠', task: '쓰레기통 비우기', who: '이서연'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final group = _mockLog[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    group.dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff717182),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...group.tasks.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                    child: _LogTile(emoji: t.emoji, task: t.task, who: t.who),
                  ),
                ),
              ],
            ),
          );
        },
        childCount: _mockLog.length,
      ),
    );
  }
}

class _LogGroup {
  _LogGroup({required this.dateLabel, required this.tasks});
  final String dateLabel;
  final List<_LogItem> tasks;
}

class _LogItem {
  _LogItem({required this.emoji, required this.task, required this.who});
  final String emoji;
  final String task;
  final String who;
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.emoji,
    required this.task,
    required this.who,
  });

  final String emoji;
  final String task;
  final String who;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1), width: 0.65),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffF3F4F6),
              border: Border.all(color: const Color(0xffE5E7EB)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff1E1D24),
              ),
            ),
          ),
          Text(
            who,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff717182),
            ),
          ),
        ],
      ),
    );
  }
}

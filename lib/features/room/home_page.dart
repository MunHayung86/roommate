import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roommate/features/room/room_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RoomService _roomService = RoomService();
  final TextEditingController _noteController = TextEditingController();
  final Random _random = Random();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<DocumentSnapshot<Map<String, dynamic>>?>? _roomFuture;
  Timer? _elapsedTicker;
  bool _isWriteBoxVisible = false;
  int? _expandedNoteIndex;
  String? _activeRoomId;
  final List<_HomeNote> _savedNotes = <_HomeNote>[];
  static const double _noteGap = -4;

  @override
  void initState() {
    super.initState();
    _roomFuture = _roomService.getCurrentUserRoom();
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _savedNotes.isEmpty) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _elapsedTicker?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  String _formatElapsed(DateTime createdAt) {
    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${max(1, diff.inSeconds)}초 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    return '${diff.inHours}시간 전';
  }

  Future<void> _saveNoteToRoom(String roomId, _HomeNote note) async {
    try {
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .update(<String, dynamic>{
        'homeNotes': FieldValue.arrayUnion(<Map<String, dynamic>>[note.toMap()]),
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 네트워크를 확인해 주세요.')),
      );
    }
  }

  Widget _buildProfileAvatar({
    required String? photoUrl,
    required String authorName,
    double size = 18,
  }) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(
            authorName: authorName,
            size: size,
          ),
        ),
      );
    }
    return _buildFallbackAvatar(authorName: authorName, size: size);
  }

  Widget _buildFallbackAvatar({
    required String authorName,
    required double size,
  }) {
    final String initial =
        authorName.isEmpty ? '?' : authorName.substring(0, 1).toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEAE8FF),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: size * 0.52,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6C5CE7),
        ),
      ),
    );
  }

  Offset _findNotePosition({
    required Size screenSize,
    required EdgeInsets viewPadding,
    required double noteWidth,
    required double noteHeight,
  }) {
    const double leftMargin = 16;
    const double rightMargin = 16;
    const double topBase = 260;
    const double bottomReserved = 110;
    final double minLeft = leftMargin;
    final double maxLeft = max(leftMargin, screenSize.width - rightMargin - noteWidth);
    final double minTop = max(topBase, viewPadding.top + 210);
    final double maxTop = max(
      minTop,
      screenSize.height - bottomReserved - viewPadding.bottom - noteHeight,
    );

    final Rect bounds = Rect.fromLTRB(minLeft, minTop, maxLeft, maxTop);
    final List<Rect> occupied = _savedNotes
        .map((n) => Rect.fromLTWH(n.left, n.top, n.width, n.height).inflate(_noteGap))
        .toList();

    bool isFree(Offset point) {
      final Rect rect = Rect.fromLTWH(point.dx, point.dy, noteWidth, noteHeight);
      if (rect.left < minLeft ||
          rect.right > (screenSize.width - rightMargin) ||
          rect.top < minTop ||
          rect.bottom > (screenSize.height - viewPadding.bottom - bottomReserved)) {
        return false;
      }
      for (final Rect used in occupied) {
        if (used.overlaps(rect)) return false;
      }
      return true;
    }

    Offset clampToBounds(Offset raw) {
      final double left = raw.dx.clamp(minLeft, maxLeft);
      final double top = raw.dy.clamp(minTop, maxTop);
      return Offset(left, top);
    }

    final Offset center = Offset(
      bounds.left + (bounds.width / 2),
      bounds.top + (bounds.height / 2),
    );
    final double centerJitterX = bounds.width * 0.18;
    final double centerJitterY = bounds.height * 0.18;
    final Offset centerAnchor = Offset(
      center.dx + ((_random.nextDouble() * 2) - 1) * centerJitterX,
      center.dy + ((_random.nextDouble() * 2) - 1) * centerJitterY,
    );
    final List<Offset> candidates = <Offset>[centerAnchor];

    for (int ring = 1; ring <= 8; ring++) {
      final double radius = 28.0 * ring;
      final double angleOffset = _random.nextDouble() * 2 * pi;
      for (int i = 0; i < 12; i++) {
        final double theta = angleOffset + (2 * pi * i) / 12;
        candidates.add(
          Offset(
            centerAnchor.dx + radius * cos(theta),
            centerAnchor.dy + radius * sin(theta),
          ),
        );
      }
    }

    for (int i = 0; i < 40; i++) {
      candidates.add(
        Offset(
          minLeft + _random.nextDouble() * (maxLeft - minLeft),
          minTop + _random.nextDouble() * (maxTop - minTop),
        ),
      );
    }

    final List<Offset> freeCandidates = <Offset>[];
    for (final Offset raw in candidates) {
      final Offset c = clampToBounds(raw);
      if (isFree(c)) {
        freeCandidates.add(c);
      }
    }
    if (freeCandidates.isNotEmpty) {
      // Keep notes around center area, but avoid always picking the exact first spot.
      final int pickRange = min(8, freeCandidates.length);
      return freeCandidates[_random.nextInt(pickRange)];
    }

    for (double y = minTop; y <= maxTop; y += 14) {
      for (double x = minLeft; x <= maxLeft; x += 14) {
        final Offset p = Offset(x, y);
        if (isFree(p)) return p;
      }
    }

    return Offset(minLeft, minTop);
  }

  BoxDecoration _buildGlassNoteDecoration(Color baseColor) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color.fromRGBO(255, 255, 255, 0.75),
        width: 1.1,
      ),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(108, 92, 231, 0.16),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final EdgeInsets viewPadding = MediaQuery.of(context).padding;
    final double noteMaxWidth = min(220, screenSize.width - 48);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _expandedNoteIndex = null;
              _isWriteBoxVisible = !_isWriteBoxVisible;
            });
          },
          backgroundColor: const Color(0xFFF5F5F7),
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Color(0xFF6C5CE7), size: 28),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(color: const Color(0xFFFAFAFE)),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color.fromRGBO(108, 92, 231, 0),
                    Color.fromRGBO(108, 92, 231, 0.101252),
                    Color.fromRGBO(108, 92, 231, 0.7),
                  ],
                  stops: <double>[0, 0.1446, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 45,
            top: 88,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/Frame.png',
                width: 312.010009765625,
                height: 130.6999969482422,
              ),
            ),
          ),
          Positioned.fill(
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
              future: _roomFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?>
                      snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('방 정보를 불러오지 못했어요.'),
                  );
                }

                final DocumentSnapshot<Map<String, dynamic>>? roomDoc =
                    snapshot.data;

                if (roomDoc == null || !roomDoc.exists) {
                  if (_activeRoomId != null && _savedNotes.isNotEmpty) {
                    _activeRoomId = null;
                    _savedNotes.clear();
                  }
                  return const Center(
                    child: Text('아직 참여한 방이 없어요. 방을 생성하거나 참여해 주세요.'),
                  );
                }

                final Map<String, dynamic>? data = roomDoc.data();
                final List<_HomeNote> loadedNotes =
                    _HomeNote.fromList(data?['homeNotes']);
                if (_activeRoomId != roomDoc.id) {
                  _activeRoomId = roomDoc.id;
                  _savedNotes
                    ..clear()
                    ..addAll(loadedNotes);
                  _expandedNoteIndex = null;
                } else if (_savedNotes.isEmpty && loadedNotes.isNotEmpty) {
                  _savedNotes
                    ..clear()
                    ..addAll(loadedNotes);
                }
                final String roomName = (data?['name'] as String?) ?? '나의 방';
                final String roomTitle = roomName;
                final String motto =
                    (data?['motto'] as String?) ?? '방 훈을 설정해 보세요.';

                return Stack(
                  children: <Widget>[
                    Positioned(
                      top: 110,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          roomTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 31,
                            height: 30 / 31,
                            letterSpacing: 0,
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 189.7,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: screenSize.width - 60),
                          child: Text(
                            motto,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              height: 24 / 18,
                              letterSpacing: 0,
                              color: Color(0xFF6C5CE7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ..._savedNotes.asMap().entries.map(
                      (entry) {
                        final int index = entry.key;
                        final _HomeNote note = entry.value;
                        return Positioned(
                          left: note.left,
                          top: note.top,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isWriteBoxVisible = false;
                                _expandedNoteIndex = index;
                              });
                            },
                            child: Container(
                              width: note.width,
                              height: note.height,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: _buildGlassNoteDecoration(note.color),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      _buildProfileAvatar(
                                        photoUrl: note.authorPhotoUrl,
                                        authorName: note.authorName,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          note.authorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: note.textColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatElapsed(note.createdAt),
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: note.elapsedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      note.text,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: note.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isWriteBoxVisible)
            Positioned(
              left: 51,
              top: 239,
              child: Container(
                width: 299,
                height: 398,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color.fromRGBO(255, 255, 255, 0.42),
                      Color.fromRGBO(252, 235, 255, 0.4),
                      Color.fromRGBO(252, 235, 255, 0.32),
                    ],
                  ),
                  border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 0.75),
                    width: 1.2,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color.fromRGBO(108, 92, 231, 0.16),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isWriteBoxVisible = false;
                            _expandedNoteIndex = null;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/X.png',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          final String noteText = _noteController.text.trim();
                          if (noteText.isNotEmpty) {
                            final User? currentUser =
                                FirebaseAuth.instance.currentUser;
                            final String authorName =
                                (currentUser?.displayName?.trim().isNotEmpty ?? false)
                                    ? currentUser!.displayName!.trim()
                                    : '사용자';
                            const List<_NoteStyle> noteStyles = <_NoteStyle>[
                              _NoteStyle(
                                backgroundColor: Color(0x66FCEBFF),
                                textColor: Colors.black,
                                elapsedColor: Color(0xFF7A7A7A),
                              ),
                              _NoteStyle(
                                backgroundColor: Color(0x667AA9FF),
                                textColor: Colors.white,
                                elapsedColor: Color(0xFF4564EB),
                              ),
                            ];
                            const double horizontalPadding = 28;
                            const double verticalPadding = 24;
                            const double headerHeight = 18;
                            const double headerGap = 8;
                            final TextStyle noteStyle = const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            );
                            final TextPainter widthPainter = TextPainter(
                              text: TextSpan(text: noteText, style: noteStyle),
                              textDirection: TextDirection.ltr,
                            )..layout();
                            final double noteWidth = min(
                              noteMaxWidth,
                              widthPainter.size.width + horizontalPadding,
                            );
                            final double safeNoteWidth = max(170, noteWidth);
                            final TextPainter heightPainter = TextPainter(
                              text: TextSpan(text: noteText, style: noteStyle),
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: safeNoteWidth - horizontalPadding);
                            final double noteHeight =
                                heightPainter.size.height +
                                verticalPadding +
                                headerHeight +
                                headerGap +
                                16;
                            final Offset position = _findNotePosition(
                              screenSize: screenSize,
                              viewPadding: viewPadding,
                              noteWidth: safeNoteWidth,
                              noteHeight: noteHeight,
                            );

                            final _NoteStyle selectedStyle =
                                noteStyles[_random.nextInt(noteStyles.length)];

                            final _HomeNote note = _HomeNote(
                              id: '',
                              text: noteText,
                              left: position.dx,
                              top: position.dy,
                              width: safeNoteWidth,
                              height: noteHeight,
                              color: selectedStyle.backgroundColor,
                              textColor: selectedStyle.textColor,
                              elapsedColor: selectedStyle.elapsedColor,
                              authorName: authorName,
                              authorPhotoUrl: currentUser?.photoURL,
                              createdAt: DateTime.now(),
                            );
                            _savedNotes.add(note);
                            if (_activeRoomId != null) {
                              unawaited(_saveNoteToRoom(_activeRoomId!, note));
                            }
                          }

                          FocusScope.of(context).unfocus();
                          setState(() {
                            _isWriteBoxVisible = false;
                            _expandedNoteIndex = null;
                            _noteController.clear();
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/V.png',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      top: 52,
                      child: TextField(
                        controller: _noteController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: '글을 작성해 주세요',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          color: Color(0xFF3B2F85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_expandedNoteIndex != null && _expandedNoteIndex! < _savedNotes.length)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() => _expandedNoteIndex = null);
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          if (_expandedNoteIndex != null && _expandedNoteIndex! < _savedNotes.length)
            Positioned(
              left: 51,
              top: 239,
              child: Builder(
                builder: (context) {
                  final _HomeNote note = _savedNotes[_expandedNoteIndex!];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 299,
                      height: 398,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: note.color,
                        border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 0.75),
                          width: 1.2,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color.fromRGBO(108, 92, 231, 0.16),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              _buildProfileAvatar(
                                photoUrl: note.authorPhotoUrl,
                                authorName: note.authorName,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  note.authorName,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: note.textColor,
                                  ),
                                ),
                              ),
                              Text(
                                _formatElapsed(note.createdAt),
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: note.elapsedColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                note.text,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: note.textColor,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeNote {
  const _HomeNote({
    required this.id,
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.color,
    required this.textColor,
    required this.elapsedColor,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.createdAt,
  });

  factory _HomeNote.fromMap(Map<String, dynamic> data) {
    double asDouble(dynamic value) => (value as num?)?.toDouble() ?? 0;
    int asInt(dynamic value, int fallback) => (value as int?) ?? fallback;

    final Timestamp? ts = data['createdAt'] as Timestamp?;
    return _HomeNote(
      id: (data['id'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      left: asDouble(data['left']),
      top: asDouble(data['top']),
      width: asDouble(data['width']),
      height: asDouble(data['height']),
      color: Color(asInt(data['color'], 0x66FCEBFF)),
      textColor: Color(asInt(data['textColor'], 0xFF000000)),
      elapsedColor: Color(asInt(data['elapsedColor'], 0xFF7A7A7A)),
      authorName: (data['authorName'] as String?) ?? '사용자',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      createdAt: ts?.toDate() ?? DateTime.now(),
    );
  }

  static List<_HomeNote> fromList(dynamic raw) {
    if (raw is! List) return const <_HomeNote>[];
    final List<_HomeNote> notes = raw
        .whereType<Map>()
        .map((item) => _HomeNote.fromMap(Map<String, dynamic>.from(item)))
        .toList();
    notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return notes;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'left': left,
      'top': top,
      'width': width,
      'height': height,
      'color': color.toARGB32(),
      'textColor': textColor.toARGB32(),
      'elapsedColor': elapsedColor.toARGB32(),
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  final String id;
  final String text;
  final double left;
  final double top;
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final Color elapsedColor;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime createdAt;
}

class _NoteStyle {
  const _NoteStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.elapsedColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color elapsedColor;
}

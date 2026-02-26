import 'package:flutter/material.dart';
import 'package:roommate/features/activity/activity_log_page.dart';
import 'package:roommate/features/auth/my_page.dart';
import 'package:roommate/features/room/home_page.dart';
import 'package:roommate/features/room/room_page.dart';
import 'package:roommate/features/wakeup/wakeup_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  final _navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _selectedIndex = index);
  }

  Route _onGenerateRoute(int tabIndex, RouteSettings settings) {
    late final Widget page;

    switch (tabIndex) {
      case 0: // 홈
        page = const HomePage();
        break;

      case 1: // 룸
        page = const RoomPage();
        break;

      case 2: // 활동 기록
        page = const ActivityLogPage();
        break;

      case 3: // 깨워줘
        page = const WakeupPage();
        break;

      case 4: // 마이
        page = const MyPage();
        break;

      default:
        page = const HomePage();
    }

    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) => _onGenerateRoute(index, settings),
      ),
    );
  }

  Widget _buildNavIcon(String assetPath, bool isActive) {
    const activeColor = Color(0xff6C5CE7);
    const inactiveColor = Color(0xff717182);
    return ImageIcon(
      AssetImage(assetPath),
      size: 24,
      color: isActive ? activeColor : inactiveColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final nav = _navigatorKeys[_selectedIndex].currentState;

        if (nav != null && nav.canPop()) {
          nav.pop();
          return;
        }

        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }

        Navigator.of(context).pop(); // 앱 종료
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: List.generate(5, (index) => _buildOffstageNavigator(index)),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff6C5CE7),
          unselectedItemColor: const Color(0xff717182),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon('assets/images/home.png', false),
              activeIcon: _buildNavIcon('assets/images/home.png', true),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon('assets/images/people.png', false),
              activeIcon: _buildNavIcon('assets/images/people.png', true),
              label: '룸메',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon('assets/images/clean.png', false),
              activeIcon: _buildNavIcon('assets/images/clean.png', true),
              label: '치워줘',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon('assets/images/moon.png', false),
              activeIcon: _buildNavIcon('assets/images/moon.png', true),
              label: '깨워줘',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon('assets/images/person.png', false),
              activeIcon: _buildNavIcon('assets/images/person.png', true),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}

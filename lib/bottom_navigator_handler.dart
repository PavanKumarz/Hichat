import 'package:flutter/material.dart';
import 'package:hichat/api/api.dart';
import 'package:hichat/screens/call_screen.dart';
import 'package:hichat/screens/home_screen.dart';
import 'package:hichat/screens/profile_screen.dart';

class BottomNavigatorHandler extends StatefulWidget {
  const BottomNavigatorHandler({super.key});

  @override
  State<BottomNavigatorHandler> createState() => _BottomNavigatorHandlerState();
}

class _BottomNavigatorHandlerState extends State<BottomNavigatorHandler> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Api.getSelfInfo();
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const CallScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index < _pages.length) {
            setState(() => _currentIndex = index);
          }
        },
        backgroundColor: Colors.grey[100],
        elevation: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            activeIcon: Icon(Icons.call),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

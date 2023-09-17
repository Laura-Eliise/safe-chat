import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/navigation.dart';

class BottomNavBar extends StatefulWidget {
  final int index;
  const BottomNavBar({super.key, required this.index});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  //New
  late int _selectedIndex;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        navigate(context, "/contacts");
        break;
      case 1:
        navigate(context, "/chat-page");
        break;
      case 2:
        navigate(context, "/profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.index;
    return BottomNavigationBar(
      currentIndex: _selectedIndex, //New
      type: BottomNavigationBarType.shifting,
      selectedFontSize: 20,
      selectedIconTheme: const IconThemeData(color: primeColor),
      selectedItemColor: primeColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.contacts_rounded,
            size: 28,
          ),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.chat,
            size: 28,
          ),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle, size: 28),
          label: 'Profile',
        ),
      ],
      onTap: _onItemTapped,
    );
  }
}

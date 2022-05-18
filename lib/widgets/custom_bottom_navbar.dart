import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  const CustomBottomNavbar(
      {Key? key, required this.currentIndex, required this.setIndex})
      : super(key: key);
  final int currentIndex;
  final void Function(int index) setIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "Chats",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
      currentIndex: currentIndex,
      onTap: setIndex,
      backgroundColor: Theme.of(context).backgroundColor,
      selectedItemColor: Theme.of(context).primaryColor,
    );
  }
}

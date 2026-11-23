
import 'package:flutter/material.dart';

class DiaNutraFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DiaNutraFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color diaGreen = Color(0xFF176744);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFF0F0F0),
      selectedItemColor: diaGreen,
      unselectedItemColor: Colors.black,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.ramen_dining_outlined),
          label: 'Meal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

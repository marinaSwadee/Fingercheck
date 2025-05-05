import 'package:fingerprintt/ProfilePage.dart';
import 'package:flutter/material.dart';

import 'CheckIn.dart';

class HomeWrapper extends StatefulWidget {
  final Map<String, dynamic> employee;
  final Map<String, dynamic>? attendanceToday;

  const HomeWrapper({
    required this.employee,
    this.attendanceToday,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          CheckIn(
            employee: widget.employee,
            attendanceToday: widget.attendanceToday,
          ),
          ProfilePage(),

        ],
      ),
      bottomNavigationBar: Container(
        height: 83,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(191),
          border: Border(
            top: BorderSide(
              color: Colors.black.withAlpha(77),
              width: 0.33,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              image: 'assets/images/FingerPrint.png',
              label: 'Finger Print',
              isSelected: currentIndex == 0,
              onTap: () => setState(() => currentIndex = 0),
            ),
            _NavItem(
              image: 'assets/images/User.png',
              label: 'Profile',
              isSelected: currentIndex == 1,
              onTap: () => setState(() => currentIndex = 1),
            ),
          ],
        ),
      ),
    );
  }
}
class _NavItem extends StatelessWidget {
  final String image;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.image,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            width: 24,
            height: 24,
            color: isSelected ? Color(0xFFD8A353) : Color(0xFF999999),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
              color: isSelected ? Color(0xFFD8A353) : Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

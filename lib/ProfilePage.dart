import 'package:flutter/material.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Header(),
              const SizedBox(height: 20),
              const StatBoxGrid(),
              const SizedBox(height: 20),
              const AttendanceSection(),
            ],
          ),
        ),
      ),
    );
  }
}
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFECCD), Color(0xFFFDF8F0)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hey Marina!',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Check your Attendance',
                style: TextStyle(
                  color: Color(0xFFAEAEAE),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 19,
            backgroundImage: AssetImage("assets/images/frame1.png"),
          ),
        ],
      ),
    );
  }
}
class StatBoxGrid extends StatelessWidget {
  const StatBoxGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              StatBox(count: "03", label: "Early leave", color: Color(0xFFF5E0FF), textColor: Color(0xFF7C00B5)),
              StatBox(count: "03", label: "Late In", color: Color(0xFFD0FFD7), textColor: Color(0xFF018B16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              StatBox(count: "03", label: "Annual", color: Color(0xFFFFF0C8), textColor: Color(0xFFAC7F02)),
              StatBox(count: "03", label: "Absents", color: Color(0xFFFFD2D2), textColor: Color(0xFFB70000)),
            ],
          ),
        ],
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final Color textColor;

  const StatBox({
    required this.count,
    required this.label,
    required this.color,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 81,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF353535))),
              Text(label,
                  style: TextStyle(fontSize: 16, color: textColor)),
            ],
          ),
          const Spacer(),
          Icon(Icons.info_outline, size: 24, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}
class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> weeks = ["Week 4", "Week 3", "Week 2", "Week 1"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Attendance",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF353535),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...weeks.map((week) => AttendanceCard(title: week)).toList(),
      ],
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String title;
  const AttendanceCard({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w500)),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}


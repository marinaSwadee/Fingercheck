import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> employee;

  const ProfilePage({super.key, required this.employee});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceSummary();
  }

  Future<void> fetchAttendanceSummary() async {
    final id = widget.employee["id"];
    final phone = widget.employee["phone"].toString();

    try {
      final response = await http.post(
        Uri.parse('https://romamph.com/backend/api/employee/attendance-summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "employee_id": id,
          "phone": phone,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          summary = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("❌ HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Error: $e");
    }

  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.employee['name'] ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              Header(employeeName: name),
              const SizedBox(height: 20),
            //  StatBoxGrid(stats: summary?['data']?['attendance_stats']),
              StatBoxGrid(stats: summary?['summary']),


            ],
          ),
        ),
      ),
    );
  }
}


class Header extends StatelessWidget {
  final String employeeName;

  const Header({super.key, required this.employeeName});

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
            children: [
              Text(
                'Hey ${employeeName.split(' ').first}',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Check your Attendance',
                style: TextStyle(
                  color: Color(0xFFAEAEAE),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 19,
            backgroundImage: AssetImage("assets/images/frame1.png"),
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
      padding: const EdgeInsets.all(10),
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




class StatBoxGrid extends StatelessWidget {
  final Map<String, dynamic>? stats;

  const StatBoxGrid({super.key, this.stats});

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
            children: [
              StatBox(
                count: stats?['early_departures']?.toString() ?? "0",
                label: "Early leave",
                color: const Color(0xFFF5E0FF),
                textColor: const Color(0xFF7C00B5),
              ),
              StatBox(
                count: stats?['late_arrivals']?.toString() ?? "0",
                label: "Late In",
                color: const Color(0xFFD0FFD7),
                textColor: const Color(0xFF018B16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatBox(
                count: stats?['missing_check_outs']?.toString() ?? "0",
                label: "missing finger",
                color: const Color(0xFFFFF0C8),
                textColor: const Color(0xFFAC7F02),
              ),
              StatBox(
                count: stats?['absent_days']?.toString() ?? "0",
                label: "Absents",
                color: const Color(0xFFFFD2D2),
                textColor: const Color(0xFFB70000),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatBox(
                count: stats?['remote_work_days']?.toString() ?? "0",
                label: "WFH",
                color: const Color(0xFFFFF0C8),
                textColor: const Color(0xFFAC7F02),
              ),
              StatBox(
                count: stats?['total_weekend_hours']?.toString() ?? "0",
                label: "Weekend hours",
                color: const Color(0xFFFFD2D2),
                textColor: const Color(0xFFB70000),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


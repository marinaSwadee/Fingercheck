import 'package:flutter/material.dart';

class Loginscreen extends StatefulWidget {
  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool isPhoneEntered = true; // تغييرها بناءً على الإدخال الحقيقي
  bool isInHouseSelected = false;
  bool isWorkFromHomeSelected = false;
  bool isCheckInDisabled = false;
  bool isCheckOutDisabled = false;
  String location = "لم يتم تحديد الموقع بعد";
  String attendanceStatus = "لم يتم تسجيل الحضور";

  void selectInHouse() {
    setState(() {
      isInHouseSelected = true;
      isWorkFromHomeSelected = false;
    });
  }

  void selectWorkFromHome() {
    setState(() {
      isInHouseSelected = false;
      isWorkFromHomeSelected = true;
    });
  }

  void getLocation(String type) {
    setState(() {
      if (type == "checkIn") {
        attendanceStatus = "✅ تم تسجيل الدخول";
        isCheckInDisabled = true;
      } else if (type == "checkOut") {
        attendanceStatus = "✅ تم تسجيل الخروج";
        isCheckOutDisabled = true;
      }
    });
  }

  void sendAttendanceToBackend(double lat, double long, String attendType) {
    setState(() {
      attendanceStatus = "✅ تم تسجيل $attendType بنجاح!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101317),
      appBar: AppBar(
        backgroundColor: Color(0xFF780012),
        title: Text("Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPhoneEntered) ...[
                Text(
                  "📍 اختر نوع الحضور",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),

                // أزرار تحديد نوع الحضور
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: selectInHouse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInHouseSelected ? Colors.black87 : Colors.grey,
                      ),
                      child: Text("In-Site", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: selectWorkFromHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isWorkFromHomeSelected ? Colors.black87 : Colors.grey,
                      ),
                      child: Text("Work From Home", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                if (isInHouseSelected) ...[
                  Text(
                    "📍 الموقع الحالي:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(location, style: TextStyle(color: Colors.white)),
                  SizedBox(height: 20),
                  Text(
                    attendanceStatus,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 20),

                  // زر Check-in
                  ElevatedButton(
                    onPressed: isCheckInDisabled ? null : () => getLocation("checkIn"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckInDisabled ? Colors.grey : Colors.green,
                    ),
                    child: Text(isCheckInDisabled ? '✔ Checked-in' : '✅ Check-in'),
                  ),
                  SizedBox(height: 20),

                  // زر Check-out
                  ElevatedButton(
                    onPressed: isCheckOutDisabled ? null : () => getLocation("checkOut"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckOutDisabled ? Colors.grey : Colors.red,
                    ),
                    child: Text(isCheckOutDisabled ? '✔ Checked-out' : '✅ Check-out'),
                  ),
                ],

                if (isWorkFromHomeSelected) ...[
                  Text(
                    "📍 تسجيل الحضور من المنزل",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),

                  // زر WFH
                  ElevatedButton(
                    onPressed: () => sendAttendanceToBackend(0, 0, "workFromHome"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text("Wfh"),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

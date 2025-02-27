import 'dart:convert';
import 'package:fingerprintt/CheckIn.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'LoginScreen.dart';


void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      home: AttendanceScreen(),
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String location = "لم يتم تحديد الموقع بعد";
  String attendanceStatus = "لم يتم تسجيل الحضور";
  String phoneNumber = "";
  bool isCheckInDisabled = false;
  bool isCheckOutDisabled = false;
  bool isPhoneEntered = false;
  bool isInHouseSelected = false;
  bool isWorkFromHomeSelected = false;

  TextEditingController phoneController = TextEditingController();

  final double targetLatitude = 30.063621754863313;
  final double targetLongitude = 31.343651564417925;
  final double allowedRadius = 500;

  void updatePhoneNumber(String value) {
    setState(() {
      phoneNumber = value;
      isPhoneEntered = phoneNumber.length == 11;
    });
  }

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

  Future<void> getLocation(String type) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = "❌ خدمة الموقع غير مفعلة. الرجاء تفعيلها.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          location = "❌ تم رفض إذن الوصول للموقع.";
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    double distance = Geolocator.distanceBetween(
      targetLatitude,
      targetLongitude,
      position.latitude,
      position.longitude,
    );

    setState(() {
      location = "📍 الموقع الحالي تم تحديده";
      if (distance <= allowedRadius) {
        attendanceStatus = "✅ المستخدم داخل النطاق المسموح (${distance.toStringAsFixed(2)} متر)";
        sendAttendanceToBackend(position.latitude, position.longitude, type);
      } else {
        attendanceStatus = "❌ المستخدم خارج النطاق (${distance.toStringAsFixed(2)} متر)";
      }
    });
  }

  Future<void> sendAttendanceToBackend(double lat, double long, String attendType) async {
    final String url = 'https://backend.romamph.com/api/test-attend-emp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": phoneNumber,
          'lat': lat.toString(),
          'long': long.toString(),
          "attend_check": attendType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          attendanceStatus = "✅ تم تسجيل $attendType بنجاح!";
          if (attendType == "checkIn") {
            isCheckInDisabled = true;
          } else if (attendType == "checkOut") {
            isCheckOutDisabled = true;
          }
        });
      } else {
        setState(() {
          attendanceStatus = "❌ فشل في تسجيل $attendType!";
        });
      }
    } catch (e) {
      setState(() {
        attendanceStatus = "❌ حدث خطأ أثناء تسجيل الحضور!";
      });
    }
  }

  bool isPhoneValid = false; // ✅ للتحقق من صحة الرقم

  /// **📌 التحقق من صحة الرقم المدخل**
  void validatePhoneNumber(String value) {
    setState(() {
      isPhoneValid = RegExp(r'^[0-9]{11}$').hasMatch(value); // ✅ يجب أن يكون 11 رقمًا
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Positioned.fill(
            child: Image.asset("assets/images/frame.png", fit: BoxFit.cover)

          ),

          // المحتوى
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/Vector.png"),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome Back 👋\nto ',
                          style: TextStyle(
                            color: Color(0xFF101317),
                            fontSize: 28,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w500,
                            height: 1.36,
                          ),
                        ),
                        TextSpan(
                          text: 'Roma Attendee',
                          style: TextStyle(
                            color: Color(0xFF780012),
                            fontSize: 28,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w500,
                            height: 1.36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Hello there, login to continue',
                    style: TextStyle(
                      color: Color(0xFFACAFB5),
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w300,
                      height: 1.57,
                    ),
                  ),
                  SizedBox(height: 10),



                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// **📌 حقل إدخال رقم الهاتف**
                        TextField(

                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 11, // ✅ يمنع المستخدم من إدخال أكثر من 11 رقمًا
                          decoration: InputDecoration(
                            labelText: " Enter your phone number",
                            labelStyle: TextStyle(
                              color: Color(0xFF780012),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF780012)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF780012), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          onChanged: validatePhoneNumber, // ✅ استدعاء الفحص عند تغيير الإدخال
                        ),


                        /// **📌 زر تسجيل الدخول**
                        SizedBox(

                          width: 460,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isPhoneValid
                                ? () {
                              // ✅ إذا كان الرقم صحيحًا، انتقل إلى شاشة CheckIn
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CheckIn()),
                              );
                            }
                                : null, // ✅ تعطيل الزر إذا لم يكن الرقم صحيحًا
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPhoneValid ? Color(0xFF780012) : Colors.grey, // ✅ تغيير لون الزر عند التفعيل
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // if (isPhoneEntered) ...[
                  //   Text(
                  //     "📍 اختر نوع الحضور",
                  //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  //   ),
                  //   SizedBox(height: 20),
                  //   Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       ElevatedButton(
                  //         onPressed: selectInHouse,
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: isInHouseSelected ? Colors.black87 : Colors.grey,
                  //         ),
                  //         child: Text("In-Site",style: TextStyle(fontSize: 15 ,fontWeight: FontWeight.bold),),
                  //       ),
                  //       SizedBox(width: 20),
                  //       ElevatedButton(
                  //         onPressed: selectWorkFromHome,
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: isWorkFromHomeSelected ? Colors.black87 : Colors.grey,
                  //         ),
                  //         child: Text("Work From Home",style: TextStyle(fontSize: 15 ,fontWeight: FontWeight.bold),),
                  //       ),
                  //     ],
                  //   ),
                  //   SizedBox(height: 20),
                  //
                  //   if (isInHouseSelected) ...[
                  //     Text(
                  //       "📍 الموقع الحالي:",
                  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  //     ),
                  //     Text(location, style: TextStyle(color: Colors.white)),
                  //     SizedBox(height: 20),
                  //     Text(
                  //       attendanceStatus,
                  //       style: TextStyle(fontSize: 18, color: Colors.white),
                  //     ),
                  //     SizedBox(height: 20),
                  //     ElevatedButton(
                  //       onPressed: isCheckInDisabled ? null : () => getLocation("checkIn"),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: isCheckInDisabled ? Colors.grey : Colors.green,
                  //       ),
                  //       child: Text(isCheckInDisabled ? '✔ Checked-in' : '✅ Check-in'),
                  //     ),
                  //     SizedBox(height: 20),
                  //     ElevatedButton(
                  //       onPressed: isCheckOutDisabled ? null : () => getLocation("checkOut"),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: isCheckOutDisabled ? Colors.grey : Colors.red,
                  //       ),
                  //       child: Text(isCheckOutDisabled ? '✔ Checked-out' : '✅ Check-out'),
                  //     ),
                  //   ],
                  //
                  //   if (isWorkFromHomeSelected) ...[
                  //     Text(
                  //       "📍 تسجيل الحضور من المنزل",
                  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  //     ),
                  //     SizedBox(height: 20),
                  //     ElevatedButton(
                  //       onPressed: () => sendAttendanceToBackend(0, 0, "workFromHome"),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.grey,
                  //       ),
                  //       child: Text("Wfh"),
                  //     ),
                  //   ],
                  // ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

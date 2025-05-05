import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class CheckIn extends StatefulWidget {
  final Map<String, dynamic> employee;
  final Map<String, dynamic>? attendanceToday;

  const CheckIn({
    super.key,
    required this.employee,
    this.attendanceToday,
  });

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  late Map<String, dynamic> employee;
  bool showCheckInWFH = true;
  bool showCheckOutWFH = false;
  String? selectedWorkplace;
  bool isInSiteSelected = false;
  bool isWorkFromHomeSelected = false;
  bool isCheckInDisabled = false;
  bool isCheckOutDisabled = false;
  String checkInTime = "غير متوفر";
  String workPlace = "غير متوفر";
  String location = "لم يتم تحديد الموقع بعد";
  String attendanceStatus = "لم يتم تسجيل الحضور";
  String checkType = 'غير متوفر';

  final double targetLatitude = 30.063621754863313;
  final double targetLongitude = 31.343651564417925;
  final double allowedRadius = 500;

  @override
  void initState() {
    super.initState();
    employee = widget.employee;
    final todayData = widget.attendanceToday;

    if (todayData != null) {
      final check = todayData['attend_check'];
      checkType = check ?? '';

      if (check == 'checkIn') {
        showCheckInWFH = false;
        showCheckOutWFH = true;
        attendanceStatus = "✅ تم تسجيل Check-in";
      } else if (check == 'checkOut') {
        showCheckInWFH = false;
        showCheckOutWFH = false;
        attendanceStatus = "👋 نراك غدًا!";
      }

      final createdAt = todayData['created_at'];
      if (createdAt != null) {
        final parsedUtc = DateTime.tryParse(createdAt);
        if (parsedUtc != null) {
          final parsed = parsedUtc.toLocal();
          int hour = parsed.hour;
          int minute = parsed.minute;
          String period = hour >= 12 ? "PM" : "AM";
          hour = hour % 12;
          if (hour == 0) hour = 12;
          checkInTime = "${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')} $period";
        }
      }

      workPlace = todayData['work_place'] ?? "غير متوفر";
    }

  }





  Future<void> getLocation(String type) async {
    if (selectedWorkplace == null) {
      setState(() {
        attendanceStatus = "❌ الرجاء اختيار مكان العمل أولًا!";
      });
      return;
    }

    if (selectedWorkplace == "On-Site") {
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

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          location = "❌ إعدادات الموقع مرفوضة نهائيًا. الرجاء تعديل الإعدادات.";
        });
        return;
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

      if (distance > allowedRadius) {
        setState(() {
          attendanceStatus = "❌ أنت خارج نطاق العمل (${distance.toStringAsFixed(2)} متر)";
          location = "📍 الموقع تم تحديده ولكنك خارج النطاق";
        });
        return;
      }

      setState(() {
        location = "📍 الموقع داخل النطاق (${distance.toStringAsFixed(2)} متر)";
        attendanceStatus = "✅ الموقع مؤكد. جارٍ إرسال الحضور...";
      });

      await sendAttendanceToBackend(type, selectedWorkplace!, lat: position.latitude, long: position.longitude);
    } else {
      await sendAttendanceToBackend(type, selectedWorkplace!);
    }

    setState(() {
      if (type == "checkIn") {
        isCheckInDisabled = true;
        showCheckInWFH = false;
        showCheckOutWFH = true;
      } else {
        isCheckOutDisabled = true;
        showCheckOutWFH = false;
      }
    });
  }

  Future<void> sendAttendanceToBackend(String attendType, String workPlace, {double? lat, double? long}) async {
    final String url = 'https://romamph.com/backend/api/v2-fingerPrint';
    print("🔍 Incoming to sendAttendanceToBackend()");
    print("🔍 lat: $lat, long: $long");

    DateTime now = DateTime.now();
    String formattedTime = "${now.hour}:${now.minute}:${now.second}";

    // Default coordinates
    const double officeLat = 30.063621754863313;
    const double officeLong = 31.343651564417925;
    const double homeLat = 30.0123456789;
    const double homeLong = 31.0123456789;

    double finalLat = lat ?? (workPlace == "On-Site" ? officeLat : homeLat);
    double finalLong = long ?? (workPlace == "On-Site" ? officeLong : homeLong);

    Map<String, dynamic> requestBody = {
      "phone": employee['phone'],
      "attend_check": attendType,
      "work_place": workPlace,
      "time": formattedTime,
      "lat": finalLat,
      "long": finalLong,
    };

    print("📤 Sending Attendance: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (attendType == "checkIn") {
        setState(() {
          showCheckInWFH = false;
          showCheckOutWFH = true;
        });
      } else {
        setState(() {
          showCheckOutWFH = false;
        });
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          attendanceStatus = "✅ تم تسجيل $attendType بنجاح!";
        });
        showSuccessDialog(context, "You have ${attendType == "checkIn" ? "Checked in" : "Checked out"} Successfully");
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
  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Congratulations',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF56B765),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF101317),
                ),
              ),
              const SizedBox(height: 24),

              // بصمة متحركة أو صورة
              Image.asset('assets/images/iphone.gif', height: 80),

              const SizedBox(height: 16),
              Text(
                'Stay motivated and\nhave a wonderful day!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF5D5B58)),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Thanks',
                  style: TextStyle(
                    color: Color(0xFF780012),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    DateTime now = DateTime.now();
    return "${now.day} / ${now.month} / ${now.year}";
  }

  void onWorkplaceSelected(String? newValue) {
    setState(() {
      selectedWorkplace = newValue;

      if (newValue == "Remote Work") {
        isInSiteSelected = false;
        isWorkFromHomeSelected = true;
      } else {
        isInSiteSelected = true;
        isWorkFromHomeSelected = false;
      }
    });
  }

  final List<String> workplaces = ['On-Site', 'Remote Work'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/framee.png", fit: BoxFit.cover),
            ),
            SingleChildScrollView(child:
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/images/Vector2.png"),
                  Image.asset("assets/images/Roma.png"),
                  Text('MEDIA PRODUCTION HOUSE',
                      style: TextStyle(
                        color: Color(0xFF780012),
                        fontSize: 12,
                        fontFamily: 'Aldhabi',
                        fontWeight: FontWeight.w400,
                      )),
                  SizedBox(height: 5),
                  Text('Welcome Back',
                      style: TextStyle(
                        color: Color(0xFF101317),
                        fontSize: 28,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.person, widget.employee['name'] ?? "غير متوفر"),
                      _infoRow(Icons.design_services, widget.employee['position'] ?? "غير متوفر"),
                      _infoRow(Icons.business, widget.employee['department'] ?? "غير متوفر"),
                      _infoRow(Icons.phone, widget.employee['phone'] ?? "غير متوفر"),
                      _infoRow(Icons.calendar_today, _getFormattedDate()),
                      _infoRow(Icons.check_circle, '${checkType == "checkOut" ? "Checked out" : "Checked in"} at : $checkInTime'),
                      _infoRow(Icons.location_on, 'Work $workPlace'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5,right: 5,bottom: 5),
                          child: Text('Workplace',
                              style: TextStyle(
                                color: Color(0xFF780012),
                                fontSize: 11,
                                fontFamily: 'Lexend',
                              )),
                        ),
                        Container(
                          width: 400,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: ShapeDecoration(
                            color: Color(0xFFFDF8F0),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Color(0xFF780012)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedWorkplace,
                                  isExpanded: true,
                                  hint: Text('Select work place'),
                                  icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF780012)),
                                  onChanged: onWorkplaceSelected,
                                  items: workplaces.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isInSiteSelected) ...[
                          SizedBox(height: 20),
                          if (showCheckInWFH)
                            CustomButton(
                              isDisabled: false,
                              text: 'Check-in',
                              activeColor: Color(0xFF780012),
                              onPressed: () {
                                getLocation("checkIn");
                              },
                            ),
                          if (showCheckOutWFH)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: CustomButton(
                                isDisabled: false,
                                text: 'Check-out',
                                activeColor: Color(0xFF780012),
                                onPressed: () {
                                  getLocation("checkOut");
                                },
                              ),
                            ),
                        ],
                        if (isWorkFromHomeSelected) ...[
                          SizedBox(height: 10),
                          if (showCheckInWFH)
                            CustomButton(
                              isDisabled: false,
                              text: 'Check-in',
                              activeColor: Color(0xFF780012),
                              onPressed: () {
                                sendAttendanceToBackend("checkIn", "Remote Work");
                              },
                            ),
                          if (showCheckOutWFH)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: CustomButton(
                                isDisabled: false,
                                text: 'Check-out',
                                activeColor: Color(0xFF780012),
                                onPressed: () {
                                  sendAttendanceToBackend("checkOut", "Remote Work");
                                },
                              ),
                            ),

                        ],
                        if (!showCheckInWFH && !showCheckOutWFH)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              "نراك غدًا 👋",
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF780012),
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Color(0xFF5D5B58)),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Color(0xFF5D5B58),
              fontSize: 16,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final bool isDisabled;
  final String text;
  final Color activeColor;
  final VoidCallback? onPressed;

  const CustomButton({
    Key? key,
    required this.isDisabled,
    required this.text,
    required this.activeColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: 335,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDisabled ? Color(0xFFB5B5B4) : activeColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

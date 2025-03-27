import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'frame.dart';

class CheckIn extends StatefulWidget {
  final Map<String, dynamic> data;

  const CheckIn({super.key,required this.data});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  late Map<String, dynamic> data;
  bool showCheckInWFH = true;  // ✅ يظهر `Check-in` في البداية
  bool showCheckOutWFH = false;
  String? selectedWorkplace; // متغير لتخزين القيمة المحددة
  bool isWorkplaceSelected = false; // ✅ هل تم اختيار مكان العمل؟
  bool isPhoneEntered = true; // تغييرها بناءً على الإدخال الحقيقي
  bool isInSiteSelected = false;
  bool isWorkFromHomeSelected = false;
  bool isCheckInDisabled = false;
  bool isCheckOutDisabled = false;
  String location = "لم يتم تحديد الموقع بعد";
  String attendanceStatus = "لم يتم تسجيل الحضور";
  final double targetLatitude = 30.063621754863313;
  final double targetLongitude = 31.343651564417925;
  final double allowedRadius = 500;

  void initState() {
    super.initState();
    data = widget.data ?? {}; // ✅ توفير قيمة افتراضية لمنع الأخطاء
  }

  // void selectInHouse() {
  //   setState(() {
  //     isInSiteSelected = true;
  //     isWorkFromHomeSelected = false;
  //   });
  // }
  //
  // void selectWorkFromHome() {
  //   setState(() {
  //     isInSiteSelected = false;
  //     isWorkFromHomeSelected = true;
  //   });
  // }

  Future<void> getLocation(String type) async {
    if (selectedWorkplace == null) {
      setState(() {
        attendanceStatus = "❌ الرجاء اختيار مكان العمل أولًا!";
      });
      return;
    }

    // لو On-Site، افحص اللوكيشن
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

      // ✅ داخل النطاق
      setState(() {
        location = "📍 الموقع داخل النطاق (${distance.toStringAsFixed(2)} متر)";
        attendanceStatus = "✅ الموقع مؤكد. جارٍ إرسال الحضور...";
      });

      await sendAttendanceToBackend(type, selectedWorkplace!, lat: position.latitude, long: position.longitude);
    } else {
      // لو Remote Work، نرسل بدون تحقق موقع
      await sendAttendanceToBackend(type, selectedWorkplace!,);
    }

    // ✅ تحديث الحالة بعد الإرسال
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


  Future<void> sendAttendanceToBackend(String attendType, String workPlace,
      {double? lat, double? long}) async {
    final String url = 'https://romamph.com/backend/api/v2-fingerPrint';

    DateTime now = DateTime.now();
    String formattedTime = "${now.hour}:${now.minute}:${now.second}";

    Map<String, dynamic> requestBody = {
      "phone": data['phone'],
      "attend_check": attendType,
      "work_place": workPlace,
      "time": formattedTime,
    };

    if (lat != null && long != null) {
      requestBody["lat"] = lat;
      requestBody["long"] = long;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          attendanceStatus = "✅ تم تسجيل $attendType بنجاح!";
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


  String _getFormattedDate() {
    DateTime now = DateTime.now();
    return "${now.day} / ${now.month} / ${now.year}";
  }

  void onWorkplaceSelected(String? newValue) {
    setState(() {
      selectedWorkplace = newValue;
      isWorkplaceSelected = true;

      // تحقق مما إذا كان العمل في الشركة أو من المنزل
      if (newValue == "Remote Work") {
        isInSiteSelected = false;
        isWorkFromHomeSelected = true;
      } else {
        isInSiteSelected = true;
        isWorkFromHomeSelected = false;
      }
    });
  }


  void showCheckInDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // يسمح بالإغلاق عند النقر خارج الحوار
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)), // نفس تنسيق الزاوية الدائرية
        child: Frame(),
      ),
    );
  }
  void showCheckOutDialog(BuildContext context) {
    showOkAlertDialog(
      context: context,
      title: "Welcome!",
      message: "You have successfully checked out.\nEnjoy your day!",
      okLabel: "Thanks",
     // isDestructiveAction: true,
      barrierDismissible: true,
    );
  }

  final List<String> workplaces = [
    'On-Site',
    'Remote Work',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/framee.png",
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/images/Vector2.png"),
                    Image.asset("assets/images/Roma.png"),
                    Text(
                      'MEDIA PRODUCTION HOUSE',
                      style: TextStyle(
                        color: Color(0xFF780012),
                        fontSize: 12,
                        fontFamily: 'Aldhabi',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Color(0xFF101317),
                        fontSize: 28,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                        height: 1.36,
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.person, widget.data['name'] ?? "غير متوفر"),
                        _infoRow(Icons.design_services, widget.data['position'] ?? "غير متوفر"),
                        _infoRow(Icons.business, widget.data['department'] ?? "غير متوفر"),
                        _infoRow(Icons.phone, widget.data['phone'] ?? "غير متوفر"),
                        _infoRow(Icons.calendar_today, _getFormattedDate()), // ✅ استخدام دالة التاريخ
                      ],
                    ),


                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 400,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: ShapeDecoration(
                              color: Color(0xFFFDF8F0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 1, color: Color(0xFF780012)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Workplace',
                                  style: TextStyle(
                                    color: Color(0xFF780012),
                                    fontSize: 11,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(height: 5),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedWorkplace,
                                    isExpanded: true,
                                    hint: Text(
                                      'Select work place',
                                      style: TextStyle(
                                        color: Color(0xFF101317),
                                        fontSize: 14,
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    icon: Icon(Icons.keyboard_arrow_down,
                                        color: Color(0xFF780012)),
                                    onChanged: onWorkplaceSelected,
                                    items: workplaces.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: Color(0xFF101317),
                                            fontSize: 14,
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (isInSiteSelected) ...[
                            SizedBox(height: 20),
                            CustomButton(
                              isDisabled: isCheckInDisabled,
                              text: isCheckInDisabled ? 'Checked-in' : 'Check-in',
                              activeColor: Color(0xFF780012),
                              onPressed: isCheckInDisabled
                                  ? null
                                  : () {
                                getLocation("checkIn");
                              },
                            ),

                            SizedBox(height: 20),

                            CustomButton(
                              isDisabled: isCheckOutDisabled,
                              text: isCheckOutDisabled ? 'Checked-out' : 'Check-out',
                              activeColor: Color(0xFF780012),
                              onPressed: isCheckOutDisabled
                                  ? null
                                  : () {
                                getLocation("checkOut");
                              },
                            ),

                          ],


                          if (isWorkFromHomeSelected) ...[
                            SizedBox(height: 10),
                            if (showCheckInWFH)
                              ElevatedButton(
                                onPressed: () {
                                  sendAttendanceToBackend("checkIn", "Work From Home");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF780012),
                                ),
                                child: Text("Check-in"),
                              ),

                            SizedBox(height: 20),

                            if (showCheckOutWFH)
                              ElevatedButton(
                                onPressed: () {
                                  sendAttendanceToBackend("checkOut", "Work From Home");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF780012),
                                ),
                                child: Text("Check-out"),
                              ),
                          ]



                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
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
              fontWeight: FontWeight.w400,
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

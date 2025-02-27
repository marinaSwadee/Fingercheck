import 'package:flutter/material.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  String? selectedWorkplace;// متغير لتخزين القيمة المحددة
  bool isWorkplaceSelected = false; // ✅ هل تم اختيار مكان العمل؟
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


  void onWorkplaceSelected(String? newValue) {
    setState(() {
      selectedWorkplace = newValue;
      isWorkplaceSelected = true;

      // تحقق مما إذا كان العمل في الشركة أو من المنزل
      if (newValue == "Remote Work") {
        isInHouseSelected = false;
        isWorkFromHomeSelected = true;
      } else {
        isInHouseSelected = true;
        isWorkFromHomeSelected = false;
      }
    });
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
              fit: BoxFit.cover, // يجعل الصورة تمتد بالكامل
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20), // ✅ إضافة بعض المساحة الجانبية
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // ✅ جعل جميع العناصر محاذاة لليسار
              children: [
                /// **📌 الصور والشعارات**
                Image.asset("assets/images/Vector2.png"),
                Image.asset("assets/images/Roma.png"),

                /// **📌 العنوان الفرعي**
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

                /// **📌 العنوان الرئيسي**
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

                /// **📌 معلومات المستخدم**
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // ✅ التأكد من المحاذاة لليسار
                  children: [
                    _infoRow(Icons.person, 'Ahmed Elkfrawy'),
                    _infoRow(Icons.design_services, 'UX / UI Designer'),
                    _infoRow(Icons.business, 'Software Department'),
                    _infoRow(Icons.phone, '+201093839772'),
                    _infoRow(Icons.calendar_today, '27 / 02 / 2025'),
                  ],
                ),
                SizedBox(height: 20),

                /// **📌 القائمة المنسدلة (Dropdown)**

                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 📌 **القائمة المنسدلة لاختيار مكان العمل**
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

                            /// **📌 القائمة المنسدلة**
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
                                icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF780012)),
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

                      SizedBox(height: 20),

                      /// **📌 إذا كان الحضور في الشركة**
                      if (isInHouseSelected) ...[
                        Text(
                          "📍 Current Location:",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(location, style: TextStyle(color: Colors.white)),
                        SizedBox(height: 20),

                        /// **📌 حالة الحضور**
                        Text(
                          attendanceStatus,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(height: 20),

                        /// **✅ زر Check-in**
                        ElevatedButton(
                          onPressed: isCheckInDisabled ? null : () => getLocation("checkIn"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCheckInDisabled ? Colors.grey : Colors.green,
                          ),
                          child: Text(isCheckInDisabled ? '✔ Checked-in' : '✅ Check-in'),
                        ),
                        SizedBox(height: 20),

                        /// **❌ زر Check-out**
                        ElevatedButton(
                          onPressed: isCheckOutDisabled ? null : () => getLocation("checkOut"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCheckOutDisabled ? Colors.grey : Colors.red,
                          ),
                          child: Text(isCheckOutDisabled ? '✔ Checked-out' : '✅ Check-out'),
                        ),
                      ],

                      /// **📌 إذا كان الحضور من المنزل**
                      if (isWorkFromHomeSelected) ...[
                        Text(
                          "📍 تسجيل الحضور من المنزل",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 20),

                        /// **🏠 زر WFH**
                        ElevatedButton(
                          onPressed: () => sendAttendanceToBackend(0, 0, "workFromHome"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: Text("Wfh"),
                        ),
                      ],
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

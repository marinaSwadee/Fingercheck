import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:calendar_timeline/calendar_timeline.dart';







class AttendanceTableScreen extends StatefulWidget {
  @override
  _AttendanceTableScreenState createState() => _AttendanceTableScreenState();
}

class _AttendanceTableScreenState extends State<AttendanceTableScreen> {
  List<dynamic> attendanceData = [];
  Map<String, Map<String, dynamic>> groupedAttendanceData = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }


// داخل _AttendanceTableScreenState

  /// دالة لحساب التأخير (lateness) عند checkIn
  String calculateLateness(String? checkInTimeUtc) {
    if (checkInTimeUtc == null) return '--';
    try {
      DateTime checkInTime = DateTime.parse(checkInTimeUtc).toLocal();
      // الحد الأدنى للوقت (10:15:01 صباحاً)
      DateTime threshold = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 10, 15, 1);
      if (checkInTime.isAfter(threshold)) {
        Duration diff = checkInTime.difference(threshold);
        // عرض الفرق بصيغة HH:mm:ss
        return diff.toString().split('.').first;
      }
      return '--';
    } catch (e) {
      return '--';
    }
  }

  /// دالة لتحديد إذا كان Check-out excused (أي قبل 6:00:00 مساءً)
  String checkExcused(String? checkOutTimeUtc) {
    if (checkOutTimeUtc == null) return '--';
    try {
      DateTime checkOutTime = DateTime.parse(checkOutTimeUtc).toLocal();
      // وقت 6:00:00 مساءً
      DateTime threshold = DateTime(checkOutTime.year, checkOutTime.month, checkOutTime.day, 18, 0, 0);
      if (checkOutTime.isBefore(threshold)) {
        return "Excused";
      }
      return '--';
    } catch (e) {
      return '--';
    }
  }

  /// دالة لحساب الوقت الإضافي (overtime) عند Check-out
  String calculateOvertime(String? checkOutTimeUtc) {
    if (checkOutTimeUtc == null) return '00:00:00';

    try {
      DateTime checkOutTime = DateTime.parse(checkOutTimeUtc).toLocal();

      // نجيب checkIn المقابل لنفس المستخدم
      String? checkInTimeUtc;
      for (var record in attendanceData) {
        if (record['attend_check'] == "checkIn" &&
            _getDate(record['created_at']) == _getDate(checkOutTimeUtc) &&
            record['name'] == groupedAttendanceData.entries.firstWhere((e) =>
            e.value['checkOut']?['created_at'] == checkOutTimeUtc,
                orElse: () => MapEntry('', {})).value['name']) {
          checkInTimeUtc = record['created_at'];
          break;
        }
      }

      DateTime? checkInTime = checkInTimeUtc != null ? DateTime.parse(checkInTimeUtc).toLocal() : null;

      if (selectedDate.weekday == DateTime.friday || selectedDate.weekday == DateTime.saturday) {
        if (checkInTime != null) {
          // احسب الفرق بين checkOut و checkIn
          Duration diff = checkOutTime.difference(checkInTime);
          return formatDuration(diff);
        }
      }

      // الأيام العادية - احسب الفرق بعد الساعة 6 مساءً
      DateTime threshold = DateTime(checkOutTime.year, checkOutTime.month, checkOutTime.day, 18, 0);
      Duration diff = checkOutTime.isAfter(threshold)
          ? checkOutTime.difference(threshold)
          : Duration.zero;

      return formatDuration(diff);
    } catch (e) {
      return '00:00:00';
    }
  }


  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }



  Future<void> fetchAttendanceData() async {
    final String url = 'https://backend.romamph.com/api/getAttendance';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey("data")) {
          List<dynamic> allData = jsonResponse["data"];

          // ✅ استخراج البيانات فقط لليوم المحدد
          String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);
          List<dynamic> filteredData = allData.where((record) {
            String recordDate = _getDate(record['created_at'].toString());
            return recordDate == selectedDateString;
          }).toList();

          setState(() {
            attendanceData = filteredData;
            groupedAttendanceData = _groupByUser(filteredData);
          });
        } else {
          print("❌ Error: 'data' key not found in response!");
        }
      } else {
        print("❌ Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching data: $e");
    }
  }

  /// ✅ تجميع البيانات حسب المستخدم
  Map<String, Map<String, dynamic>> _groupByUser(List<dynamic> records) {
    Map<String, Map<String, dynamic>> groupedData = {};

    for (var record in records) {
      String userKey = record['name'] + "_" + record['phone'];

      if (!groupedData.containsKey(userKey)) {
        groupedData[userKey] = {
          'name': record['name'],
          'phone': record['phone'],
          'location': "${record['lat']}, ${record['long']}",
          'checkIn': null,
          'checkOut': null,
        };
      }

      if (record['attend_check'] == "checkIn") {
        groupedData[userKey]?['checkIn'] = record;
      } else if (record['attend_check'] == "checkOut") {
        groupedData[userKey]?['checkOut'] = record;
      }
    }

    return groupedData;
  }

  /// ✅ تحويل التاريخ إلى نص بتنسيق 'yyyy-MM-dd'
  String _getDate(String utcDate) {
    try {
      DateTime dateTime = DateTime.parse(utcDate).toLocal();
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  /// ✅ دالة لتنسيق الوقت
  String formatTime(String? utcDate) {
    if (utcDate == null) return "--";
    try {
      DateTime dateTime = DateTime.parse(utcDate).toLocal();
      return DateFormat('hh:mm:ss a').format(dateTime);
    } catch (e) {
      return "--";
    }
  }

  /// ✅ دالة لمعرفة ما إذا كان Check-in متأخرًا
  bool isLateCheckIn(String? utcDate) {
    if (utcDate == null) return false;
    try {
      DateTime checkInTime = DateTime.parse(utcDate).toLocal();
      DateTime lateTime = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 10, 15, 1);
      return checkInTime.isAfter(lateTime);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Records')),
      body: Column(
        children: [
          // ✅ التقويم لاختيار اليوم
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CalendarTimeline(
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now().add(Duration(days: 365)),
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
                fetchAttendanceData(); // ✅ تحميل البيانات بعد تغيير التاريخ
              },
              leftMargin: 20,
              monthColor: Colors.black,
              dayColor: Colors.black,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.grey,
              dotsColor: Colors.white,
              selectableDayPredicate: (date) => true,
            ),
          ),

          SizedBox(height: 10),

          // ✅ التمرير العمودي للجدول
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTableSection("Attendance"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ دالة لإنشاء قسم الجدول
  Widget _buildTableSection(String title) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        _buildScrollableTable(),
      ],
    );
  }

  /// ✅ دالة لإنشاء الجدول
  // داخل الدالة التي تبني جدول البيانات
  Widget _buildScrollableTable() {
    if (groupedAttendanceData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("No records available", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      );
    }

    // تحديد ما إذا كان يجب إخفاء أعمدة Lateness و Excused
    bool hideLateAndExcused = (selectedDate.weekday == DateTime.friday || selectedDate.weekday == DateTime.saturday);

    // بناء قائمة الأعمدة
    List<DataColumn> columns = [
      DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Check-in Time', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Check-out Time', style: TextStyle(fontWeight: FontWeight.bold))),
    ];

    if (!hideLateAndExcused) {
      columns.add(DataColumn(label: Text('Excused', style: TextStyle(fontWeight: FontWeight.bold))));
      columns.add(DataColumn(label: Text('Lateness', style: TextStyle(fontWeight: FontWeight.bold))));
    }

    columns.add(DataColumn(label: Text('Overtime', style: TextStyle(fontWeight: FontWeight.bold))));

    // بناء الصفوف
    List<DataRow> rows = groupedAttendanceData.entries.map((entry) {
      bool isLate = entry.value['checkIn'] != null
          ? isLateCheckIn(entry.value['checkIn']['created_at'].toString())
          : false;

      List<DataCell> cells = [
        DataCell(Text(entry.value['name'].toString())),
        DataCell(Text(entry.value['phone'].toString())),
        DataCell(Text(entry.value['location'].toString())),
        DataCell(
          Text(
            formatTime(entry.value['checkIn']?['created_at']),

          ),
        ),
        DataCell(Text(formatTime(entry.value['checkOut']?['created_at']))),
      ];

      if (!hideLateAndExcused) {
        // عمود Excused: إذا كان Check-out قبل 6:00:00 مساءً
        cells.add(DataCell(Text(checkExcused(entry.value['checkOut']?['created_at']))));
        // عمود Lateness: حساب التأخير إذا Check-in بعد 10:15:01
        cells.add(DataCell(Text(calculateLateness(entry.value['checkIn']?['created_at']),style: TextStyle(
          color: isLate ? Colors.red : Colors.black,
          fontWeight: isLate ? FontWeight.bold : FontWeight.normal,
        ),)));
      }

      // عمود Overtime: حساب الوقت الإضافي
      cells.add(DataCell(Text(calculateOvertime(entry.value['checkOut']?['created_at']))));

      return DataRow(cells: cells);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(color: Colors.grey.shade300),
        columns: columns,
        rows: rows,
      ),
    );
  }

}

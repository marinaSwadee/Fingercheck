// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   // دالة إرسال البيانات إلى الـ API
//   Future<void> login() async {
//     if (_formKey.currentState!.validate()) {
//       String name = nameController.text; // الحصول على الاسم
//       String phone = phoneController.text; // الحصول على رقم الهاتف
//
//       // رابط الـ API
//       final String url = 'https://backend.romamph.com/api/register';
//
//       try {
//         final response = await http.post(
//           Uri.parse(url), // الرابط
//           headers: {
//             'Content-Type': 'application/json', // نوع البيانات المُرسلة
//           },
//           body: jsonEncode({
//             'name': name, // الاسم
//             'phone': phone, // رقم الهاتف
//           }),
//         );
//
//         // التحقق من استجابة الخادم
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           var responseData = jsonDecode(response.body); // قراءة الرد
//           print("Response from server: $responseData");
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Registration successful!")),
//           );
//
//           // الانتقال إلى صفحة الحضور
//           Navigator.pushReplacementNamed(context, '/attendance');
//         } else {
//           print("Error: ${response.statusCode}");
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to register. Please try again.")),
//           );
//         }
//       } catch (e) {
//         print("Error: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("An error occurred. Please try again. $e")),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // إدخال الاسم
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//
//               // إدخال رقم الهاتف
//               TextFormField(
//                 controller: phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                     return 'Phone number must contain only numbers';
//                   } else if (value.length < 10) {
//                     return 'Phone number must be at least 10 digits';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//
//               // زر تسجيل الدخول
//               ElevatedButton(onPressed: login, child: Text('Register')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

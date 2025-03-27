import 'package:flutter/material.dart';

class Frame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 343,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFFDF8F0),
            borderRadius: BorderRadius.circular(21),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎉 عنوان النجاح
              Text(
                'Congratulations',
                style: TextStyle(
                  color: Color(0xFF56B765),
                  fontSize: 24,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              // ✔️ رسالة تأكيد تسجيل الخروج
              Text(
                'You have checked out successfully.',
                style: TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // 🖼️ صورة نجاح العملية
              Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover, image: AssetImage("assets/images/iphone.gif"),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // ✨ رسالة وداع
              Text(
                'We wish you a happy evening and a safe journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5D5B58),
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 16),

              // 🔘 زر الإغلاق (Thanks)
              GestureDetector(
                onTap: () => Navigator.of(context).pop(), // إغلاق الحوار عند الضغط
                child: Text(
                  'Thanks',
                  style: TextStyle(
                    color: Color(0xFF780012),
                    fontSize: 16,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

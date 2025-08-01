import 'package:flutter/material.dart';
import 'package:itm_connect/features/landing/landing_screen.dart';
import 'package:itm_connect/features/user/home/user_home_screen.dart';
import 'package:itm_connect/features/user/class_routine/class_routine_screen.dart';
import 'package:itm_connect/features/user/teacher/list/teacher_list_screen.dart';
import 'package:itm_connect/features/user/notice/notice_board_screen.dart';
import 'package:itm_connect/features/user/contact/contact_us_screen.dart';
import 'package:itm_connect/features/user/feedback/feedback_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITM Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const LandingScreen(),
      routes: {
        '/home': (context) => const UserHomeScreen(),
        '/class-routine': (context) => const ClassRoutineScreen(),
        '/teachers': (context) => const TeacherListScreen(),
        '/notices': (context) => const NoticeBoardScreen(),
        '/contact': (context) => const ContactUsScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },
    );
  }
}

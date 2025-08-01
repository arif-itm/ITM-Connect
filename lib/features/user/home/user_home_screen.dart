import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:itm_connect/widgets/app_layout.dart';
import 'package:itm_connect/features/user/class_routine/class_routine_screen.dart';
import 'package:itm_connect/features/user/contact/contact_us_screen.dart';
import 'package:itm_connect/features/user/feedback/feedback_screen.dart';
import 'package:itm_connect/features/user/notice/notice_board_screen.dart';
import 'package:itm_connect/features/user/teacher/list/teacher_list_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = -1;

  final List<Widget> _pages = [
    const TeacherListScreen(),
    const NoticeBoardScreen(),
    const ClassRoutineScreen(),
    const ContactUsScreen(),
    const FeedbackScreen(),
  ];

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showAppBar: true,
      showBottomNavBar: true,
      currentIndex: _currentIndex,
      onBottomNavTap: _handleBottomNavTap,
      body: _currentIndex == -1
          ? const ITMDepartmentHomeBody()
          : _pages[_currentIndex],
    );
  }
}

class ITMDepartmentHomeBody extends StatelessWidget {
  const ITMDepartmentHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to ITM Department",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Where innovation meets education.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            // About the Department
            GlassCard(
              title: "About the Department",
              description:
              "The ITM Department focuses on integrating IT with business practices. Our students are trained in technology, leadership, and ethical innovation. Our curriculum is carefully designed to keep pace with the global tech industry.",
              icon: Icons.info_outline,
              color: Colors.teal,
              height: 240,
            ),
            const SizedBox(height: 20),

            // Our Mission
            GlassCard(
              title: "Our Mission",
              description:
              "To empower students with the technical and managerial skills needed to succeed in a fast-paced digital world. We aim to cultivate innovation, integrity, and inclusivity in every student.",
              icon: Icons.flag_outlined,
              color: Colors.deepOrange,
              height: 220,
            ),
            const SizedBox(height: 30),

            // Highlights Section
            Text(
              "Department Highlights",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.70,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                InfoHighlightCard(
                  icon: Icons.lightbulb_outline,
                  title: "Innovation",
                  description: "Encouraging creative tech solutions.",
                  color: Colors.amber,
                  height: 160,
                ),
                InfoHighlightCard(
                  icon: Icons.school_outlined,
                  title: "Career Focus",
                  description:
                  "Curriculum aligned with industry jobs to prepare graduates for tech leadership roles.",
                  color: Colors.blueAccent,
                  height: 200,
                ),
                InfoHighlightCard(
                  icon: Icons.public_outlined,
                  title: "Global Vision",
                  description:
                  "Students gain exposure to international tech trends and global industry standards.",
                  color: Colors.deepPurple,
                  height: 200,
                ),
                InfoHighlightCard(
                  icon: Icons.security_outlined,
                  title: "Cyber Awareness",
                  description:
                  "Educating on digital safety and ethical cybersecurity practices.",
                  color: Colors.redAccent,
                  height: 160,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Full Width Cards
            GlassCardFullWidth(
              title: "Why Choose Us?",
              description:
              "✔ Experienced Faculty\n✔ Modern Labs\n✔ Career Guidance\n✔ Internship Opportunities\n✔ Alumni Support",
              icon: Icons.star_rate,
              color: Colors.green,
              height: 220,
            ),
            const SizedBox(height: 20),

            GlassCardFullWidth(
              title: "Student Opportunities",
              description:
              "💡 Hackathons\n🌐 Tech Seminars\n📊 Research Projects\n🌍 International Exposure\n🏆 Merit Scholarships",
              icon: Icons.emoji_objects_outlined,
              color: Colors.purple,
              height: 240,
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double height;

  const GlassCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[900],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 14.5, color: Colors.grey[800]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassCardFullWidth extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double height;

  const GlassCardFullWidth({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: title,
      description: description,
      icon: icon,
      color: color,
      height: height,
    );
  }
}

class InfoHighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final double height;

  const InfoHighlightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({super.key});

  // 🔧 Dummy notices (replace with Firebase later)
  List<Map<String, String>> getDummyNotices() {
    return [
      {
        'title': 'Orientation Program',
        'description':
        'Join us for the orientation of the new semester on Monday at 10 AM in Auditorium.',
        'date': '2025-07-01',
      },
      {
        'title': 'Exam Schedule Published',
        'description':
        'Final exam schedule is published. Check your batch-wise routine.',
        'date': '2025-07-05',
      },
      {
        'title': 'Holiday Notice',
        'description': 'University will remain closed on July 10th for Eid-ul-Adha.',
        'date': '2025-07-03',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notices = getDummyNotices();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // ✅ Matches header
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.announcement, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notice['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notice['description']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '📅 ${notice['date']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fade(duration: 400.ms)
                .slide(begin: const Offset(0, 0.1), duration: 400.ms);
          },
        ),
      ),
    );
  }
}

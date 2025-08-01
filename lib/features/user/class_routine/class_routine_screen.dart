import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  int? selectedBatch;
  String? selectedDay;

  final List<String> days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  // Added demo routine data here
  final Map<String, List<Map<String, String>>> routineData = {
    // Batch 6 routine
    '6_Sat': [
      {
        'time': '11:30 AM - 1:00 PM',
        'courseName': 'ITM 418',
        'courseId': '',
        'teacher': 'MA',
        'room': '609',
      },
      {
        'time': '1:00 PM - 2:30 PM',
        'courseName': 'ITM 314',
        'courseId': '',
        'teacher': 'FM',
        'room': '609',
      },
      {
        'time': '2:30 PM - 4:00 PM',
        'courseName': 'ITM 304',
        'courseId': '',
        'teacher': 'AHN',
        'room': '602',
      },
    ],
    '6_Mon': [
      {
        'time': '10:30 AM - 11:30 PM',
        'courseName': 'ITM 401',
        'courseId': '',
        'teacher': 'NJ',
        'room': '602',
      },
      {
        'time': '1:00 PM - 2:30 PM',
        'courseName': 'ITM 313',
        'courseId': '',
        'teacher': 'FM',
        'room': '609',
      },
      {
        'time': '2:30 PM - 4:00 PM',
        'courseName': 'ITM 304',
        'courseId': '',
        'teacher': 'AHN',
        'room': '602',
      },
    ],
    '6_Tue': [
      {
        'time': '8:30 AM - 10:00 AM',
        'courseName': 'ITM 418',
        'courseId': '',
        'teacher': 'MA',
        'room': '603',
      },
      {
        'time': '10:00 AM - 11:30 AM',
        'courseName': 'ITM 401',
        'courseId': '',
        'teacher': 'NJ',
        'room': '602',
      },
      {
        'time': '11:30 AM - 1:00 PM',
        'courseName': 'ITM 313',
        'courseId': '',
        'teacher': 'AHN',
        'room': '602',
      },
    ],

    // Batch 7 routine
    '7_Sat': [
      {
        'time': '10:00 AM - 11:30 AM',
        'courseName': 'ITM 321',
        'courseId': '',
        'teacher': '',
        'room': '609',
      },
      {
        'time': '11:30 AM - 1:00 PM',
        'courseName': 'ITM 321',
        'courseId': '',
        'teacher': '',
        'room': '603',
      },
      {
        'time': '2:30 PM - 4:00 PM',
        'courseName': 'ITM 304',
        'courseId': '',
        'teacher': '',
        'room': '602',
      },
    ],
    '7_Sun': [
      {
        'time': '10:00 AM - 11:30 AM',
        'courseName': 'ITM 306',
        'courseId': '',
        'teacher': '',
        'room': '602',
      },
      {
        'time': '1:00 PM - 2:30 PM',
        'courseName': 'ITM 323',
        'courseId': '',
        'teacher': '',
        'room': '609',
      },
      {
        'time': '2:30 PM - 4:00 PM',
        'courseName': 'ITM 324',
        'courseId': '',
        'teacher': '',
        'room': '609',
      },
    ],
    '7_Mon': [
      {
        'time': '8:30 AM - 9:50 AM',
        'courseName': 'ITM 306',
        'courseId': '',
        'teacher': '',
        'room': '602',
      },
      {
        'time': '1:00 PM - 2:30 PM',
        'courseName': 'ITM 323',
        'courseId': '',
        'teacher': '',
        'room': '603',
      },
      {
        'time': '2:30 PM - 4:00 PM',
        'courseName': 'ITM 304',
        'courseId': '',
        'teacher': '',
        'room': '602',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    final today = DateFormat('EEE').format(DateTime.now());
    if (days.contains(today)) {
      selectedDay = today;
    } else {
      selectedDay = days.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineKey = selectedBatch != null && selectedDay != null
        ? '${selectedBatch}_$selectedDay'
        : null;
    final routines = routineKey != null ? routineData[routineKey] : null;

    return Container(
      color: const Color(0xFFF5F5F5), // Background color #f5f5f5
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Batch Input
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Batch Number',
                    prefixIcon: Icon(Icons.group),
                  ),
                  onChanged: (value) {
                    final batch = int.tryParse(value);
                    if (batch != null && batch > 0) {
                      setState(() => selectedBatch = batch);
                    }
                  },
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Day Selector
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isSelected = selectedDay == day;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = day),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.shade500 : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().slideX(begin: 1).fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            if (selectedBatch == null || selectedDay == null)
              const Text(
                'Please enter batch and select day.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ).animate().fadeIn(),

            if (selectedBatch != null &&
                selectedDay != null &&
                (routines == null || routines.isEmpty))
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 400)),
                  SlideEffect(begin: Offset(0, 0.1))
                ],
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange, size: 28),
                            SizedBox(width: 10),
                            Text(
                              'No Classes Today',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Class Time: 8:30 AM – 4:00 PM',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Each class duration: 1 hour 30 minutes.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (routines != null && routines.isNotEmpty)
              ...routines.mapIndexed((index, routine) {
                return Animate(
                  effects: [
                    FadeEffect(duration: 300.ms, delay: (index * 100).ms),
                    SlideEffect(begin: const Offset(0, 0.2), duration: 300.ms),
                  ],
                  child: GlassCard(
                    courseName: routine['courseName']!,
                    courseId: routine['courseId']!,
                    time: routine['time']!,
                    teacher: routine['teacher']!,
                    room: routine['room']!,
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final String courseName;
  final String courseId;
  final String time;
  final String teacher;
  final String room;

  const GlassCard({
    super.key,
    required this.courseName,
    required this.courseId,
    required this.time,
    required this.teacher,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$courseName${courseId.isNotEmpty ? ' ($courseId)' : ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Text(time),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 6),
                Text(teacher.isNotEmpty ? teacher : '-'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.meeting_room, size: 18),
                const SizedBox(width: 6),
                Text('Room: $room'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

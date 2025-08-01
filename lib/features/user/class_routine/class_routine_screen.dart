import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassRoutineScreen extends StatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  State<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends State<ClassRoutineScreen> {
  int? selectedBatch;
  String? selectedDay;

  final List<String> days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  // Removed all hard-coded routineData. Data now comes from Firestore.

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

  String _fullDay(String shortDay) {
    switch (shortDay) {
      case 'Sat':
        return 'Saturday';
      case 'Sun':
        return 'Sunday';
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      default:
        return shortDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    // No local routines map anymore; will render from Firestore below.
    final hasSelection = selectedBatch != null && selectedDay != null;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.shade500
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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

            if (hasSelection)
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                // Avoid composite index by removing orderBy and sorting client-side
                future: FirebaseFirestore.instance
                    .collection('routines')
                    .where('batch', isEqualTo: '${selectedBatch}')
                    .where('day', isEqualTo: _fullDay(selectedDay!))
                    .get(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Failed to load routine: ${snap.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  final docs = snap.data?.docs ?? [];

                  // Sort client-side by time (string). Adjust parsing if you change schema to Timestamp.
                  docs.sort((a, b) {
                    final ta = (a.data()['time'] ?? '') as String;
                    final tb = (b.data()['time'] ?? '') as String;
                    return ta.compareTo(tb);
                  });

                  if (docs.isEmpty) {
                    return Animate(
                      effects: const [
                        FadeEffect(duration: Duration(milliseconds: 400)),
                        SlideEffect(begin: Offset(0, 0.1))
                      ],
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
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
                                  Icon(Icons.info_outline,
                                      color: Colors.orange, size: 28),
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
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Each class duration: 1 hour 30 minutes.',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: docs.mapIndexed((index, doc) {
                      final r = doc.data();
                      final time = (r['time'] ?? '') as String;
                      final courseName = (r['courseName'] ?? '') as String;
                      final courseId = (r['courseCode'] ?? '') as String;
                      final teacher = (r['teacherInitial'] ?? '') as String;
                      final room = (r['room'] ?? '') as String;

                      return Animate(
                        effects: [
                          FadeEffect(duration: 300.ms, delay: (index * 100).ms),
                          const SlideEffect(
                              begin: Offset(0, 0.2),
                              duration: Duration(milliseconds: 300)),
                        ],
                        child: GlassCard(
                          courseName: courseName,
                          courseId: courseId,
                          time: time,
                          teacher: teacher,
                          room: room,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

            // Removed rendering from local routines map (no longer exists).
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

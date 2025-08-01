import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itm_connect/widgets/universal_header.dart';

class RoutineScreen extends StatefulWidget {
  final String teacherName;
  const RoutineScreen({super.key, required this.teacherName});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  String selectedDay = 'Monday';

  // Removed dummyRoutine; wire up to real data source when available.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Column(
        children: [
          // ✅ App header
          UniversalHeader(
              title: '${widget.teacherName}\'s Routine', showBackButton: true),

          // ✅ Day Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: buildDaySelector(),
          ),

          // ✅ Routine List (Firestore)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('routines')
                    .where('teacher', isEqualTo: widget.teacherName)
                    .where('day', isEqualTo: selectedDay)
                    .orderBy('time')
                    .get(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Failed to load routine: ${snap.error}',
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return buildEmptyState();
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final r = docs[index].data();
                      final time = (r['time'] ?? '') as String;
                      final courseName = (r['courseName'] ?? '') as String;
                      final code = (r['courseCode'] ?? '') as String;
                      final room = (r['room'] ?? '') as String;
                      final batch = (r['batch'] ?? '') as String;

                      return Animate(
                        effects: const [
                          FadeEffect(),
                          SlideEffect(begin: Offset(0, 0.05))
                        ],
                        delay: (index * 100).ms,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: const CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.green,
                              child: Icon(Iconsax.clock,
                                  color: Colors.white, size: 20),
                            ),
                            title: Text(
                              '$time • $courseName ($code)',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text('Room: $room  |  Batch: $batch'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDaySelector() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = selectedDay == day;

          return GestureDetector(
            onTap: () => setState(() => selectedDay = day),
            child: Animate(
              effects: const [FadeEffect(), ScaleEffect()],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.green.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  day.substring(0, 3), // "Mon", "Tue"...
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return Animate(
      effects: const [FadeEffect(), SlideEffect(begin: Offset(0, 0.1))],
      child: Center(
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.warning_2, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No routine available for this day.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check back later or choose another day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

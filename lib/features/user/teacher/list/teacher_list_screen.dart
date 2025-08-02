import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itm_connect/widgets/app_layout.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  // Firestore-backed teachers
  List<Map<String, String>> teachers = [];

  int? expandedIndex;
  int? showRoutineIndex;
  String selectedDay = 'Monday';

  // Loading & error states
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final formattedDay = DateFormat('EEEE').format(now); // EEEE = full day name
    const validDays = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday'
    ];
    selectedDay = validDays.contains(formattedDay) ? formattedDay : 'Monday';
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final qs = await FirebaseFirestore.instance
          .collection('teachers')
          .orderBy('name')
          .get();

      teachers = qs.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'name': (data['name'] ?? '') as String,
          'position': (data['role'] ?? '') as String,
          'email': (data['email'] ?? '') as String,
          'image': (data['photoUrl'] ?? '') as String,
          'initials': (data['initial'] ?? '') as String,
        };
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showAppBar: false,
      showBottomNavBar: false,
      onBottomNavTap: (_) {},
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF5F5F5),
            child: Column(
              children: [
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                      color: Colors.redAccent, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : teachers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No Teachers Available',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black54),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: teachers.length,
                                  itemBuilder: (context, index) {
                                    final teacher = teachers[index];
                                    final isExpanded = expandedIndex == index;
                                    final routineVisible =
                                        showRoutineIndex == index;

                                    return Animate(
                                      effects: [
                                        FadeEffect(
                                            duration: 400.ms,
                                            delay: (index * 100).ms),
                                        const SlideEffect(
                                            begin: Offset(0, 0.2),
                                            duration:
                                                Duration(milliseconds: 400)),
                                      ],
                                      child: GestureDetector(
                                        onTap: () {
                                          if (!routineVisible) {
                                            setState(() {
                                              expandedIndex =
                                                  isExpanded ? null : index;
                                              showRoutineIndex = null;
                                            });
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              isExpanded
                                                  ? _buildExpandedContent(
                                                      teacher,
                                                      index,
                                                      routineVisible)
                                                  : _buildCollapsedContent(
                                                      teacher),
                                              if (routineVisible) ...[
                                                const SizedBox(height: 20),
                                                _buildDaySelector(),
                                                const SizedBox(height: 16),
                                                // Load routine from Firestore without requiring a composite index.
                                                _buildRoutineList(
                                                    teacher['name'] ?? ''),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
          if (expandedIndex != null)
            Positioned(
              bottom: 24,
              right: 24,
              child: SizedBox(
                height: 36,
                width: 36,
                child: FloatingActionButton(
                  heroTag: 'backBtn',
                  backgroundColor: Colors.green,
                  mini: true,
                  onPressed: () {
                    setState(() {
                      expandedIndex = null;
                      showRoutineIndex = null;
                    });
                  },
                  child: const Icon(Icons.arrow_back,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollapsedContent(Map<String, String> teacher) {
    return Row(
      children: [
        _buildTeacherImage(teacher),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(teacher['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(teacher['position'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      ],
    );
  }

  Widget _buildExpandedContent(
      Map<String, String> teacher, int index, bool routineVisible) {
    return Column(
      children: [
        _buildTeacherImage(teacher, size: 120),
        const SizedBox(height: 16),
        Text(teacher['name'] ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(teacher['position'] ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 10),
        Text(teacher['email'] ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            setState(() {
              showRoutineIndex = routineVisible ? null : index;
            });
          },
          icon: Icon(routineVisible ? Icons.close : Icons.schedule,
              color: Colors.white),
          label: Text(
            routineVisible ? 'Hide Routine' : 'Routine',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherImage(Map<String, String> teacher, {double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.green.shade700, width: size == 60 ? 2 : 3),
      ),
      child: ClipOval(
        child: Image.network(
          teacher['image'] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person, color: Colors.grey, size: size / 2),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday'
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.green.shade700 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                day.substring(0, 3),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutineList(String teacherName) {
    // routines collection: fields include {teacher, day, time, courseName, courseCode, room, batch, teacherInitial}
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('routines')
          .where('teacher', isEqualTo: teacherName)
          .where('day', isEqualTo: selectedDay)
          // Avoid composite index by not ordering server-side; sort client-side
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Failed to load routine: ${snap.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        final docs = snap.data?.docs ?? [];

        // client-side sort by time string
        docs.sort((a, b) {
          final ta = (a.data()['time'] ?? '') as String;
          final tb = (b.data()['time'] ?? '') as String;
          return ta.compareTo(tb);
        });

        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No routine available for this day.',
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return Column(
          children: docs.map((d) {
            final r = d.data();
            final time = (r['time'] ?? '') as String;
            final courseName = (r['courseName'] ?? '') as String;
            final code = (r['courseCode'] ?? '') as String;
            final room = (r['room'] ?? '') as String;
            final batch = (r['batch'] ?? '') as String;
            final initials = (r['teacherInitial'] ?? '') as String;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFBBE0BD), Color(0xFFFFFFFF)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '$courseName ($code)',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text('$room  |  Batch: $batch',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  if (initials.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green.shade700,
                        child: Text(
                          initials,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

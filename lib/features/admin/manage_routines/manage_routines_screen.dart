import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';

class ManageRoutineScreen extends StatefulWidget {
  const ManageRoutineScreen({super.key});

  @override
  State<ManageRoutineScreen> createState() => _ManageRoutineScreenState();
}

class _ManageRoutineScreenState extends State<ManageRoutineScreen>
    with SingleTickerProviderStateMixin {
  final List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday'
  ];
  final List<String> _defaultBatches = [];

  String selectedDay = 'Saturday';
  String selectedBatch = '';

  final TextEditingController _batchController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  final _fs = FirestoreService.instance;

  // Collections
  static const String routinesCol = 'routines';
  static const String batchesCol = 'batches';

  @override
  void initState() {
    super.initState();

    // Auto-select today's day (excluding Friday)
    final today = DateTime.now().weekday; // 1 = Monday, ..., 7 = Sunday
    final weekMap = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Saturday', // Skipping Friday
      6: 'Saturday',
      7: 'Sunday'
    };
    final todayName = weekMap[today] ?? 'Sunday';
    if (days.contains(todayName)) {
      selectedDay = todayName;
    }
    // default selectedBatch will be set from stream when data available

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  void _showRoutineForm({Map<String, dynamic>? routine, String? docId}) {
    final courseName = TextEditingController(text: routine?['courseName']);
    final courseCode = TextEditingController(text: routine?['courseCode']);
    final teacher = TextEditingController(text: routine?['teacher']);
    final room = TextEditingController(text: routine?['room']);
    final time = TextEditingController(text: routine?['time']);
    final teacherInitial =
        TextEditingController(text: routine?['teacherInitial']);
    String formBatch = routine?['batch']?.toString() ?? selectedBatch;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(routine == null ? 'Add Routine' : 'Edit Routine'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: courseName,
                  decoration: const InputDecoration(labelText: 'Course Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Required field' : null,
                ),
                TextFormField(
                  controller: courseCode,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                  validator: (value) =>
                      value!.isEmpty ? 'Required field' : null,
                ),
                TextFormField(
                  controller: teacher,
                  decoration: const InputDecoration(labelText: 'Teacher Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Required field' : null,
                ),
                TextFormField(
                  controller: teacherInitial,
                  decoration: const InputDecoration(
                      labelText: 'Teacher Initial (unique)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
                TextFormField(
                  controller: room,
                  decoration: const InputDecoration(labelText: 'Room Number'),
                  validator: (value) =>
                      value!.isEmpty ? 'Required field' : null,
                ),
                TextFormField(
                  controller: time,
                  decoration: const InputDecoration(
                      labelText: 'Time (e.g. 8:30 AM - 10:00 AM)'),
                  validator: (value) =>
                      value!.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 12),
                // Batch input field (dropdown populated from batches if available, fallback to free text)
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _fs.streamCollection(batchesCol),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final List<String> batches = docs.map((d) => d.id).toList()
                      ..sort();
                    if (batches.isEmpty) {
                      // fallback to simple text input if no batches collection
                      return TextFormField(
                        initialValue: formBatch,
                        decoration: const InputDecoration(labelText: 'Batch'),
                        onChanged: (v) => formBatch = v.trim(),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      );
                    }
                    if (!batches.contains(formBatch) && batches.isNotEmpty) {
                      formBatch = batches.first;
                    }
                    return DropdownButtonFormField<String>(
                      value: formBatch.isEmpty ? null : formBatch,
                      decoration: const InputDecoration(labelText: 'Batch'),
                      items: batches
                          .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (val) {
                        formBatch = (val ?? '').trim();
                      },
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newRoutine = {
                  'courseName': courseName.text.trim(),
                  'courseCode': courseCode.text.trim(),
                  'teacher': teacher.text.trim(),
                  'teacherInitial': teacherInitial.text.trim().toUpperCase(),
                  'room': room.text.trim(),
                  'time': time.text.trim(),
                  'day': selectedDay,
                  'batch': formBatch,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (docId == null) {
                  await _fs.add(routinesCol, newRoutine);
                } else {
                  await _fs.set(routinesCol, docId, newRoutine, merge: true);
                }

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteRoutine(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Routine'),
        content: const Text('Are you sure you want to delete this routine?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _fs.delete(routinesCol, docId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _routineStream() {
    // If no batch selected yet, avoid querying and return empty stream so UI doesn't error
    if (selectedBatch.isEmpty) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    // Remove orderBy('time') to avoid issues if 'time' is a non-sortable string range
    return _fs.streamCollection(
      routinesCol,
      build: (q) => q
          .where('day', isEqualTo: selectedDay)
          .where('batch', isEqualTo: selectedBatch),
    );
  }

  Future<void> _addBatch() async {
    final newBatch = _batchController.text.trim();
    if (newBatch.isEmpty) return;

    // create doc with id = batch for uniqueness
    await _fs.set(batchesCol, newBatch, {
      'name': newBatch,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _batchController.clear();
  }

  Future<void> _deleteBatch(String batch) async {
    await _fs.delete(batchesCol, batch);
    if (selectedBatch == batch) {
      selectedBatch = _defaultBatches.first;
      setState(() {});
    }
  }

  void _openManageBatchesDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setStateDialog) {
        Future<void> addBatch() async {
          final val = controller.text.trim();
          if (val.isEmpty) return;
          await _fs.set(batchesCol, val, {
            'name': val,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          controller.clear();
        }

        Future<void> editBatch(String oldId) async {
          final editCtrl = TextEditingController(text: oldId);
          final newId = await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Edit Batch'),
              content: TextField(
                controller: editCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter new batch id (e.g. 1)',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, editCtrl.text.trim()),
                  child: const Text('Save'),
                ),
              ],
            ),
          );
          if (newId == null || newId.isEmpty || newId == oldId) return;

          // Rename: create new doc then delete old.
          final batchDoc = await _fs.get(batchesCol, oldId);
          final data = batchDoc.data() ?? {};
          await _fs.set(batchesCol, newId, {
            ...data,
            'name': newId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          await _fs.delete(batchesCol, oldId);

          if (selectedBatch == oldId) {
            setState(() => selectedBatch = newId);
          }
        }

        Future<void> deleteBatch(String id) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Batch'),
              content: Text('Delete batch "$id"? This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await _fs.delete(batchesCol, id);
            if (selectedBatch == id) {
              setState(() => selectedBatch = '');
            }
          }
        }

        return AlertDialog(
          title: const Text('Manage Batches'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'New batch (e.g. 1)',
                        ),
                        onSubmitted: (_) => addBatch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: addBatch,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _fs.streamCollection(
                    batchesCol,
                    build: (q) => q.orderBy(FieldPath.documentId),
                  ),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'No batches yet. Add one above.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (_, i) {
                          final id = docs[i].id;
                          return ListTile(
                            title: Text(id),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () => editBatch(id),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => deleteBatch(id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // [DAY]
                DropdownButton<String>(
                  hint: const Text('Day'),
                  value: selectedDay.isEmpty ? null : selectedDay,
                  onChanged: (val) => setState(() => selectedDay = val ?? ''),
                  items: days
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                ),
                const SizedBox(width: 16),

                // [SELECTED BATCH FOR PREVIEW] - prefers batches collection; falls back to derive from routines for current day
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _fs.streamCollection(batchesCol),
                  builder: (context, batchSnapshot) {
                    final batchDocs = batchSnapshot.data?.docs ?? [];
                    List<String> batches = batchDocs.map((d) => d.id).toList();

                    Widget buildPreviewDropdown(List<String> opts) {
                      return DropdownButton<String>(
                        hint: const Text('Selected Batch'),
                        value: (selectedBatch.isNotEmpty &&
                                opts.contains(selectedBatch))
                            ? selectedBatch
                            : null,
                        onChanged: (val) {
                          setState(() => selectedBatch = val ?? '');
                        },
                        items: opts
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                      );
                    }

                    if (batches.isNotEmpty) {
                      return buildPreviewDropdown(batches);
                    }

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _fs.streamCollection(
                        routinesCol,
                        build: (q) => q.where('day', isEqualTo: selectedDay),
                      ),
                      builder: (context, routineSnap) {
                        final rdocs = routineSnap.data?.docs ?? [];
                        final derived = <String>{
                          for (final d in rdocs)
                            (d.data()['batch'] ?? '').toString()
                        }..removeWhere((e) => e.isEmpty);
                        batches = derived.toList()..sort();
                        return buildPreviewDropdown(batches);
                      },
                    );
                  },
                ),

                const SizedBox(width: 16),
              ],
            ),
          ),
          // Removed "Manage Batches" UI per request
          const SizedBox(height: 12),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _routineStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                        child:
                            Text('No routine found for this day and batch.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final doc = docs[index];
                      final routine = doc.data();
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(routine['courseName'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Code: ${routine['courseCode'] ?? ''}'),
                              Text('Teacher: ${routine['teacher'] ?? ''}'),
                              Text(
                                  'Initial: ${routine['teacherInitial'] ?? ''}'),
                              Text('Room: ${routine['room'] ?? ''}'),
                              Text('Time: ${routine['time'] ?? ''}'),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange),
                                onPressed: () => _showRoutineForm(
                                  routine: routine,
                                  docId: doc.id,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteRoutine(doc.id),
                              ),
                            ],
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addRoutineFab',
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Routine'),
            onPressed: () => _showRoutineForm(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

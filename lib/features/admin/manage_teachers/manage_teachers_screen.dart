import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../services/firestore_service.dart';

class ManageTeacherScreen extends StatefulWidget {
  const ManageTeacherScreen({super.key});

  @override
  State<ManageTeacherScreen> createState() => _ManageTeacherScreenState();
}

class _ManageTeacherScreenState extends State<ManageTeacherScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  final _fs = FirestoreService.instance;
  static const String teachersCol = 'teachers';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  Future<String> _uploadToImgBB(File file) async {
    // Using provided API key
    const apiKey = 'b6afb366c0d7f03f6368483a1ba5fb44';
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final response = await http.post(uri, body: {'image': base64Image});
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final url = (json['data']?['url'] ?? json['data']?['display_url']) as String?;
      if (url == null || url.isEmpty) {
        throw Exception('ImgBB response missing url');
      }
      return url;
    } else {
      throw Exception('ImgBB upload failed: ${response.statusCode} ${response.body}');
    }
  }

  void _showTeacherForm({Map<String, dynamic>? existingData, String? docId}) {
    final nameController = TextEditingController(text: existingData?['name']);
    final emailController = TextEditingController(text: existingData?['email']);
    final roleController = TextEditingController(text: existingData?['role']);
    final initialController =
        TextEditingController(text: existingData?['initial']);
    File? selectedFile; // kept for UI, uploaded to ImgBB on save
    String? uploadError;
    bool isUploading = false;

    bool showNameError = false;
    bool showEmailError = false;
    bool showRoleError = false;
    bool showInitialError = false;
    String? initialErrorMessage;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text(existingData == null ? 'Add Teacher' : 'Edit Teacher'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      errorText: showNameError ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: showEmailError ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roleController,
                    decoration: InputDecoration(
                      labelText: 'Role (e.g. Professor, Lecturer)',
                      errorText: showRoleError ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: initialController,
                    decoration: InputDecoration(
                      labelText: 'Teacher Initial (Unique)',
                      errorText: showInitialError ? initialErrorMessage : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                      );
                      if (result != null && result.files.single.path != null) {
                        setModalState(() {
                          selectedFile = File(result.files.single.path!);
                          uploadError = null;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Select Photo'),
                  ),
                  const SizedBox(height: 12),
                  if (selectedFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedFile!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (uploadError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      uploadError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final role = roleController.text.trim();
                  final initial = initialController.text.trim().toUpperCase();

                  showNameError = name.isEmpty;
                  showEmailError = email.isEmpty;
                  showRoleError = role.isEmpty;
                  showInitialError = initial.isEmpty;
                  initialErrorMessage = initial.isEmpty ? 'Required' : null;

                  (context as Element).markNeedsBuild();

                  if (showNameError ||
                      showEmailError ||
                      showRoleError ||
                      showInitialError) {
                    return;
                  }

                  String? finalPhotoUrl = existingData?['photoUrl'];

                  if (selectedFile != null) {
                    try {
                      setModalState(() {
                        isUploading = true;
                        uploadError = null;
                      });
                      finalPhotoUrl = await _uploadToImgBB(selectedFile!);
                    } catch (e) {
                      setModalState(() {
                        uploadError = 'Image upload failed. Please try another image.';
                      });
                      setModalState(() {
                        isUploading = false;
                      });
                      return;
                    } finally {
                      setModalState(() {
                        isUploading = false;
                      });
                    }
                  }

                  final payload = {
                    'name': name,
                    'email': email,
                    'role': role,
                    'initial': initial,
                    'photoUrl': finalPhotoUrl,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };

                  if (docId == null) {
                    await _fs.add(teachersCol, {
                      ...payload,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  } else {
                    await _fs.set(teachersCol, docId, payload, merge: true);
                  }

                  if (mounted) Navigator.pop(context);
                },
                child: isUploading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _deleteTeacher(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this teacher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _fs.delete(teachersCol, docId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher, String docId) {
    final imageFile = teacher['imageFile'];
    final photoUrl = teacher['photoUrl'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: imageFile != null
              ? FileImage(imageFile)
              : (photoUrl != null && (photoUrl as String).isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
        ),
        title: Text(
          '${teacher['name']} (${teacher['initial']})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teacher['email'] ?? '', style: const TextStyle(fontSize: 14)),
            Text(teacher['role'] ?? '',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () =>
                  _showTeacherForm(existingData: teacher, docId: docId),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTeacher(docId),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _fs.streamCollection(
                  teachersCol,
                  build: (q) => q.orderBy('name'),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No teachers added yet.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final d = docs[index];
                      final data = d.data();
                      return _buildTeacherCard(data, d.id);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTeacherForm(),
        label: const Text('Add Teacher'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
    );
  }
}

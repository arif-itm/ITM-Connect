import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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

  // Native (mobile/desktop): upload from File (mirrors curl -F image=@...)
  Future<String> _uploadToImgBB(File file) async {
    const apiKey = 'b6afb366c0d7f03f6368483a1ba5fb44';
    final uri = Uri.parse('https://api.imgbb.com/1/upload');

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('Selected file is empty.');
    }

    final request = http.MultipartRequest('POST', uri)..fields['key'] = apiKey;
    final fileName = file.path.split('/').last;
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: fileName));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic> jsonResp;
    try {
      jsonResp = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('ImgBB response parse error: ${response.statusCode} ${response.body}');
    }

    if (response.statusCode != 200 || jsonResp['success'] != true) {
      final err = jsonResp['error'];
      final errMessage = err is Map<String, dynamic> ? (err['message']?.toString() ?? '') : '';
      throw Exception('ImgBB upload failed: ${response.statusCode} ${errMessage.isNotEmpty ? errMessage : response.body}');
    }

    final data = jsonResp['data'] as Map<String, dynamic>?;
    final url = (data?['display_url'] ?? data?['url'])?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('ImgBB response missing URL');
    }
    return url;
  }

  // Web: upload from bytes (path is unavailable on web)
  Future<String> _uploadBytesToImgBB(Uint8List bytes, {required String fileName}) async {
    const apiKey = 'b6afb366c0d7f03f6368483a1ba5fb44';
    final uri = Uri.parse('https://api.imgbb.com/1/upload');

    if (bytes.isEmpty) {
      throw Exception('Selected file is empty.');
    }

    final request = http.MultipartRequest('POST', uri)..fields['key'] = apiKey;
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: fileName));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic> jsonResp;
    try {
      jsonResp = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('ImgBB response parse error: ${response.statusCode} ${response.body}');
    }

    if (response.statusCode != 200 || jsonResp['success'] != true) {
      final err = jsonResp['error'];
      final errMessage = err is Map<String, dynamic> ? (err['message']?.toString() ?? '') : '';
      throw Exception('ImgBB upload failed: ${response.statusCode} ${errMessage.isNotEmpty ? errMessage : response.body}');
    }

    final data = jsonResp['data'] as Map<String, dynamic>?;
    final url = (data?['display_url'] ?? data?['url'])?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('ImgBB response missing URL');
    }
    return url;
  }

  void _showTeacherForm({Map<String, dynamic>? existingData, String? docId}) {
    final nameController = TextEditingController(text: existingData?['name']);
    final emailController = TextEditingController(text: existingData?['email']);
    final roleController = TextEditingController(text: existingData?['role']);
    final initialController =
        TextEditingController(text: existingData?['initial']);

    // Selection state
    File? selectedFile; // native platforms
    Uint8List? selectedBytes; // web platforms
    String? selectedFileName;

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

                  // Photo requirements note
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCCD9FF)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photo requirements',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B4CB3),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '• Format: JPG, JPEG, or PNG\n• Max size: 10 MB\n• Recommended: square image for best avatar fit',
                          style: TextStyle(fontSize: 12, color: Color(0xFF2B4CB3)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png'],
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final picked = result.files.single;
                        final ext = (picked.extension ?? '').toLowerCase();
                        final allowed = ['jpg', 'jpeg', 'png'];
                        String? localError;

                        if (!allowed.contains(ext)) {
                          localError = 'Invalid file format. Select JPG, JPEG, or PNG.';
                        } else if (picked.size > 10 * 1024 * 1024) {
                          localError = 'File too large. Max allowed size is 10 MB.';
                        } else if ((picked.bytes == null || picked.bytes!.isEmpty) &&
                            (picked.path == null || picked.path!.isEmpty)) {
                          localError = 'Could not read selected file.';
                        }

                        setModalState(() {
                          if (localError != null) {
                            uploadError = localError;
                            selectedFile = null;
                            selectedBytes = null;
                            selectedFileName = null;
                          } else {
                            uploadError = null;
                            selectedFileName = picked.name;
                            if (kIsWeb) {
                              // Web: path is unavailable; use bytes
                              selectedBytes = picked.bytes!;
                              selectedFile = null;
                            } else {
                              // Native: can use path
                              selectedFile = File(picked.path!);
                              selectedBytes = null;
                            }
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Select Photo'),
                  ),
                  const SizedBox(height: 12),

                  if (!kIsWeb && selectedFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedFile!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (kIsWeb && selectedBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        selectedBytes!,
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

                  // Decide upload source
                  final bool hasNewImage =
                      kIsWeb ? (selectedBytes != null) : (selectedFile != null);

                  if (hasNewImage) {
                    try {
                      setModalState(() {
                        isUploading = true;
                        uploadError = null;
                      });

                      if (kIsWeb && selectedBytes != null) {
                        finalPhotoUrl = await _uploadBytesToImgBB(
                          selectedBytes!,
                          fileName: selectedFileName ?? 'photo.jpg',
                        );
                      } else if (!kIsWeb && selectedFile != null) {
                        finalPhotoUrl = await _uploadToImgBB(selectedFile!);
                      }
                    } catch (e) {
                      // ignore: avoid_print
                      print('ImgBB upload error: $e');
                      setModalState(() {
                        uploadError =
                            'Image upload failed: ${e is Exception ? e.toString().replaceFirst("Exception: ", "") : e.toString()}';
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
    final photoUrl = teacher['photoUrl'] as String?;

    Widget avatarChild;
    if (imageFile != null) {
      avatarChild = CircleAvatar(
        radius: 28,
        backgroundImage: FileImage(imageFile),
      );
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      // Use Image.network with errorBuilder to avoid breaking UI on web CORS/hotlink issues
      avatarChild = CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: Image.network(
            photoUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/default_profile.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      avatarChild = const CircleAvatar(
        radius: 28,
        backgroundImage: AssetImage('assets/images/default_profile.png'),
      );
    }

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: avatarChild,
        title: Text(
          '${teacher['name']} (${teacher['initial']})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teacher['email'] ?? '', style: const TextStyle(fontSize: 14)),
            Text(
              teacher['role'] ?? '',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showTeacherForm(existingData: teacher, docId: docId),
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
    _animation_controller_dispose_safe();
    super.dispose();
  }

  void _animation_controller_dispose_safe() {
    try {
      _animationController.dispose();
    } catch (_) {
      // ignore
    }
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

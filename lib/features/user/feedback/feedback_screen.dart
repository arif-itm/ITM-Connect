import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _feedbackType = 'Suggestion';
  bool isSubmitting = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  final List<String> _feedbackTypes = [
    'Suggestion',
    'Bug Report',
    'Complaint',
    'Appreciation'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'type': _feedbackType,
        'message': _messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('feedback').add(payload);

      if (!mounted) return;

      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      setState(() {
        _feedbackType = 'Suggestion';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Thank you for your feedback!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Unified light background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 650),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'We value your feedback!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Your Name',
                      icon: Icons.person_outline,
                      validator: (val) =>
                          val!.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 18),

                    // DIU Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'DIU Email',
                      icon: Icons.email_outlined,
                      hint: 'example@diu.edu.bd',
                      validator: (val) {
                        if (val!.isEmpty) return 'Email is required';
                        if (!val.endsWith('@diu.edu.bd')) {
                          return 'Only DIU email addresses are allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Feedback Type
                    DropdownButtonFormField<String>(
                      value: _feedbackType,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: _feedbackTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Feedback Type',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _feedbackType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // Message
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Your Message',
                        hintText: 'Write your feedback here...',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.feedback_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (val) => val!.isEmpty
                          ? 'Feedback message cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 30),

                    // Submit
                    Center(
                      child: isSubmitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _submitFeedback,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Submit Feedback'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchUri(String uriString) async {
    final uri = Uri.parse(uriString);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $uriString')),
      );
    }
  }

  Widget _linkCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double width,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final cardWidth = isWide
        ? MediaQuery.of(context).size.width / 2 - 48
        : MediaQuery.of(context).size.width - 40;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('settings')
              .doc('contact')
              .snapshots(),
          builder: (context, snap) {
            final data = snap.data?.data() ?? {};
            final phone = (data['phone'] ?? '') as String;
            final email =
                (data['email'] ?? '') as String;
            final website =
                (data['website'] ?? '')
                    as String;
            final facebook =
                (data['facebook'] ?? '')
                    as String;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _linkCard(
                        icon: Icons.phone,
                        title: 'Phone',
                        value: phone,
                        color: Colors.teal,
                        width: cardWidth,
                        onTap: () => _launchUri('tel:${phone.replaceAll('-', '')}'),
                      ),
                      _linkCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: email,
                        color: Colors.green,
                        width: cardWidth,
                        onTap: () => _launchUri('mailto:$email'),
                      ),
                      _linkCard(
                        icon: Icons.language,
                        title: 'Website',
                        value: website,
                        color: Colors.blue,
                        width: cardWidth,
                        onTap: () => _launchUri(website),
                      ),
                      _linkCard(
                        icon: Icons.facebook,
                        title: 'Facebook',
                        value: facebook,
                        color: Colors.indigo,
                        width: cardWidth,
                        onTap: () => _launchUri(facebook),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

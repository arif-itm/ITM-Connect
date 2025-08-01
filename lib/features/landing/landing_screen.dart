import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:itm_connect/features/admin/login/admin_login_screen.dart';
import 'package:itm_connect/features/user/home/user_home_screen.dart';
import 'package:itm_connect/widgets/app_layout.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedLogoIcon() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (_, child) => Padding(
        padding: EdgeInsets.only(top: _bounceAnimation.value),
        child: child,
      ),
      child: const CircleAvatar(
        radius: 34,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.school,
          size: 30,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Information Technology & Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'One place for ITM information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showAppBar: false,
      showBottomNavBar: false,
      currentIndex: -1,
      onBottomNavTap: (_) {},
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF5F5F5), // Background color
            child: Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAnimatedLogoIcon(),
                        const SizedBox(height: 12),
                        _buildMainCard(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserHomeScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      label: const Text('Get Started', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.indigo,
              tooltip: 'Admin Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                );
              },
              child: const Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

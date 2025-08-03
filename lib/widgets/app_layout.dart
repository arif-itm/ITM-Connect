

import 'package:flutter/material.dart';
import 'package:itm_connect/services/prefs_service.dart';

class AppLayout extends StatelessWidget {
  final bool showAppBar;
  final bool showBottomNavBar;
  final bool showFloatingActionButton;
  final int currentIndex;
  final Widget body;
  final void Function(int index) onBottomNavTap;
  final Widget? leading;

  const AppLayout({
    super.key,
    required this.body,
    this.showAppBar = true,
    this.showBottomNavBar = true,
    this.showFloatingActionButton = true,
    this.currentIndex = -1,
    required this.onBottomNavTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              leading: leading ??
                  IconButton(
                    icon: const Icon(Icons.dashboard, color: Colors.teal),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                  ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(width: 8),
                  const Text(
                    'ITM Connect',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.teal),
                  onPressed: () async {
                    await PrefsService.clearHasOnboarded();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                ),
              ],
            )
          : null,
      body: SafeArea(child: body),
      floatingActionButton: showBottomNavBar && showFloatingActionButton
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              onPressed: () => onBottomNavTap(2),
              child: const Icon(Icons.calendar_month, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: showBottomNavBar && showFloatingActionButton
          ? FloatingActionButtonLocation.centerDocked
          : null,
      bottomNavigationBar: showBottomNavBar
          ? SafeArea(
              child: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                child: SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.person, 'Teachers', 0),
                      _buildNavItem(Icons.notifications, 'Notices', 1),
                      const SizedBox(width: 40), // for FAB space
                      _buildNavItem(Icons.contact_mail, 'Contact', 3),
                      _buildNavItem(Icons.feedback, 'Feedback', 4),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? Colors.teal : Colors.grey;

    return GestureDetector(
      onTap: () => onBottomNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.school,
        size: 20,
        color: Colors.teal.shade700,
      ),
    );
  }
}

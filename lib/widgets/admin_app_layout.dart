import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAppLayout extends StatelessWidget {
  final bool showAppBar;
  final bool showBottomNavBar;
  final int currentIndex;
  final Widget body;
  final void Function(int index) onBottomNavTap;
  final Widget? leading;

  const AdminAppLayout({
    super.key,
    required this.body,
    required this.onBottomNavTap,
    this.currentIndex = 0,
    this.showAppBar = true,
    this.showBottomNavBar = true,
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
                      if (currentIndex != -1) {
                        onBottomNavTap(-1); // Go to dashboard welcome page
                      }
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
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text(
                            'Are you sure you want to logout'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      try {
                        // Firebase sign out (best-effort). Route is guarded, so no local flags.
                        await FirebaseAuth.instance.signOut();
                      } catch (_) {
                        // Even if signOut throws, still navigate to landing
                      }
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ],
            )
          : null,
      body: body,
      bottomNavigationBar: showBottomNavBar
          ? BottomNavigationBar(
              currentIndex: currentIndex >= 0 ? currentIndex : 0,
              onTap: onBottomNavTap,
              selectedItemColor: currentIndex == -1 ? Colors.grey : Colors.teal,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: TextStyle(
                fontSize: 14,
                fontWeight:
                    currentIndex == -1 ? FontWeight.normal : FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Teachers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notices',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Routines',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.contact_mail),
                  label: 'Contact',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.feedback),
                  label: 'Feedback',
                ),
              ],
            )
          : null,
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

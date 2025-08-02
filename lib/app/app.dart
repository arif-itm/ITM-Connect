import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itm_connect/features/landing/landing_screen.dart';
import 'package:itm_connect/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:itm_connect/services/auth_guard.dart';
import 'package:itm_connect/features/user/home/user_home_screen.dart';
import 'package:itm_connect/features/user/class_routine/class_routine_screen.dart';
import 'package:itm_connect/features/user/teacher/list/teacher_list_screen.dart';
import 'package:itm_connect/features/user/notice/notice_board_screen.dart';
import 'package:itm_connect/features/user/contact/contact_us_screen.dart';
import 'package:itm_connect/features/user/feedback/feedback_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthGuard(),
      child: MaterialApp(
        title: 'ITM Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.green,
          useMaterial3: true,
        ),
        // Use home OR initialRoute/routes, not both with '/' when home is set.
        home: const _AppEntry(), // Startup check widget
        onGenerateRoute: (settings) {
          // Guarded admin route
          if (settings.name == '/admin_home') {
            return MaterialPageRoute(
              builder: (ctx) {
                final guard = Provider.of<AuthGuard>(ctx);
                if (guard.loading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (guard.user == null || !guard.isAdmin) {
                  // Not authorized -> Landing
                  return const LandingScreen();
                }
                return const AdminDashboardScreen();
              },
              settings: settings,
            );
          }

          // Public routes (non-admin)
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const UserHomeScreen(),
                settings: settings,
              );
            case '/class-routine':
              return MaterialPageRoute(
                builder: (_) => const ClassRoutineScreen(),
                settings: settings,
              );
            case '/teachers':
              return MaterialPageRoute(
                builder: (_) => const TeacherListScreen(),
                settings: settings,
              );
            case '/notices':
              return MaterialPageRoute(
                builder: (_) => const NoticeBoardScreen(),
                settings: settings,
              );
            case '/contact':
              return MaterialPageRoute(
                builder: (_) => const ContactUsScreen(),
                settings: settings,
              );
            case '/feedback':
              return MaterialPageRoute(
                builder: (_) => const FeedbackScreen(),
                settings: settings,
              );
          }

          // Fallback to Landing
          return MaterialPageRoute(
            builder: (_) => const LandingScreen(),
            settings: settings,
          );
        },
      ),
    );
  }
}

/// Splash/entry that decides initial navigation based on isAdminLogged
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  @override
  void initState() {
    super.initState();
    // No local storage. FirebaseAuth restores session automatically.
    // Routing is decided once AuthGuard finishes resolving.
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  void _decide() {
    final guard = Provider.of<AuthGuard>(context, listen: false);
    // Listen once; when loading flips false, navigate accordingly.
    void handle() {
      if (!mounted) return;
      if (guard.loading) return;
      if (guard.user != null && guard.isAdmin) {
        Navigator.of(context).pushReplacementNamed('/admin_home');
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LandingScreen()),
        );
      }
    }

    // If already resolved, handle immediately; else wait for update.
    if (!guard.loading) {
      handle();
    } else {
      // Add a micro-listener to run once
      guard.addListener(handle);
      // Remove listener after first navigation by scheduling a microtask
      // Navigation will rebuild tree, so keeping it minimal.
      // We rely on navigation to drop this widget and its listeners.
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:itm_connect/features/landing/landing_screen.dart';
import 'package:itm_connect/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:itm_connect/services/auth_guard.dart';
import 'package:itm_connect/features/user/home/user_home_screen.dart';
import 'package:itm_connect/features/user/class_routine/class_routine_screen.dart';
import 'package:itm_connect/features/user/teacher/list/teacher_list_screen.dart';
import 'package:itm_connect/features/user/notice/notice_board_screen.dart';
import 'package:itm_connect/features/user/contact/contact_us_screen.dart';
import 'package:itm_connect/features/user/feedback/feedback_screen.dart';
import 'package:itm_connect/services/prefs_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;

  @override
  void initState() {
    super.initState();
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

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
        navigatorObservers: [_observer],
        // Use home OR initialRoute/routes, not both with '/' when home is set.
        home: const _AppEntry(), // Startup check widget
        // Note: initial screen will be decided by _AppEntry using PrefsService.hasOnboarded
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    final guard = Provider.of<AuthGuard>(context, listen: false);

    // Wait for AuthGuard to resolve admin session if still loading
    Future<void> waitGuard() async {
      if (!guard.loading) return;
      final c = Completer<void>();
      void handle() {
        if (!guard.loading) {
          guard.removeListener(handle);
          c.complete();
        }
      }
      guard.addListener(handle);
      return c.future;
    }

    await waitGuard();

    if (!mounted) return;

    // If admin logged in -> go admin
    if (guard.user != null && guard.isAdmin) {
      Navigator.of(context).pushReplacementNamed('/admin_home');
      return;
    }

    // For non-admin flow, check persisted onboarding flag
    final hasOnboarded = await PrefsService.getHasOnboarded();

    if (!mounted) return;

    if (hasOnboarded) {
      // Go directly to user home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    } else {
      // Default to landing
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

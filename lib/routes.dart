import 'package:flutter/material.dart';
import 'app/app.dart';
import 'features/landing/landing_screen.dart';
import 'features/admin/debug/firestore_debug_screen.dart';
import 'features/admin/settings/admin_contact_screen.dart';
import 'features/admin/feedback/manage_feedback_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String firestoreDebug = '/firestore-debug';

  static Map<String, WidgetBuilder> routes = {
    landing: (_) => const LandingScreen(),
    firestoreDebug: (_) => const FirestoreDebugScreen(),
    '/admin/contact': (_) => const AdminContactScreen(),
    '/admin/feedback': (_) => const ManageFeedbackScreen(),
  };
}

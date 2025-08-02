import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// AuthGuard listens to FirebaseAuth user changes and resolves whether
/// the current user is an admin by checking Firestore: admins/{uid}.isAdmin==true.
/// Exposes loading/user/isAdmin for route guarding.
class AuthGuard extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<User?>? _authSub;

  bool _loading = true;
  bool get loading => _loading;

  User? _user;
  User? get user => _user;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  AuthGuard({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _authSub = _auth.userChanges().listen((u) async {
      _user = u;
      if (u == null) {
        _isAdmin = false;
        _loading = false;
        notifyListeners();
        return;
      }
      _loading = true;
      notifyListeners();
      try {
        final doc = await _firestore.collection('admins').doc(u.uid).get();
        _isAdmin = doc.exists && (doc.data()?['isAdmin'] == true);
      } catch (_) {
        _isAdmin = false;
      } finally {
        _loading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

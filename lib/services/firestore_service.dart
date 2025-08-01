import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  Future<String> add(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> set(
    String collection,
    String id,
    Map<String, dynamic> data, {
    bool merge = true,
  }) {
    return _db.collection(collection).doc(id).set(
          data,
          SetOptions(merge: merge),
        );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> get(
    String collection,
    String id,
  ) {
    return _db.collection(collection).doc(id).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection, {
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> q)? build,
  }) {
    Query<Map<String, dynamic>> q = _db.collection(collection);
    if (build != null) q = build(q);
    return q.snapshots();
  }

  Future<void> delete(String collection, String id) {
    return _db.collection(collection).doc(id).delete();
  }
}

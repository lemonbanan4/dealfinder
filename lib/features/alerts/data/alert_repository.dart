import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/alert_config.dart';

class AlertRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _configsRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('alert_configs');
  }

  Future<void> saveAlertConfig(AlertConfig config) async {
    final ref = _configsRef;
    if (ref == null) {
      throw Exception('User must be signed in to save an alert.');
    }
    await ref.doc(config.id).set(config.toMap());
  }

  Stream<List<AlertConfig>> watchAlertConfigs() {
    final ref = _configsRef;
    if (ref == null) return Stream.value([]);
    return ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AlertConfig.fromMap(doc.data()))
              .toList();
        })
        .handleError((error) {
          // Fallback to empty list on error
          return <AlertConfig>[];
        });
  }

  Future<void> deleteAlertConfig(String id) async {
    await _configsRef?.doc(id).delete();
  }
}

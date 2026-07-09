import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/price_alert.dart';

class FirestoreAlertRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('alerts');

  Future<List<PriceAlert>> getAll(String userId) async {
    final snap = await _col(
      userId,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => PriceAlert.fromJson(d.data())).toList();
  }

  Future<void> save(String userId, PriceAlert alert) =>
      _col(userId).doc(alert.id).set(alert.toJson());

  Future<void> delete(String userId, String alertId) =>
      _col(userId).doc(alertId).delete();

  Future<void> markTriggered(String userId, String alertId) =>
      _col(userId).doc(alertId).update({'isTriggered': true});
}

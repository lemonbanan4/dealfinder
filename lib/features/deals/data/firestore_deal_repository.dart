import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/deal.dart';

class FirestoreDealRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('deals');

  Stream<List<Deal>> watchAll() {
    return _col
        .orderBy('scrapedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Deal.fromJson(_normalize(doc.data())))
              .toList(),
        );
  }

  Future<bool> hasDeals() async {
    final snap = await _col.limit(1).get();
    return snap.docs.isNotEmpty;
  }

  Future<void> seedDeals(List<Deal> deals) async {
    final batch = _db.batch();
    for (final deal in deals) {
      // Store scrapedAt as a Firestore Timestamp so server-side
      // orderBy works correctly with native timestamp ordering.
      final data = Map<String, dynamic>.from(deal.toJson());
      data['scrapedAt'] =
          Timestamp.fromDate(DateTime.parse(deal.toJson()['scrapedAt'] as String));
      batch.set(_col.doc(deal.id), data);
    }
    await batch.commit();
  }

  // Converts Firestore Timestamp → ISO string so Deal.fromJson works.
  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    final ts = data['scrapedAt'];
    if (ts is Timestamp) {
      return {...data, 'scrapedAt': ts.toDate().toIso8601String()};
    }
    return data;
  }
}

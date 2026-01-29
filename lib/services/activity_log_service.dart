import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityLogService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> log(String action, {Map<String, dynamic>? meta}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('activity_logs').add({
      'userId': user.uid,
      'action': action,
      'meta': meta ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

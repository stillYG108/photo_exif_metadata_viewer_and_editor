import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;

  /// Create Firestore user doc if not exists
  static Future<void> ensureUserDocument(User user) async {
    final userRef = _db.collection('users').doc(user.uid);

    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'email': user.email,
        'role': 'user',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔐 USERS
  static Future<void> createUser({
    required String uid,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'role': 'user',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // 🧰 SERVICES (admin only later)
  static Future<void> addService(String id, String name, String description) {
    return _db.collection('services').doc(id).set({
      'name': name,
      'description': description,
      'enabled': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 📁 JOBS
  static Future<void> createJob({
    required String userId,
    required String serviceId,
    required String inputFile,
  }) async {
    await _db.collection('jobs').add({
      'userId': userId,
      'serviceId': serviceId,
      'status': 'processing',
      'inputFile': inputFile,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'activity_logger.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> register(String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirestoreService.createUser(
      uid: userCred.user!.uid,
      email: email,
    );

    await ActivityLogger.log(
      userId: userCred.user!.uid,
      action: 'REGISTER',
      details: 'User registered',
    );
  }

  static Future<void> login(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await ActivityLogger.log(
      userId: userCred.user!.uid,
      action: 'LOGIN',
      details: 'User logged in',
    );
  }

  static Future<void> logout(String uid) async {
    await ActivityLogger.log(
      userId: uid,
      action: 'LOGOUT',
      details: 'User logged out',
    );
    await _auth.signOut();
  }
}

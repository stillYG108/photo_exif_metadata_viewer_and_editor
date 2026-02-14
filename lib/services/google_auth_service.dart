import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service to handle Google Sign-In authentication
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Using Android OAuth client from updated google-services.json
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// Sign in with Google
  /// 
  /// Returns [UserCredential] on success
  /// Throws exception on failure
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Check if user is currently signed in with Google
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Link Google account to existing Firebase user
  Future<UserCredential> linkWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link the credential to the current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      return await currentUser.linkWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to link Google account: $e');
    }
  }
}

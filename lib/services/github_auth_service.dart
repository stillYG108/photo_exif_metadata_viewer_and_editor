import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle GitHub Sign-In authentication
class GitHubAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with GitHub
  /// 
  /// Returns [UserCredential] on success
  /// Throws exception on failure
  Future<UserCredential> signInWithGitHub() async {
    try {
      // Create a GitHub provider
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      
      // Sign in with GitHub
      return await _auth.signInWithProvider(githubProvider);
    } catch (e) {
      throw Exception('Failed to sign in with GitHub: $e');
    }
  }

  /// Sign out from GitHub and Firebase
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Check if user is currently signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Link GitHub account to existing Firebase user
  Future<UserCredential> linkWithGitHub() async {
    try {
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      return await currentUser.linkWithProvider(githubProvider);
    } catch (e) {
      throw Exception('Failed to link GitHub account: $e');
    }
  }
}

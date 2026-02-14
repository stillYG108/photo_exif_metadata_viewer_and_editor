import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle GitHub Sign-In authentication
class GitHubAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with GitHub
  /// 
  /// Returns [UserCredential] on success
  /// Handles account linking if user already exists with different provider
  /// Throws exception on failure
  Future<UserCredential> signInWithGitHub() async {
    try {
      print('DEBUG: GitHubAuthService: Starting GitHub Sign-In...');

      // Create GitHub auth provider
      final GithubAuthProvider githubProvider = GithubAuthProvider();

      // Add scopes (IMPORTANT for proper user data + redirect handling)
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');

      // Trigger Firebase GitHub login
      print('DEBUG: GitHubAuthService: Calling Firebase signInWithProvider...');
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(githubProvider);

      print(
        'DEBUG: GitHubAuthService: Sign-In successful. UID: ${userCredential.user?.uid}',
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException: ${e.code} - ${e.message}');
      
      // Handle account exists with different credential
      // Log information but allow Firebase to handle the error naturally
      if (e.code == 'account-exists-with-different-credential') {
        print('DEBUG: Account exists with different credential.');
        print('DEBUG: This email is already registered with a different provider.');
        
        final String? email = e.email;
        
        if (email != null) {
          // Fetch existing sign-in methods for informational purposes
          try {
            final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
            print('DEBUG: Email $email has existing sign-in methods: $signInMethods');
            if (signInMethods.isNotEmpty) {
              print('DEBUG: User should sign in with: ${signInMethods.first}');
            }
          } catch (fetchError) {
            print('DEBUG: Could not fetch sign-in methods (Email Enumeration Protection may be enabled): $fetchError');
          }
        }
        
        print('DEBUG: To allow multiple providers for the same email:');
        print('DEBUG: Go to Firebase Console → Authentication → Settings');
        print('DEBUG: Enable "Allow creation of multiple accounts with the same email address"');
      }
      
      rethrow;
    } catch (e) {
      print('DEBUG: Unknown error during GitHub Sign-In: $e');
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

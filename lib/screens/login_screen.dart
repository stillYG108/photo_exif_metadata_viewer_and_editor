import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/crt_effect_container.dart';
import '../widgets/forensic_card.dart';
import '../widgets/animated_text.dart';
import '../services/google_auth_service.dart';
import '../services/github_auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final GitHubAuthService _githubAuthService = GitHubAuthService();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isGitHubLoading = false;
  String? _errorMessage;
  String? _successMessage;



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "CREDENTIALS_MISSING";
        _successMessage = null;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Show success message briefly
      setState(() {
        _isLoading = false;
        _successMessage = "ACCESS_GRANTED :: SESSION_INITIATED";
      });
      
      // Wait briefly to show success, then navigate
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Navigate to main shell - pop all routes and replace with main shell
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
      
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = "OPERATOR_NOT_FOUND";
          break;
        case 'wrong-password':
          errorMsg = "INVALID_ACCESS_CODE";
          break;
        case 'invalid-email':
          errorMsg = "INVALID_EMAIL_FORMAT";
          break;
        case 'user-disabled':
          errorMsg = "ACCOUNT_SUSPENDED";
          break;
        default:
          errorMsg = "AUTH_FAILED::${e.code.toUpperCase()}";
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
        _successMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "SYSTEM_ERROR::UNKNOWN";
        _successMessage = null;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      print('DEBUG: Starting Google Sign-In...');
      final userCredential = await _googleAuthService.signInWithGoogle();
      print('DEBUG: Google Sign-In successful, user: ${userCredential.user?.email}');
      
      // Show success message briefly
      setState(() {
        _isGoogleLoading = false;
        _successMessage = "GOOGLE_AUTH_SUCCESS :: SESSION_INITIATED";
      });
      
      // Wait briefly to show success, then navigate
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Navigate to main shell
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
      
    } on Exception catch (e) {
      print('DEBUG: Google Sign-In error: $e');
      String errorMsg = "GOOGLE_AUTH_FAILED";
      
      // Parse common errors
      if (e.toString().contains('sign_in_canceled') || e.toString().contains('cancelled')) {
        errorMsg = "SIGN_IN_CANCELLED_BY_USER";
      } else if (e.toString().contains('network_error')) {
        errorMsg = "NETWORK_ERROR :: CHECK_CONNECTION";
      } else if (e.toString().contains('sign_in_failed')) {
        errorMsg = "SIGN_IN_FAILED :: CHECK_FIREBASE_CONFIG";
      } else {
        errorMsg = "GOOGLE_AUTH_FAILED :: ${e.toString().substring(0, 50)}";
      }
      
      setState(() {
        _isGoogleLoading = false;
        _errorMessage = errorMsg;
      });
    } catch (e) {
      print('DEBUG: Unexpected error: $e');
      setState(() {
        _isGoogleLoading = false;
        _errorMessage = "UNEXPECTED_ERROR :: $e";
      });
    }
  }

  Future<void> _handleGitHubSignIn() async {
    setState(() {
      _isGitHubLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      print('DEBUG: Starting GitHub Sign-In...');
      final userCredential = await _githubAuthService.signInWithGitHub();
      print('DEBUG: GitHub Sign-In successful, user: ${userCredential.user?.email}');
      
      // Show success message briefly
      setState(() {
        _isGitHubLoading = false;
        _successMessage = "GITHUB_AUTH_SUCCESS :: SESSION_INITIATED";
      });
      
      // Wait briefly to show success, then navigate
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Navigate to main shell
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
      
    } on FirebaseAuthException catch (e) {
      print('DEBUG: GitHub Sign-In error: ${e.code} - ${e.message}');
      String errorMsg;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMsg = "ACCOUNT_COLLISION :: USE_ORIGINAL_PROVIDER";
          break;
        case 'user-disabled':
          errorMsg = "ACCOUNT_SUSPENDED";
          break;
        case 'operation-not-allowed':
          errorMsg = "GITHUB_AUTH_NOT_ENABLED";
          break;
        case 'invalid-credential':
          errorMsg = "INVALID_CREDENTIALS";
          break;
        default:
          errorMsg = "GITHUB_AUTH_FAILED :: ${e.code.toUpperCase()}";
      }

      setState(() {
        _isGitHubLoading = false;
        _errorMessage = errorMsg;
      });
    } on Exception catch (e) {
      print('DEBUG: GitHub Sign-In error: $e');
      String errorMsg = "GITHUB_AUTH_FAILED";
      
      // Parse common errors
      if (e.toString().contains('sign_in_canceled') || e.toString().contains('cancelled')) {
        errorMsg = "SIGN_IN_CANCELLED_BY_USER";
      } else if (e.toString().contains('network_error')) {
        errorMsg = "NETWORK_ERROR :: CHECK_CONNECTION";
      } else if (e.toString().contains('sign_in_failed')) {
        errorMsg = "SIGN_IN_FAILED :: CHECK_FIREBASE_CONFIG";
      } else {
        errorMsg = "GITHUB_AUTH_FAILED :: ${e.toString().substring(0, 50)}";
      }
      
      setState(() {
        _isGitHubLoading = false;
        _errorMessage = errorMsg;
      });
    } catch (e) {
      print('DEBUG: Unexpected error: $e');
      setState(() {
        _isGitHubLoading = false;
        _errorMessage = "UNEXPECTED_ERROR :: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CrtEffectContainer(
      child: Scaffold(
        backgroundColor: ForensicColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / ASCII Header
                  Text(
                    "EXIF.FORENSICS",
                    style: GoogleFonts.orbitron(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                      color: ForensicColors.greenPrimary,
                    ),
                  ),
                   Text(
                    "SECURE WORKSTATION LOGIN",
                    style: GoogleFonts.shareTechMono(
                      color: ForensicColors.textDim,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 48),

                  ForensicCard(
                    title: "AUTHENTICATION_REQUIRED",
                    isWarning: _errorMessage != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AnimatedText(
                              text: "// ERROR: $_errorMessage",
                              style: TextStyle(color: ForensicColors.alert),
                            ),
                          ),
                        
                        if (_successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AnimatedText(
                              text: "// SUCCESS: $_successMessage",
                              style: TextStyle(color: ForensicColors.success),
                            ),
                          ),

                        // Email
                        TextField(
                          controller: _emailController,
                          style: GoogleFonts.shareTechMono(color: ForensicColors.textPrimary),
                          cursorColor: ForensicColors.greenPrimary,
                          decoration: const InputDecoration(
                            labelText: "OPERATOR_ID (EMAIL)",
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: GoogleFonts.shareTechMono(color: ForensicColors.textPrimary),
                          cursorColor: ForensicColors.greenPrimary,
                          decoration: const InputDecoration(
                            labelText: "ACCESS_CODE (PASSWORD)",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (_isLoading)
                           const Center(
                            child: CircularProgressIndicator(
                              color: ForensicColors.greenPrimary,
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: _handleLogin,
                            child: const Text("INITIATE_SESSION"),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: ForensicColors.gridLine)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR",
                                style: GoogleFonts.shareTechMono(
                                  color: ForensicColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: ForensicColors.gridLine)),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Google Sign-In Button
                        if (_isGoogleLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: ForensicColors.greenPrimary,
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _handleGoogleSignIn,
                            icon: Icon(Icons.g_mobiledata, size: 28, color: ForensicColors.neonGreen),
                            label: Text(
                              "Google",
                              style: GoogleFonts.shareTechMono(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ForensicColors.neonGreen,
                              side: BorderSide(color: ForensicColors.neonGreen, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // GitHub Sign-In Button
                        if (_isGitHubLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: ForensicColors.greenPrimary,
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _handleGitHubSignIn,
                            icon: Icon(Icons.code, size: 24, color: ForensicColors.textPrimary),
                            label: Text(
                              "GitHub",
                              style: GoogleFonts.shareTechMono(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ForensicColors.textPrimary,
                              side: BorderSide(color: ForensicColors.textSecondary, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      "[ CREATE_NEW_PROFILE ]",
                      style: GoogleFonts.shareTechMono(
                        color: ForensicColors.textDim,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

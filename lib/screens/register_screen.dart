import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/crt_effect_container.dart';
import '../widgets/forensic_card.dart';
import '../widgets/animated_text.dart';
import '../services/google_auth_service.dart';
import '../services/github_auth_service.dart';
import '../services/sound_service.dart';
import '../widgets/animated_app_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "FIELDS_INCOMPLETE";
        _successMessage = null;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "PASSWORD_MISMATCH";
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Show success message
      setState(() {
        _isLoading = false;
        _successMessage = "ACCESS_GRANTED :: OPERATOR_REGISTERED";
      });
      
      // Wait a moment to show success, then navigate
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
      
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = "EMAIL_ALREADY_IN_USE";
          break;
        case 'weak-password':
          errorMsg = "PASSWORD_TOO_WEAK";
          break;
        case 'invalid-email':
          errorMsg = "INVALID_EMAIL_FORMAT";
          break;
        default:
          errorMsg = "REGISTRATION_FAILED::${e.code.toUpperCase()}";
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

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _googleAuthService.signInWithGoogle();
      
      // Show success message briefly
      setState(() {
        _isGoogleLoading = false;
        _successMessage = "GOOGLE_REGISTRATION_SUCCESS :: PROFILE_CREATED";
      });
      
      // Wait briefly to show success, then navigate
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Navigate to main shell
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
      
    } catch (e) {
      setState(() {
        _isGoogleLoading = false;
        _errorMessage = "GOOGLE_REGISTRATION_FAILED :: ${e.toString()}";
      });
    }
  }

  Future<void> _handleGitHubSignUp() async {
    setState(() {
      _isGitHubLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _githubAuthService.signInWithGitHub();
      
      // Show success message briefly
      setState(() {
        _isGitHubLoading = false;
        _successMessage = "GITHUB_REGISTRATION_SUCCESS :: PROFILE_CREATED";
      });
      
      // Wait briefly to show success, then navigate
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Navigate to main shell
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
      
    } catch (e) {
      setState(() {
        _isGitHubLoading = false;
        _errorMessage = "GITHUB_REGISTRATION_FAILED :: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CrtEffectContainer(
      child: Scaffold(
        backgroundColor: ForensicColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: ForensicColors.greenPrimary,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Logo
                  const AnimatedAppLogo(size: 150),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    "NEW_OPERATOR_REGISTRY",
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: ForensicColors.greenPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  ForensicCard(
                    title: "PROFILE_CREATION",
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
                            prefixIcon: Icon(Icons.person_add),
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
                            labelText: "SET_ACCESS_CODE",
                            prefixIcon: Icon(Icons.vpn_key),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: GoogleFonts.shareTechMono(color: ForensicColors.textPrimary),
                          cursorColor: ForensicColors.greenPrimary,
                          decoration: const InputDecoration(
                            labelText: "CONFIRM_ACCESS_CODE",
                            prefixIcon: Icon(Icons.lock_reset),
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
                            onPressed: () {
                              SoundService().playClickSound();
                              _handleRegister();
                            },
                            child: const Text("REGISTER_PROFILE"),
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
                        
                        // Google Sign-Up Button
                        if (_isGoogleLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: ForensicColors.greenPrimary,
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: () {
                              SoundService().playClickSound();
                              _handleGoogleSignUp();
                            },
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
                        
                        // GitHub Sign-Up Button
                        if (_isGitHubLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: ForensicColors.greenPrimary,
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: () {
                              SoundService().playClickSound();
                              _handleGitHubSignUp();
                            },
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

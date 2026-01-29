import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/activity_log_service.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_textfield.dart';
import '../widgets/retro_checkbox.dart';
import '../widgets/retro_window_chrome.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBD7EC),

      body: Center(
        child: Container(
          width: 360,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7CC),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ───────── TITLE BAR ─────────
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFF4A90E2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "EXIF FORENSICS LOGIN PORTAL",
                      style: TextStyle(color: Colors.white),
                    ),
                    RetroWindowButtons(),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // LOGO
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEFEF),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // EMAIL
                    RetroTextField(
                      label: "Email Address",
                      controller: _emailController,
                    ),

                    const SizedBox(height: 10),

                    // PASSWORD
                    const Text("Password"),
                    const SizedBox(height: 4),

                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !showPassword,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            child: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    const RetroCheckbox(label: "Remember credentials"),

                    const SizedBox(height: 16),

                    // LOGIN BUTTON
                    RetroButton(
                      text: "LOGIN",
                      onPressed: () async {
                        await _login(
                          context,
                          _emailController.text,
                          _passwordController.text,
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // CREATE ACCOUNT
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AUTH LOGIC (SECURE)
Future<void> _login(
    BuildContext context,
    String email,
    String password,
    ) async {
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await UserService.ensureUserDocument(user);
      await ActivityLogService.log('LOGIN');
    }

    // AuthGate will redirect automatically
  } on FirebaseAuthException catch (e) {
    String message = "Authentication failed";

    if (e.code == 'user-not-found') {
      message = "No user found for this email";
    } else if (e.code == 'wrong-password') {
      message = "Incorrect password";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

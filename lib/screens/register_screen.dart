import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/retro_button.dart';
import '../widgets/retro_textfield.dart';
import '../widgets/retro_checkbox.dart';
import '../widgets/retro_window_chrome.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool showPassword = false;
  bool showConfirmPassword = false;
  String source = "Social Media";

  // Controllers (SECURITY CRITICAL)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBD7EC),

      body: SafeArea(
        top: true,
        child: Center(
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7CC),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [

                // ───────── TITLE BAR ─────────
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: const Color(0xFFB05A7A),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(color: Colors.white),
                      ),
                      RetroWindowButtons(),
                    ],
                  ),
                ),

                // ───────── BODY ─────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ───────── LOGO ─────────
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _sectionTitle("Personal Information"),

                        RetroTextField(
                          label: "Username",
                          controller: _usernameController,
                        ),
                        const SizedBox(height: 6),

                        RetroTextField(
                          label: "Nationality",
                          controller: _nationalityController,
                        ),

                        _sectionTitle("Account Details"),

                        RetroTextField(
                          label: "Email Address",
                          controller: _emailController,
                        ),
                        const SizedBox(height: 6),

                        _passwordField(
                          "Password",
                          _passwordController,
                          showPassword,
                              () => setState(() => showPassword = !showPassword),
                        ),
                        const SizedBox(height: 6),

                        _passwordField(
                          "Confirm Password",
                          _confirmPasswordController,
                          showConfirmPassword,
                              () => setState(
                                  () => showConfirmPassword = !showConfirmPassword),
                        ),

                        _sectionTitle("Preferences"),

                        const Text("How did you hear about us?"),
                        const SizedBox(height: 4),

                        _retroDropdown(),

                        const SizedBox(height: 8),

                        const RetroCheckbox(
                          label: "I agree to system policies",
                        ),

                        const SizedBox(height: 18),

                        // ───────── REGISTER BUTTON ─────────
                        RetroButton(
                          text: "CREATE ACCOUNT",
                          onPressed: () {
                            _register(
                              context,
                              _emailController.text,
                              _passwordController.text,
                              _confirmPasswordController.text,
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "Back to Login",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── SECTION TITLE ─────────
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // ───────── PASSWORD FIELD ─────────
  Widget _passwordField(
      String label,
      TextEditingController controller,
      bool visible,
      VoidCallback toggle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
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
                  controller: controller,
                  obscureText: !visible,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: toggle,
                child: Icon(
                  visible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────── DROPDOWN ─────────
  Widget _retroDropdown() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: source,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "Social Media", child: Text("Social Media")),
            DropdownMenuItem(
                value: "Newsletter Ad", child: Text("Newsletter Ad")),
            DropdownMenuItem(value: "Friends", child: Text("Friends")),
            DropdownMenuItem(value: "Others", child: Text("Others")),
          ],
          onChanged: (value) {
            setState(() => source = value!);
          },
        ),
      ),
    );
  }
}

/// FIREBASE REGISTER LOGIC
Future<void> _register(
    BuildContext context,
    String email,
    String password,
    String confirmPassword,
    ) async {
  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all required fields")),
    );
    return;
  }

  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password must be at least 6 characters")),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    Navigator.pop(context); // back to login

  } on FirebaseAuthException catch (e) {
    String message = "Registration failed";

    if (e.code == 'weak-password') {
      message = "Password is too weak";
    } else if (e.code == 'email-already-in-use') {
      message = "Email already registered";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

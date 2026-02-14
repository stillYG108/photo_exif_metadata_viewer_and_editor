import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/glitch_text.dart';
import '../services/imgbb_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      color: Colors.transparent, // Background handled by parent
      child: user == null ? _buildNoUserState() : _buildUserProfile(context, user),
    );
  }

  Future<void> _showUpdateIntelDialog(BuildContext context, User user) async {
    final displayNameController = TextEditingController(text: user.displayName);
    final emailController = TextEditingController(text: user.email);
    File? selectedImage;
    String? imageUrl;
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ForensicColors.background,
          shape: BeveledRectangleBorder(
            side: BorderSide(color: ForensicColors.neonGreen, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: ForensicColors.neonGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                "UPDATE_INTEL",
                style: GoogleFonts.orbitron(
                  color: ForensicColors.neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Picture Section
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                      );
                      
                      if (image != null) {
                        setDialogState(() {
                          selectedImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: ForensicColors.neonGreen, width: 2),
                        color: Colors.black,
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : (user.photoURL != null
                              ? Image.network(user.photoURL!, fit: BoxFit.cover)
                              : Icon(Icons.add_a_photo, size: 40, color: ForensicColors.neonGreen)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "TAP TO CHANGE PHOTO",
                    style: GoogleFonts.shareTechMono(
                      color: ForensicColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Code Name Field
                Text(
                  "CODENAME",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.neonGreen,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: displayNameController,
                  style: GoogleFonts.shareTechMono(color: ForensicColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Enter codename",
                    hintStyle: TextStyle(color: ForensicColors.textSecondary.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.badge, color: ForensicColors.neonGreen),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field
                Text(
                  "SECURE_CHANNEL (EMAIL)",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.neonGreen,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: emailController,
                  style: GoogleFonts.shareTechMono(color: ForensicColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Enter email",
                    hintStyle: TextStyle(color: ForensicColors.textSecondary.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.alternate_email, color: ForensicColors.neonGreen),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "⚠ Email change requires re-authentication",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.warningAmber,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "ABORT",
                style: GoogleFonts.orbitron(color: ForensicColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ForensicColors.neonGreen,
              ),
              onPressed: isUploading ? null : () async {
                setDialogState(() => isUploading = true);

                try {
                  // Upload profile picture if selected
                  if (selectedImage != null) {
                    try {
                      // Upload to ImgBB
                      final imgbbService = ImgBBService();
                      imageUrl = await imgbbService.uploadImage(selectedImage!);
                      
                      // Update user's photoURL in Firebase Auth
                      await user.updatePhotoURL(imageUrl);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "✓ Photo uploaded successfully",
                              style: GoogleFonts.shareTechMono(color: ForensicColors.neonGreen),
                            ),
                            backgroundColor: Colors.black,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (uploadError) {
                      // ImgBB upload failed
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "⚠ Photo upload failed: ${uploadError.toString()}",
                              style: GoogleFonts.shareTechMono(color: ForensicColors.alertRed),
                            ),
                            backgroundColor: Colors.black,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }

                  // Update display name
                  if (displayNameController.text.trim() != user.displayName) {
                    await user.updateDisplayName(displayNameController.text.trim());
                  }

                  // Update email (requires re-authentication)
                  if (emailController.text.trim() != user.email) {
                    // Show re-authentication dialog
                    final password = await _showReauthDialog(dialogContext);
                    if (password != null && password.isNotEmpty) {
                      final credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: password,
                      );
                      await user.reauthenticateWithCredential(credential);
                      await user.updateEmail(emailController.text.trim());
                    }
                  }

                  // Reload user to get updated info
                  await user.reload();
                  
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    setState(() {}); // Refresh the UI
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "✓ INTEL UPDATED SUCCESSFULLY",
                          style: GoogleFonts.shareTechMono(color: ForensicColors.neonGreen),
                        ),
                        backgroundColor: Colors.black,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isUploading = false);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "⚠ UPDATE FAILED: ${e.toString()}",
                          style: GoogleFonts.shareTechMono(color: ForensicColors.alertRed),
                        ),
                        backgroundColor: Colors.black,
                      ),
                    );
                  }
                }
              },
              child: isUploading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      "COMMIT",
                      style: GoogleFonts.orbitron(color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showReauthDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ForensicColors.background,
        shape: BeveledRectangleBorder(
          side: BorderSide(color: ForensicColors.warningAmber, width: 2),
        ),
        title: Text(
          "RE-AUTHENTICATION REQUIRED",
          style: GoogleFonts.orbitron(
            color: ForensicColors.warningAmber,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter your password to confirm email change",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textPrimary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: GoogleFonts.shareTechMono(color: ForensicColors.textPrimary),
              decoration: InputDecoration(
                labelText: "PASSWORD",
                prefixIcon: Icon(Icons.lock, color: ForensicColors.warningAmber),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "CANCEL",
              style: GoogleFonts.orbitron(color: ForensicColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ForensicColors.warningAmber,
            ),
            onPressed: () => Navigator.pop(dialogContext, passwordController.text),
            child: Text(
              "VERIFY",
              style: GoogleFonts.orbitron(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoUserState() {
    return Center(
      child: CornerBracketContainer(
        color: ForensicColors.alertRed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: ForensicColors.alertRed, size: 64),
            const SizedBox(height: 24),
            GlitchText(
              "ACCESS_DENIED",
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ForensicColors.alertRed,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "CLASSIFIED CLEARANCE REQUIRED",
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / ID Badge
          CornerBracketContainer(
            color: ForensicColors.neonGreen,
            strokeWidth: 2,
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: ForensicColors.neonGreen, width: 2),
                    color: Colors.black,
                  ),
                  child: user.photoURL != null && user.photoURL!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.photoURL!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ForensicColors.neonGreen,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 40,
                            color: ForensicColors.neonGreen,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: ForensicColors.neonGreen,
                        ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlitchText(
                        "OPERATOR_DOSSIER",
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ForensicColors.neonGreen,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "CLEARANCE: LEVEL_4 // OMEGA",
                        style: GoogleFonts.shareTechMono(
                          fontSize: 12,
                          color: ForensicColors.cyberCyan,
                        ),
                      ),
                      const SizedBox(height: 4),
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: ForensicColors.neonGreen,
                        child: Text(
                          "STATUS: ACTIVE",
                          style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User Information Section
          _buildSectionHeader("IDENTITY_DATA"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ForensicColors.panelBackground,
              border: Border(left: BorderSide(color: ForensicColors.neonGreen, width: 2)),
            ),
            child: Column(
              children: [
                _buildInfoRow("CODENAME", user.displayName?.toUpperCase() ?? "UNKNOWN_AGENT", Icons.badge),
                const SizedBox(height: 16),
                _buildInfoRow("SECURE_CHANNEL", user.email ?? "NO_COMMS", Icons.alternate_email),
                const SizedBox(height: 16),
                _buildInfoRow("SERVICE_UID", user.uid, Icons.fingerprint),
                const SizedBox(height: 16),
                _buildInfoRow(
                  "INDUCTION_DATE",
                  user.metadata.creationTime != null
                      ? _formatDate(user.metadata.creationTime!)
                      : "REDACTED",
                  Icons.calendar_today,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Security Status
          _buildSectionHeader("SECURITY_PROTOCOLS"),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black.withOpacity(0.5),
            child: Column(
              children: [
                _buildStatusRow(
                  "CHANNEL_ENCRYPTION",
                  user.emailVerified ? "VERIFIED" : "UNSECURED",
                  user.emailVerified,
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  "2FA_PROTOCOL",
                  "DISABLED",
                  false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          _buildSectionHeader("COMMAND_OVERRIDES"),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showUpdateIntelDialog(context, user),
                  child: const Text("UPDATE_INTEL"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ForensicColors.alertRed,
                  ),
                  onPressed: () async {
                     final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: ForensicColors.background,
                          shape: BeveledRectangleBorder(
                            side: BorderSide(color: ForensicColors.alertRed),
                          ),
                          title: Text(
                            "TERMINATE_UPLINK?",
                            style: GoogleFonts.orbitron(
                              color: ForensicColors.alertRed,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          content: Text(
                            "Confirm disconnection from secure server.",
                            style: GoogleFonts.shareTechMono(
                              color: ForensicColors.textPrimary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: Text(
                                "ABORT",
                                style: GoogleFonts.orbitron(
                                  color: ForensicColors.textSecondary,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ForensicColors.alertRed,
                              ),
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: Text(
                                "DISCONNECT",
                                style: GoogleFonts.orbitron(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await FirebaseAuth.instance.signOut();
                      }
                  },
                  icon: const Icon(Icons.power_settings_new, color: Colors.black),
                  label: const Text("DISCONNECT"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "// $title",
        style: GoogleFonts.shareTechMono(
          color: ForensicColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: ForensicColors.neonGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.shareTechMono(
                  color: ForensicColors.neonGreen.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.shareTechMono(
                  color: ForensicColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(color: ForensicColors.textPrimary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive ? ForensicColors.neonGreen : ForensicColors.alertRed
            ),
          ),
          child: Text(
            status,
            style: GoogleFonts.shareTechMono(
              color: isActive ? ForensicColors.neonGreen : ForensicColors.alertRed,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
  }
}

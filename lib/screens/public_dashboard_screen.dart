import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/tactical_scaffold.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/glitch_text.dart';
import 'login_screen.dart';

class PublicDashboardScreen extends StatelessWidget {
  const PublicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      body: Column(
        children: [
          // ───────── HEADER ─────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ForensicColors.neonGreen.withOpacity(0.5), width: 1),
              ),
              color: Colors.black.withOpacity(0.6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlitchText(
                        "PUBLIC_ACCESS_TERMINAL_V2",
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ForensicColors.neonGreen,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "UNSECURED_CONNECTION :: MONITORING_ACTIVE",
                        style: GoogleFonts.shareTechMono(
                          fontSize: 12,
                          color: ForensicColors.alertRed,
                          letterSpacing: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.public_off, color: ForensicColors.alertRed, size: 32),
              ],
            ),
          ),

          // ───────── BODY ─────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GridView.count(
                crossAxisCount: 2, 
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.2,
                children: [
                  _buildRestrictedTile(context, "EXIF ANALYZER", Icons.saved_search),
                  _buildRestrictedTile(context, "METADATA EDITOR", Icons.edit_note),
                  _buildRestrictedTile(context, "FORENSIC REPORT", Icons.article),
                  _buildRestrictedTile(context, "EVIDENCE EXPORT", Icons.drive_file_move),
                  _buildRestrictedTile(context, "DEEP SCAN", Icons.radar),
                  _buildRestrictedTile(context, "SYSTEM LOGS", Icons.terminal),
                ],
              ),
            ),
          ),

          // ───────── FOOTER ─────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: ForensicColors.panelBackground,
              border: Border(top: BorderSide(color: ForensicColors.borderDim))
            ),
            child: Column(
              children: [
                Text(
                  "// AUTHENTICATION REQUIRED FOR ACCESS //",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_open, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          "> INITIATE_LOGIN_SEQUENCE",
                          style: GoogleFonts.shareTechMono(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedTile(BuildContext context, String title, IconData icon) {
    return CornerBracketContainer(
      color: ForensicColors.textSecondary.withOpacity(0.3),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: ForensicColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(
                  color: ForensicColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: ForensicColors.textSecondary.withOpacity(0.5)),
                  color: Colors.black,
                ),
                child: Text(
                  "LOCKED",
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: ForensicColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

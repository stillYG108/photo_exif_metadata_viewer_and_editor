import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/forensic_card.dart';
import '../widgets/crt_effect_container.dart';
import 'exif_analyzer_screen.dart';
import 'forensic_report_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CrtEffectContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Handled by parent
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Text(
                "AVAILABLE_MODULES",
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ForensicColors.greenPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85, // More vertical space
                  children: [
                    _buildModuleTile(
                      context,
                      "EXIF_ANALYZER",
                      "DECODES_METADATA",
                      Icons.image_search,
                      true,
                    ),
                    _buildModuleTile(
                      context,
                      "METADATA_EDITOR",
                      "MODIFIES_HEADERS",
                      Icons.edit_note,
                      true,
                    ),
                    _buildModuleTile(
                      context,
                      "FORENSIC_REPORT",
                      "VIEW_EXTRACTIONS",
                      Icons.folder_special,
                      true,
                    ),
                    _buildModuleTile(
                      context,
                      "EVIDENCE_EXPORT",
                      "SECURE_ARCHIVE",
                      Icons.inventory_2,
                      true,
                    ),
                    _buildModuleTile(
                      context,
                      "DEEP_SCAN",
                      "RECOVERS_DELETED",
                      Icons.radar,
                      false,
                    ),
                    _buildModuleTile(
                      context,
                      "NETWORK_TRACER",
                      "IP_ANALYSIS",
                      Icons.router,
                      false,
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

  Widget _buildModuleTile(BuildContext context, String title, String subtitle, IconData icon, bool isOnline) {
    final color = isOnline ? ForensicColors.greenPrimary : ForensicColors.textDim;
    
    return GestureDetector(
      onTap: isOnline ? () {
        // Navigate to respective screens
        if (title == "EXIF_ANALYZER") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExifAnalyzerScreen()),
          );
        } else if (title == "FORENSIC_REPORT") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForensicReportScreen()),
          );
        } else {
          // Show snackbar for other modules (not implemented yet)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "MODULE_ACTIVATED :: $title",
                style: GoogleFonts.shareTechMono(color: ForensicColors.greenPrimary),
              ),
              backgroundColor: ForensicColors.cardBackground,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } : null,
      child: ForensicCard(
        title: "MOD::${title.substring(0, 3)}",
        isWarning: !isOnline,
        compactPadding: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.shareTechMono(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.shareTechMono(
                  fontSize: 8,
                  color: color.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  isOnline ? "ONLINE" : "OFFLINE",
                  style: GoogleFonts.shareTechMono(
                    fontSize: 6,
                    color: color,
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

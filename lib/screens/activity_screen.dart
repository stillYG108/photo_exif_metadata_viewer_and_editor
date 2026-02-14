import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/scanning_effect.dart';
import '../widgets/glitch_text.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for now
    final logs = [
      {"time": "10:42:15", "event": "SESSION_INITIATED", "level": "INFO"},
      {"time": "10:43:02", "event": "ACCESSED_MODULE: EXIF_ANALYZER", "level": "INFO"},
      {"time": "10:45:11", "event": "FILE_UPLOAD: IMG_2024.JPG", "level": "WARN"},
      {"time": "10:45:12", "event": "SCAN_COMPLETE: 14_TAGS_FOUND", "level": "SUCCESS"},
      {"time": "10:48:20", "event": "EXPORTED_EVIDENCE: CASE_992", "level": "INFO"},
      {"time": "11:02:05", "event": "SYSTEM_CHECK_ROUTINE", "level": "INFO"},
    ];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   GlitchText(
                    "SYSTEM_AUDIT_LOG",
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ForensicColors.neonGreen,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: ForensicColors.alertRed,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "REC",
                        style: GoogleFonts.shareTechMono(
                          color: ForensicColors.alertRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
        
              Expanded(
                child: CornerBracketContainer(
                  color: ForensicColors.borderBright,
                  strokeWidth: 1,
                  padding: EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border(
                        left: BorderSide(color: ForensicColors.borderDim),
                        right: BorderSide(color: ForensicColors.borderDim),
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => Divider(
                        color: ForensicColors.gridLine, 
                        height: 24
                      ),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final color = _getColorForLevel(log['level']!);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Text(
                                "${log['time']} :: ",
                                style: GoogleFonts.shareTechMono(
                                  color: ForensicColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: color.withOpacity(0.5)),
                                  color: color.withOpacity(0.1),
                                ),
                                child: Text(
                                  log['level']!,
                                  style: GoogleFonts.shareTechMono(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  log['event']!,
                                  style: GoogleFonts.shareTechMono(
                                    color: ForensicColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Passive Scanning Overlay
        IgnorePointer(
          child: ScanningEffect(
            isScanning: true,
            scanColor: ForensicColors.neonGreen.withOpacity(0.2),
            child: Container(),
          ),
        ),
      ],
    );
  }

  Color _getColorForLevel(String level) {
    switch (level) {
      case 'WARN': return ForensicColors.warningAmber;
      case 'SUCCESS': return ForensicColors.neonGreen;
      case 'ERROR': return ForensicColors.alertRed;
      default: return ForensicColors.cyberCyan;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the color palette and theme data for the Forensic Workstation.
/// Updated for "Covert Ops / CIA Secret Mission" Aesthetic.
class ForensicColors {
  // Backgrounds - Deep, Void-like Blacks
  static const Color background = Color(0xFF030303); // Void Black
  static const Color panelBackground = Color(0xFF080808); // Tactical Panel
  static const Color cardBackground = Color(0xFF0C0C0C); // HUD Card

  // Primary High-Contrast Accents
  static const Color neonGreen = Color(0xFF00FF41); // Classic Terminal Green
  static const Color cyberCyan = Color(0xFF00F0FF); // Data Stream Cyan
  static const Color alertRed = Color(0xFFFF0033); // Critical Failure Red
  static const Color warningAmber = Color(0xFFFFB000); // System Warning

  // Functional Colors
  static const Color textPrimary = Color(0xFFE0E0E0); // High Readability Off-White
  static const Color textSecondary = Color(0xFF9E9E9E); // Dimmed Data
  static const Color borderDim = Color(0xFF222222); // Subtle Grid Lines
  static const Color borderBright = Color(0xFF444444); // Active Borders
  
  // Aliases for backward compatibility
  static const Color greenPrimary = neonGreen; // Alias for neonGreen
  static const Color textDim = textSecondary; // Alias for textSecondary
  static const Color alert = alertRed; // Alias for alertRed
  static const Color success = neonGreen; // Success state (green)
  
  // Tactical Overlays
  static final Color gridLine = neonGreen.withOpacity(0.05);
  static final Color scanLine = neonGreen.withOpacity(0.1);
}

class ForensicTheme {
  static ThemeData getTheme({Color primaryColor = ForensicColors.neonGreen}) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ForensicColors.background,
      primaryColor: primaryColor,
      canvasColor: ForensicColors.panelBackground, // For Drawers/Panels
      cardColor: ForensicColors.cardBackground,
      
      // Typography - Monospace "Share Tech Mono" for data, "Orbitron" for headers
      fontFamily: GoogleFonts.shareTechMono().fontFamily,
      textTheme: TextTheme(
        // Large Headers (e.g., "RESTRICTED ACCESS")
        displayLarge: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: primaryColor,
          letterSpacing: 4.0,
        ),
        // Screen Titles
        displayMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
        // Section Headers
        displaySmall: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          letterSpacing: 1.5,
        ),
        // Subtitles / Data Labels
        headlineMedium: GoogleFonts.shareTechMono(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ForensicColors.cyberCyan,
          letterSpacing: 1.2,
        ),
        // Standard Body Text
        bodyLarge: GoogleFonts.shareTechMono(
          fontSize: 15,
          color: ForensicColors.textPrimary,
          height: 1.4,
        ),
        // Smaller Data Text
        bodyMedium: GoogleFonts.shareTechMono(
          fontSize: 13,
          color: ForensicColors.textSecondary,
        ),
        // Button Text / Tags
        labelLarge: GoogleFonts.shareTechMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Dark text on bright buttons
          letterSpacing: 1.0,
        ),
      ),

      // Input Decoration (Terminal Command Line)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ForensicColors.panelBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: ForensicColors.borderDim),
          borderRadius: BorderRadius.zero, // Sharp corners
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ForensicColors.borderDim),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        labelStyle: TextStyle(color: ForensicColors.textSecondary),
        hintStyle: TextStyle(color: ForensicColors.textSecondary.withOpacity(0.5)),
        prefixStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),

      // Buttons (Tactical / Military Style)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black, // High contrast text
          elevation: 0,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ), // Angled "cut" corners
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: GoogleFonts.shareTechMono(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          shape: const BeveledRectangleBorder(
             borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.shareTechMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: primaryColor, size: 24),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: ForensicColors.borderDim,
        thickness: 1,
        space: 32,
      ),
      
      // Checkbox / Radio
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primaryColor;
          return null;
        }),
        checkColor: MaterialStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

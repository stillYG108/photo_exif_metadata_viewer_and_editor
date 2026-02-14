import 'package:flutter/material.dart';
import 'color_constants.dart';

/// Classic Forensic Lab Theme
ThemeData getClassicForensicTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorConstants.bgPrimary,
    primaryColor: ColorConstants.forensicGreen,
    fontFamily: 'Courier New',
    useMaterial3: false,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorConstants.bgTertiary,
      foregroundColor: ColorConstants.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ColorConstants.textPrimary,
        letterSpacing: 1.5,
      ),
    ),
    
    // Card Theme
    cardTheme: const CardThemeData(
      color: ColorConstants.bgSecondary,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: ColorConstants.borderPrimary,
          width: 2,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: ColorConstants.bgSecondary,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorConstants.borderSecondary,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorConstants.borderSecondary,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorConstants.borderPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorConstants.textError,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Courier New',
        color: ColorConstants.textSecondary,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Courier New',
        color: ColorConstants.textTertiary,
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ColorConstants.textPrimary,
        letterSpacing: 2.0,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorConstants.textPrimary,
        letterSpacing: 1.5,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 14,
        color: ColorConstants.textPrimary,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 12,
        color: ColorConstants.textSecondary,
        letterSpacing: 0.5,
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: ColorConstants.textPrimary,
      size: 20,
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: ColorConstants.borderInactive,
      thickness: 1,
    ),
  );
}

/// DOS Terminal Theme
ThemeData getDosTerminalTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorConstants.dosBackground,
    primaryColor: ColorConstants.dosWhite,
    fontFamily: 'Courier New',
    useMaterial3: false,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0000AA),
      foregroundColor: ColorConstants.dosWhite,
      elevation: 0,
    ),
    
    cardTheme: const CardThemeData(
      color: Color(0xFF000055),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: ColorConstants.dosWhite,
          width: 2,
        ),
      ),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 14,
        color: ColorConstants.dosWhite,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 12,
        color: ColorConstants.dosCyan,
      ),
    ),
  );
}

/// Intelligence Agency Console Theme
ThemeData getIntelligenceAgencyTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorConstants.intelBackground,
    primaryColor: ColorConstants.intelBlue,
    fontFamily: 'Courier New',
    useMaterial3: false,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000066),
      foregroundColor: ColorConstants.intelBlue,
      elevation: 0,
    ),
    
    cardTheme: const CardThemeData(
      color: Color(0xFF000044),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: ColorConstants.intelBlue,
          width: 2,
        ),
      ),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 14,
        color: ColorConstants.intelBlue,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 12,
        color: Color(0xFF0099FF),
      ),
    ),
  );
}

/// Cyber Investigation Workstation Theme
ThemeData getCyberInvestigationTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorConstants.cyberBackground,
    primaryColor: ColorConstants.cyberNeon,
    fontFamily: 'Courier New',
    useMaterial3: false,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E0028),
      foregroundColor: ColorConstants.cyberNeon,
      elevation: 0,
    ),
    
    cardTheme: const CardThemeData(
      color: Color(0xFF14001E),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: ColorConstants.cyberNeon,
          width: 2,
        ),
      ),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 14,
        color: ColorConstants.cyberNeon,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 12,
        color: ColorConstants.cyberCyan,
      ),
    ),
  );
}

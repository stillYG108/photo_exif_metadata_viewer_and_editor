import 'package:flutter/material.dart';

/// Typography system for forensic themes
class ForensicTypography {
  static const String primaryFont = 'Courier New';
  static const String secondaryFont = 'Consolas';
  static const String terminalFont = 'monospace';
  
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeXS = 10.0;
  
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  
  static TextStyle header1(Color color) => TextStyle(
    fontFamily: primaryFont,
    fontSize: fontSizeXXL,
    fontWeight: fontWeightBold,
    color: color,
    letterSpacing: 2.0,
  );
  
  static TextStyle header2(Color color) => TextStyle(
    fontFamily: primaryFont,
    fontSize: fontSizeXL,
    fontWeight: fontWeightBold,
    color: color,
    letterSpacing: 1.5,
  );
  
  static TextStyle body(Color color) => TextStyle(
    fontFamily: primaryFont,
    fontSize: fontSizeMD,
    fontWeight: fontWeightRegular,
    color: color,
    letterSpacing: 0.5,
  );
  
  static TextStyle caption(Color color) => TextStyle(
    fontFamily: primaryFont,
    fontSize: fontSizeSM,
    fontWeight: fontWeightRegular,
    color: color,
    letterSpacing: 0.5,
  );
  
  static TextStyle terminal(Color color) => TextStyle(
    fontFamily: terminalFont,
    fontSize: fontSizeMD,
    fontWeight: fontWeightRegular,
    color: color,
    letterSpacing: 1.0,
    height: 1.5,
  );
}

/// Spacing constants
class ForensicSpacing {
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  
  static const double borderThin = 1.0;
  static const double borderMedium = 2.0;
  static const double borderThick = 3.0;
  
  static const double radiusNone = 0.0;
  static const double radiusSmall = 2.0;
  static const double radiusMedium = 4.0;
}

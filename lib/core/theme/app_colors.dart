import 'package:flutter/material.dart';
//X

class AppColors {
  static const Color primary = Color(0xFFD4AF37);
  static const Color accent = Color(0xFFF3E5AB);
  static const Color background = Color(0xFF0D0E15);
  static const Color surface = Color(0xFF161824);
  static const Color cardBg = Color(0xFF1F2233);
  static const Color cardBackground = Color(0xFF1F2233);
  static const Color border = Color(0xFF2E334D);

  static const Color primaryNeon = Color(0xFFD4AF37);
  static const Color secondaryNeon = Color(0xFF457B9D);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color gold = Color(0xFFD4AF37);

  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFFAA7C11);

  static const Color teamRed = Color(0xFFE63946);
  static const Color teamBlue = Color(0xFF457B9D);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF3E5AB), Color(0xFFD4AF37), Color(0xFFAA7C11)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF457B9D), Color(0xFF1D3557)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF3E5AB), Color(0xFFD4AF37), Color(0xFFAA7C11)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF25293E), Color(0xFF1A1D2C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryNeonBlue,
      cardColor: AppColors.cardBackground,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16.0,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14.0,
          color: AppColors.textSecondary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primaryNeonBlue,
      ),
    );
  }
}
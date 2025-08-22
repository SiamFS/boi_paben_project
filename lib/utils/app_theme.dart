import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8A65);
  static const Color darkGray = Color(0xFF2C2C2C);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color textGray = Color(0xFF666666);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFE53E3E);
  static const Color green = Color(0xFF38A169);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(0xFFFF6B35, {
        50: Color(0xFFFFE8E0),
        100: Color(0xFFFFCCB3),
        200: Color(0xFFFFAD80),
        300: Color(0xFFFF8E4D),
        400: Color(0xFFFF7A26),
        500: Color(0xFFFF6B35),
        600: Color(0xFFFF5722),
        700: Color(0xFFE64A19),
        800: Color(0xFFCC3D00),
        900: Color(0xFFB32A00),
      }),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryOrange,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightGray,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textGray.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textGray.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: GoogleFonts.poppins(color: AppColors.textGray),
        hintStyle: GoogleFonts.poppins(color: AppColors.textGray.withOpacity(0.7)),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
}

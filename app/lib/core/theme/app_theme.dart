import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const bgDeepest = Color(0xFF06051A);
  static const bgDark = Color(0xFF0D0B2A);
  static const bgMid = Color(0xFF141240);
  static const bgCard = Color(0xFF1C1A4E);
  static const bgElevated = Color(0xFF252364);

  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFA78BFA);
  static const purpleDark = Color(0xFF5B21B6);

  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFF4ADE80);
  static const orange = Color(0xFFF59E0B);
  static const orangeLight = Color(0xFFFCD34D);
  static const red = Color(0xFFEF4444);
  static const redDark = Color(0xFF991B1B);
  static const blue = Color(0xFF1D4ED8);
  static const blueDark = Color(0xFF1E3A8A);

  static const text = Color(0xFFEEEEFF);
  static const textSoft = Color(0xFFC4B5FD);
  static const textMuted = Color(0xFF7870A8);
  static const border = Color(0xFF2A275F);
  static const borderLight = Color(0xFF3D3890);
}

abstract final class AppText {
  static TextStyle heading({
    double size = 22,
    Color color = AppColors.text,
    FontWeight weight = FontWeight.w700,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) => GoogleFonts.fredoka(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    shadows: shadows,
  );

  static TextStyle body({
    double size = 14,
    Color color = AppColors.textSoft,
    FontWeight weight = FontWeight.w600,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) => GoogleFonts.nunito(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgDeepest,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.green,
      surface: AppColors.bgCard,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}

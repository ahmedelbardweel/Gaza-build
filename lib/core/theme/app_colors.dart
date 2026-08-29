import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Identity Palette (Gaza Architectural Golden Amber)
  static const primary = Color(0xFFFFBD17);
  static const primaryDark = Color(0xDDFBBF24);
  static const primaryLight = Color(0xC3FBBF24);
  static const primaryContainer = Color(0x30FBBF24);
  static const onPrimary = Color(0xFF000000);

  // Secondary & Accents (Warm Ochre / Sandstone Heritage)
  static const secondary = Color(0xFFD97706);
  static const secondaryDark = Color(0xFFB45309);
  static const secondaryLight = Color(0xFFFBBF24);
  static const secondaryContainer = Color(0xFFFEF3C7);
  static const onSecondary = Color(0xFFFFFFFF);

  // Role Color Accents
  static const clientRole = Color(0xFFFFB800);
  static const engineerRole = Color(0xFFFFB800);
  static const syndicateRole = Color(0xFFFFB800);
  static const studentRole = Color(0xFFFFB800);

  // Light Background & Surfaces
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const surfaceElevated = Color(0xFFFFFFFF);

  // Pure True Black Dark Background & Surfaces (Pure AMOLED / Deep Black, No Navy/Blue Tint)
  static const darkBackground = Color(0xFF000000); // True Pure Black
  static const darkSurface = Color(0xFF121212); // Deep Charcoal Card Surface
  static const darkSurfaceVariant = Color(0xFF1E1E1E); // Elevated Container
  static const darkSurfaceElevated = Color(0xFF262626);

  // Light Text & Content
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textMuted = Color(0xFF94A3B8); // Slate 400
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Dark Text & Content (Neutral Crisp Gray & White)
  static const darkTextPrimary = Color(0xFFFFFFFF); // Pure White
  static const darkTextSecondary = Color(0xFFA1A1AA); // Neutral Zinc 400
  static const darkTextMuted = Color(0xFF71717A); // Neutral Zinc 500

  // Light Borders & Dividers
  static const border = Color(0xFFE2E8F0);
  static const borderFocused = Color(0xFFFBCE40);
  static const borderLight = Color(0xFFF1F5F9);

  // Dark Borders & Dividers (Neutral Dark Gray)
  static const darkBorder = Color(0xFF27272A); // Zinc 800
  static const darkBorderLight = Color(0xFF1E1E1E);

  // Status & Feedback (Light)
  static const success = Color(0xFF16A34A);
  static const successContainer = Color(0xFFDCFCE7);
  static const warning = Color(0xFFEAB308);
  static const warningContainer = Color(0xFFFEF9C3);
  static const error = Color(0xFFDC2626);
  static const errorContainer = Color(0xFFFEE2E2);
  static const info = Color(0xFF0284C7);
  static const infoContainer = Color(0xFFE0F2FE);

  // Status Containers (Dark)
  static const darkSuccessContainer = Color(0xFF0D2818);
  static const darkWarningContainer = Color(0xFF2A2004);
  static const darkErrorContainer = Color(0xFF2B0E0E);
  static const darkInfoContainer = Color(0xFF0A2239);
  static const darkPrimaryContainer = Color(0xFF2E2204);

  // Verification Status Colors
  static const verified = Color(0xFF16A34A);
  static const pending = Color(0xFFD97706);
  static const rejected = Color(0xFFDC2626);
  static const unsubmitted = Color(0xFF64748B);

  // Dynamic helper methods
  static Color getBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : background;

  static Color getSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color getSurfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceVariant : surfaceVariant;

  static Color getTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textPrimary;

  static Color getTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;

  static Color getTextMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextMuted : textMuted;

  static Color getBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;
}

extension AppThemeContextExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get themeBackground => AppColors.getBackground(this);
  Color get themeSurface => AppColors.getSurface(this);
  Color get themeSurfaceVariant => AppColors.getSurfaceVariant(this);
  Color get themeTextPrimary => AppColors.getTextPrimary(this);
  Color get themeTextSecondary => AppColors.getTextSecondary(this);
  Color get themeTextMuted => AppColors.getTextMuted(this);
  Color get themeBorder => AppColors.getBorder(this);
}

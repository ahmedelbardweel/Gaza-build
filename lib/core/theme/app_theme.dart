import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  // Global corner radius constant - strictly 3.0 across the whole app
  static const double borderRadiusValue = 3.0;
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(borderRadiusValue));
  static const RoundedRectangleBorder roundedShape = RoundedRectangleBorder(borderRadius: borderRadius);

  static ThemeData get light {
    final baseTextTheme = GoogleFonts.tajawalTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.error,
        outline: AppColors.border,
        surfaceContainerHighest: AppColors.surfaceVariant,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
          fontSize: 11,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleSpacing: 10,
        titleTextStyle: GoogleFonts.tajawal(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: roundedShape,
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          shape: roundedShape,
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: roundedShape,
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.tajawal(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.tajawal(
          color: AppColors.textMuted,
          fontSize: 13,
        ),
      ),

      chipTheme: ChipThemeData(
        shape: roundedShape,
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 4,
        shape: roundedShape,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ),

      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        dividerHeight: 0.0,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get dark {
    final baseTextTheme = GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground, // Pure Black 0xFF000000
      cardColor: AppColors.darkSurface, // Deep Charcoal 0xFF121212
      dividerColor: AppColors.darkBorder, // Neutral dark border 0xFF27272A
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: Colors.black,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.darkWarningContainer,
        onSecondaryContainer: AppColors.secondaryLight,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.darkErrorContainer,
        onErrorContainer: AppColors.error,
        outline: AppColors.darkBorder,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.darkTextMuted,
          fontSize: 11,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        centerTitle: false,
        titleSpacing: 10,
        titleTextStyle: GoogleFonts.tajawal(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: roundedShape,
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          shape: roundedShape,
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: roundedShape,
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.tajawal(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.tajawal(
          color: AppColors.darkTextMuted,
          fontSize: 13,
        ),
      ),

      chipTheme: ChipThemeData(
        shape: roundedShape,
        side: const BorderSide(color: AppColors.darkBorder),
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.darkPrimaryContainer,
        labelStyle: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 4,
        shape: roundedShape,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ),

      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        dividerHeight: 0.0,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

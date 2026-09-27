import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _displayFont = 'Bricolage Grotesque';
  static const _bodyFont = 'Instrument Sans';

  /// Headline style used for screen titles and big numbers.
  static TextStyle display(double size, {Color color = AppColors.ink}) {
    return GoogleFonts.getFont(
      _displayFont,
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02 * size,
      height: 1.05,
      color: color,
    );
  }

  /// Small uppercase label, like course codes and card captions.
  static TextStyle eyebrow({Color color = AppColors.blue, double size = 12}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.05 * size,
      color: color,
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
    final textTheme = GoogleFonts.getTextTheme(_bodyFont, base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.blue,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.placeholder),
        border: border(AppColors.inputBorder),
        enabledBorder: border(AppColors.inputBorder),
        focusedBorder: border(AppColors.blue, 1.6),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 1.6),
        errorStyle: const TextStyle(color: AppColors.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        extendedTextStyle:
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.tint,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.blue : AppColors.subtle,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.blue : AppColors.subtle,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

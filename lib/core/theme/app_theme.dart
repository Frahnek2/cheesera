import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkroomBackground,
      primaryColor: AppColors.amberAccent,
      canvasColor: AppColors.surfaceDark,
      cardColor: AppColors.surfaceElevated,
      dividerColor: AppColors.surfaceBorder,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkroomBackground,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amberAccent,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}

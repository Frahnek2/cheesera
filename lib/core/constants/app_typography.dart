import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Clean, Swiss-inspired typography with analog camera cues.
class AppTypography {
  AppTypography._();

  static const TextStyle brandLogo = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 3.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle filmHeadline = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle filmSubhead = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  static const TextStyle filmMetadata = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    fontFamily: 'Courier',
    color: AppColors.amberAccent,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle knobValue = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    fontFamily: 'Courier',
    color: AppColors.textPrimary,
  );
}

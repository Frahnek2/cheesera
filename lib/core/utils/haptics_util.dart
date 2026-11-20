import 'package:flutter/services.dart';

/// Provides tactile micro-haptic feedback matching analog dials and camera clicks.
class HapticsUtil {
  HapticsUtil._();

  /// Subtle click for slider ticks, stepping, and dial rotation.
  static void selectionTick() {
    HapticFeedback.selectionClick();
  }

  /// Light mechanical snap when switching presets or locking into neutral.
  static void lightSnap() {
    HapticFeedback.lightImpact();
  }

  /// Medium mechanical shutter / shutter press feel.
  static void shutterClick() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact when successfully exporting or completing a major action.
  static void heavyAffirmation() {
    HapticFeedback.heavyImpact();
  }
}

import 'package:flutter/services.dart';

/// Provides tactile micro-haptic feedback matching analog dials and camera clicks.
/// All calls are silently no-op when platform channels are unavailable (e.g. unit tests).
class HapticsUtil {
  HapticsUtil._();

  /// Subtle click for slider ticks, stepping, and dial rotation.
  static void selectionTick() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Light mechanical snap when switching presets or locking into neutral.
  static void lightSnap() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium mechanical shutter / shutter press feel.
  static void shutterClick() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy impact when successfully exporting or completing a major action.
  static void heavyAffirmation() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}

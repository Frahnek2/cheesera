import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects device shake gestures for agitating chemical development tanks.
/// Gracefully falls back on platforms or devices without accelerometer hardware.
class ShakeDetector {
  final VoidCallback onShake;
  final double shakeThresholdGravity;
  final int minShakeIntervalMs;

  StreamSubscription? _subscription;
  int _lastShakeTimestamp = 0;

  ShakeDetector({
    required this.onShake,
    this.shakeThresholdGravity = 2.4, // Sensitivity threshold in G-force
    this.minShakeIntervalMs = 600, // Cooldown between shake triggers
  });

  /// Starts listening to device accelerometer events.
  void start() {
    try {
      _subscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final double gX = event.x / 9.80665;
          final double gY = event.y / 9.80665;
          final double gZ = event.z / 9.80665;

          final double gForce = math.sqrt(gX * gX + gY * gY + gZ * gZ);

          if (gForce > shakeThresholdGravity) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - _lastShakeTimestamp > minShakeIntervalMs) {
              _lastShakeTimestamp = now;
              onShake();
            }
          }
        },
        onError: (err) {
          // Sensor unavailable (e.g. on simulator or desktop)
        },
        cancelOnError: true,
      );
    } catch (_) {
      // Platform does not support sensors_plus
    }
  }

  /// Stops listening.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}

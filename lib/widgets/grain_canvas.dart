import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders real-time procedural film grain over the live editor preview.
class GrainCanvas extends StatelessWidget {
  final double amount;
  final double size;
  final Widget child;

  const GrainCanvas({
    super.key,
    required this.amount,
    this.size = 1.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (amount <= 0.01) return child;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _FilmGrainPainter(
                grainAmount: amount,
                grainScale: size,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilmGrainPainter extends CustomPainter {
  final double grainAmount;
  final double grainScale;

  _FilmGrainPainter({
    required this.grainAmount,
    required this.grainScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(1337);
    final paint = Paint()..style = PaintingStyle.fill;

    // Distribute simulated silver halide grains across canvas
    final int count = (size.width * size.height * 0.0018 * grainAmount).round().clamp(100, 2500);
    final double radius = 0.8 * grainScale;

    for (int i = 0; i < count; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double opacity = (random.nextDouble() * 0.35 + 0.05) * grainAmount;

      // Half dark grains, half light silver flecks
      if (random.nextBool()) {
        paint.color = Colors.black.withOpacity(opacity.clamp(0.0, 1.0));
      } else {
        paint.color = Colors.white.withOpacity((opacity * 0.6).clamp(0.0, 1.0));
      }

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FilmGrainPainter oldDelegate) {
    return oldDelegate.grainAmount != grainAmount || oldDelegate.grainScale != grainScale;
  }
}

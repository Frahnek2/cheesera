import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Generates realistic synthetic photographic bitmaps entirely in code.
/// This ensures Cheesera works 100% out-of-the-box without requiring any external
/// image files, internet connection, or bundled assets.
class SampleImagesData {
  SampleImagesData._();

  static Uint8List? _cachedGoldenCoast;
  static Uint8List? _cachedMidnightNeon;
  static Uint8List? _cachedStudioPortrait;

  /// Golden Hour Coastal Sunset (rich warm tones, ideal for Portra / Gold 200).
  static Uint8List getGoldenCoast({int width = 720, int height = 960}) {
    if (_cachedGoldenCoast != null) return _cachedGoldenCoast!;
    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      final double ny = y / height;
      for (int x = 0; x < width; x++) {
        final double nx = x / width;

        int r, g, b;
        if (ny < 0.60) {
          // Sunset sky gradient: deep indigo -> burnt orange -> golden yellow
          final double t = ny / 0.60;
          r = (180 + t * 75).clamp(0, 255).toInt();
          g = (70 + t * 110 + (nx - 0.5).abs() * 20).clamp(0, 255).toInt();
          b = (110 - t * 80).clamp(0, 255).toInt();

          // Sun disc at (0.6, 0.45)
          final double dx = nx - 0.58;
          final double dy = ny - 0.42;
          final double dist = math.sqrt(dx * dx + dy * dy);
          if (dist < 0.12) {
            final double glow = (1.0 - (dist / 0.12));
            r = (r + glow * 120).clamp(0, 255).toInt();
            g = (g + glow * 90).clamp(0, 255).toInt();
            b = (b + glow * 30).clamp(0, 255).toInt();
          }
        } else {
          // Ocean water with sunlight specular streak
          final double t = (ny - 0.60) / 0.40;
          r = (50 + (1.0 - t) * 110).clamp(0, 255).toInt();
          g = (65 + (1.0 - t) * 75).clamp(0, 255).toInt();
          b = (75 + (1.0 - t) * 40).clamp(0, 255).toInt();

          // Sunlight reflection column
          final double dx = (nx - 0.58).abs();
          if (dx < 0.16) {
            final double shimmer = (1.0 - dx / 0.16) * math.sin(y * 0.8) * 0.5 + 0.5;
            final double intensity = shimmer * (1.0 - t * 0.6) * 110;
            r = (r + intensity).clamp(0, 255).toInt();
            g = (g + intensity * 0.85).clamp(0, 255).toInt();
            b = (b + intensity * 0.4).clamp(0, 255).toInt();
          }
        }

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    _cachedGoldenCoast = Uint8List.fromList(img.encodeJpg(image, quality: 90));
    return _cachedGoldenCoast!;
  }

  /// Midnight Neon (cool cyan shadows with incandescent lights, ideal for CineStill 800T).
  static Uint8List getMidnightNeon({int width = 720, int height = 960}) {
    if (_cachedMidnightNeon != null) return _cachedMidnightNeon!;
    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      final double ny = y / height;
      for (int x = 0; x < width; x++) {
        final double nx = x / width;

        // Dark moody urban atmosphere
        int r = (12 + (1.0 - ny) * 18).toInt();
        int g = (18 + (1.0 - ny) * 24).toInt();
        int b = (32 + (1.0 - ny) * 45).toInt();

        // Neon sign red/orange glow at top left
        final double dNeon1 = math.sqrt(math.pow(nx - 0.25, 2) + math.pow(ny - 0.35, 2));
        if (dNeon1 < 0.35) {
          final double intensity = (1.0 - dNeon1 / 0.35);
          r = (r + intensity * 210).clamp(0, 255).toInt();
          g = (g + intensity * 40).clamp(0, 255).toInt();
          b = (b + intensity * 70).clamp(0, 255).toInt();
        }

        // Cyan accent glow at bottom right
        final double dNeon2 = math.sqrt(math.pow(nx - 0.78, 2) + math.pow(ny - 0.65, 2));
        if (dNeon2 < 0.40) {
          final double intensity = (1.0 - dNeon2 / 0.40);
          r = (r + intensity * 25).clamp(0, 255).toInt();
          g = (g + intensity * 165).clamp(0, 255).toInt();
          b = (b + intensity * 200).clamp(0, 255).toInt();
        }

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    _cachedMidnightNeon = Uint8List.fromList(img.encodeJpg(image, quality: 90));
    return _cachedMidnightNeon!;
  }

  /// Studio Monochrome / Fine Art (smooth gradients, ideal for Tri-X 400 & Ilford HP5).
  static Uint8List getStudioPortrait({int width = 720, int height = 960}) {
    if (_cachedStudioPortrait != null) return _cachedStudioPortrait!;
    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      final double ny = y / height;
      for (int x = 0; x < width; x++) {
        final double nx = x / width;

        // Radial studio key light from upper right
        final double dx = nx - 0.70;
        final double dy = ny - 0.30;
        final double dist = math.sqrt(dx * dx + dy * dy);
        final double light = (1.0 - dist.clamp(0.0, 1.0));

        // Subtle warm vignette
        final double base = (40 + light * 150).clamp(0, 255);
        final int r = (base * 1.05).clamp(0, 255).toInt();
        final int g = base.toInt();
        final int b = (base * 0.92).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, r, g, b);
      }
    }

    _cachedStudioPortrait = Uint8List.fromList(img.encodeJpg(image, quality: 90));
    return _cachedStudioPortrait!;
  }
}

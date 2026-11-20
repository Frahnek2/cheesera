import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'llm_models.dart';

/// Fast, purely on-device photographic feature & histogram extractor.
/// Samples pixel grids to determine lighting, warmth, contrast, and dominant hues.
class ImageFeatureExtractor {
  ImageFeatureExtractor._();

  /// Analyzes image bytes and returns structured [ImageAnalysisMetadata].
  static ImageAnalysisMetadata analyze(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      return const ImageAnalysisMetadata(
        averageLuminance: 0.5,
        colorTemperatureK: 5500,
        warmthScore: 0.0,
        contrastRatio: 0.5,
        saturationLevel: 0.5,
        lightingAtmosphere: 'Daylight Neutral',
        dominantTones: ['Neutral Midtones'],
      );
    }

    final int width = image.width;
    final int height = image.height;

    // Subsample grid (e.g. 32x32 samples for lightning fast 2ms execution)
    const int sampleSteps = 32;
    final int stepX = math.max(1, width ~/ sampleSteps);
    final int stepY = math.max(1, height ~/ sampleSteps);

    double totalLum = 0.0;
    double totalWarmth = 0.0;
    double totalSat = 0.0;
    double minLum = 1.0;
    double maxLum = 0.0;
    int sampleCount = 0;

    int warmPixelCount = 0;
    int coolPixelCount = 0;
    int skinToneCount = 0;

    for (int y = 0; y < height; y += stepY) {
      for (int x = 0; x < width; x += stepX) {
        final pixel = image.getPixel(x, y);

        final double r = pixel.r / 255.0;
        final double g = pixel.g / 255.0;
        final double b = pixel.b / 255.0;

        // Rec. 709 relative luminance
        final double lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        totalLum += lum;
        if (lum < minLum) minLum = lum;
        if (lum > maxLum) maxLum = lum;

        // Warmth: red vs blue differential
        final double warmth = r - b;
        totalWarmth += warmth;
        if (warmth > 0.15) warmPixelCount++;
        if (warmth < -0.15) coolPixelCount++;

        // Saturation estimation (max - min) / max
        final double maxC = math.max(r, math.max(g, b));
        final double minC = math.min(r, math.min(g, b));
        final double sat = maxC > 0 ? (maxC - minC) / maxC : 0;
        totalSat += sat;

        // Skin tone heuristic: R > G > B, moderate saturation, warm hue
        if (r > g && g > b && sat > 0.15 && sat < 0.65 && lum > 0.25 && lum < 0.85) {
          skinToneCount++;
        }

        sampleCount++;
      }
    }

    if (sampleCount == 0) sampleCount = 1;

    final double avgLum = (totalLum / sampleCount).clamp(0.0, 1.0);
    final double avgWarmth = (totalWarmth / sampleCount).clamp(-1.0, 1.0);
    final double avgSat = (totalSat / sampleCount).clamp(0.0, 1.0);
    final double contrast = (maxLum - minLum).clamp(0.0, 1.0);

    // Estimate color temperature in Kelvin (2500K to 9500K)
    final double kelvin = 5500.0 - (avgWarmth * 3000.0);

    // Classify lighting atmosphere
    String atmosphere;
    final List<String> dominantTones = [];

    if (avgLum < 0.25 && coolPixelCount > warmPixelCount) {
      atmosphere = 'Night / Moody Tungsten';
      dominantTones.add('Teal Shadows');
      dominantTones.add('Low-Key Ambient');
    } else if (avgWarmth > 0.20 && avgLum > 0.40) {
      atmosphere = 'Golden Hour / Sunset';
      dominantTones.add('Warm Amber Highlights');
      dominantTones.add('Golden Skin Tones');
    } else if (contrast > 0.75) {
      atmosphere = 'High Contrast Architectural';
      dominantTones.add('Deep Blacks');
      dominantTones.add('Specular Highlights');
    } else if (skinToneCount > sampleCount * 0.20) {
      atmosphere = 'Portrait / Studio Soft';
      dominantTones.add('Natural Skin Tones');
      dominantTones.add('Gentle Highlight Roll-Off');
    } else if (avgSat < 0.15) {
      atmosphere = 'Monochrome / Low Saturation';
      dominantTones.add('Silvery Greys');
    } else {
      atmosphere = 'Natural Daylight Documentary';
      dominantTones.add('Balanced Midtones');
    }

    return ImageAnalysisMetadata(
      averageLuminance: avgLum,
      colorTemperatureK: kelvin,
      warmthScore: avgWarmth,
      contrastRatio: contrast,
      saturationLevel: avgSat,
      lightingAtmosphere: atmosphere,
      dominantTones: dominantTones,
    );
  }
}

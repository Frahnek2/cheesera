import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageAnalysisResult {
  final List<String> tags;
  final double brightness;
  final double contrast;
  final double colorTemperature;
  final double saturation;

  ImageAnalysisResult({
    required this.tags,
    required this.brightness,
    required this.contrast,
    required this.colorTemperature,
    required this.saturation,
  });
}

class ImageAnalyzer {
  /// Analyzes an image and extracts aesthetic tags based on image characteristics
  static Future<ImageAnalysisResult> analyzeImage(Uint8List imageBytes) async {
    // Decode the image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate image characteristics
    final brightness = _calculateBrightness(image);
    final contrast = _calculateContrast(image);
    final colorTemp = _calculateColorTemperature(image);
    final saturation = _calculateSaturation(image);

    // Generate tags based on characteristics
    final tags = _generateTags(brightness, contrast, colorTemp, saturation);

    return ImageAnalysisResult(
      tags: tags,
      brightness: brightness,
      contrast: contrast,
      colorTemperature: colorTemp,
      saturation: saturation,
    );
  }

  /// Calculate average brightness of the image (0.0 to 1.0)
  static double _calculateBrightness(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        // Convert to luminance
        final brightness = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);
        totalBrightness += brightness.toInt();
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalBrightness / pixelCount / 255.0 : 0.5;
  }

  /// Calculate contrast of the image (0.0 to 1.0)
  static double _calculateContrast(img.Image image) {
    List<int> brightnessValues = [];

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final brightness = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);
        brightnessValues.add(brightness.toInt());
      }
    }

    if (brightnessValues.isEmpty) return 0.5;

    brightnessValues.sort();
    final minBrightness = brightnessValues.first;
    final maxBrightness = brightnessValues.last;

    return (maxBrightness - minBrightness) / 255.0;
  }

  /// Calculate color temperature (warm vs cool, -1.0 to 1.0)
  static double _calculateColorTemperature(img.Image image) {
    int redTotal = 0;
    int blueTotal = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        redTotal += pixel.r.toInt();
        blueTotal += pixel.b.toInt();
        pixelCount++;
      }
    }

    if (pixelCount == 0) return 0.0;

    final avgRed = redTotal / pixelCount;
    final avgBlue = blueTotal / pixelCount;

    // Positive = warm (more red), Negative = cool (more blue)
    return (avgRed - avgBlue) / 255.0;
  }

  /// Calculate saturation (0.0 to 1.0)
  static double _calculateSaturation(img.Image image) {
    double totalSaturation = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final max = [pixel.r, pixel.g, pixel.b].reduce((a, b) => a > b ? a : b);
        final min = [pixel.r, pixel.g, pixel.b].reduce((a, b) => a < b ? a : b);
        
        if (max == 0) {
          totalSaturation += 0;
        } else {
          totalSaturation += (max - min) / max;
        }
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalSaturation / pixelCount : 0.5;
  }

  /// Generate aesthetic tags based on image characteristics
  static List<String> _generateTags(
    double brightness,
    double contrast,
    double colorTemp,
    double saturation,
  ) {
    List<String> tags = [];

    // Brightness-based tags
    if (brightness < 0.3) {
      tags.add('dark');
      tags.add('moody');
    } else if (brightness > 0.7) {
      tags.add('bright');
      tags.add('airy');
    } else {
      tags.add('balanced');
    }

    // Contrast-based tags
    if (contrast < 0.3) {
      tags.add('low contrast');
      tags.add('soft');
    } else if (contrast > 0.6) {
      tags.add('high contrast');
      tags.add('dramatic');
    }

    // Color temperature-based tags
    if (colorTemp > 0.15) {
      tags.add('warm');
      tags.add('golden hour');
    } else if (colorTemp < -0.15) {
      tags.add('cool');
      tags.add('blue hour');
    }

    // Saturation-based tags
    if (saturation < 0.3) {
      tags.add('desaturated');
      tags.add('muted');
    } else if (saturation > 0.7) {
      tags.add('vibrant');
      tags.add('saturated');
    }

    // Combination tags
    if (brightness < 0.4 && contrast > 0.5) {
      tags.add('moody urban');
    }
    
    if (colorTemp > 0.1 && brightness > 0.5) {
      tags.add('golden hour');
    }

    if (contrast > 0.5 && brightness < 0.6) {
      tags.add('cinematic');
    }

    if (saturation < 0.4 && contrast < 0.4) {
      tags.add('vintage');
      tags.add('film look');
    }

    // Ensure we have at least some tags
    if (tags.isEmpty) {
      tags.add('natural');
      tags.add('everyday');
    }

    return tags;
  }
}

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';
import 'color_matrix_utils.dart';
import 'cube_lut.dart';
import 'cube_lut_parser.dart';
import 'lut_processor.dart';

/// The core image rendering engine for Cheesera.
/// Coordinates real-time GPU matrix transforms, 3D LUT processing,
/// analog grain synthesis, vignette, and high-resolution export.
class FilmEngine {
  final LutProcessor lutProcessor;

  FilmEngine({
    LutProcessor? lutProcessor,
  }) : lutProcessor = lutProcessor ?? const DefaultLutProcessor();

  /// Returns real-time GPU ColorFilter matrix for instantaneous UI response.
  List<double> getPreviewColorMatrix(FilmRecipe recipe) {
    return ColorMatrixUtils.calculateMatrix(recipe);
  }

  /// Parses external .cube LUT file bytes and returns a [Lut3D].
  Lut3D parseCubeLut(Uint8List cubeFileBytes) {
    return CubeLutParser.parseBytes(cubeFileBytes);
  }

  /// Renders a full-resolution processed photo ready for export to camera roll.
  /// Runs inside compute/isolate if requested or directly on background threads.
  Future<Uint8List> renderFullResolution({
    required Uint8List sourceBytes,
    required FilmRecipe recipe,
    FrameRatio frameRatio = FrameRatio.ratio4_5,
    bool addAnalogFrame = false,
  }) async {
    return compute(_renderPipeline, {
      'sourceBytes': sourceBytes,
      'matrix': ColorMatrixUtils.calculateMatrix(recipe),
      'grainAmount': recipe.grainAmount,
      'grainSize': recipe.grainSize,
      'vignette': recipe.vignette,
      'fade': recipe.fade,
      'aspectRatio': frameRatio.aspectRatio,
      'addAnalogFrame': addAnalogFrame,
      'filmName': recipe.preset.name,
      'iso': recipe.preset.iso,
    });
  }

  /// Top-level isolate execution function
  static Uint8List _renderPipeline(Map<String, dynamic> params) {
    final Uint8List sourceBytes = params['sourceBytes'];
    final List<double> matrix = (params['matrix'] as List).cast<double>();
    final double grainAmount = params['grainAmount'];
    final double grainSize = params['grainSize'];
    final double vignette = params['vignette'];
    final double aspectRatio = params['aspectRatio'];
    final bool addAnalogFrame = params['addAnalogFrame'];
    final String filmName = params['filmName'];
    final int iso = params['iso'];

    img.Image? image = img.decodeImage(sourceBytes);
    if (image == null) return sourceBytes;

    // 1. Crop to target aspect ratio if needed
    final currentAspect = image.width / image.height;
    if ((currentAspect - aspectRatio).abs() > 0.05) {
      int targetW, targetH;
      if (currentAspect > aspectRatio) {
        // Image is wider than desired ratio
        targetH = image.height;
        targetW = (image.height * aspectRatio).round();
      } else {
        // Image is taller than desired ratio
        targetW = image.width;
        targetH = (image.width / aspectRatio).round();
      }
      final cropX = (image.width - targetW) ~/ 2;
      final cropY = (image.height - targetH) ~/ 2;
      image = img.copyCrop(image, x: cropX, y: cropY, width: targetW, height: targetH);
    }

    final int width = image.width;
    final int height = image.height;
    final random = math.Random(42); // Deterministic seed for consistent organic grain

    final double centerX = width / 2.0;
    final double centerY = height / 2.0;
    final double maxDist = math.sqrt(centerX * centerX + centerY * centerY);

    // 2. Pixel-level processing: Matrix Color Grade + Grain + Vignette
    for (int y = 0; y < height; y++) {
      final double dy = y - centerY;
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);

        final double rIn = pixel.r.toDouble();
        final double gIn = pixel.g.toDouble();
        final double bIn = pixel.b.toDouble();

        // 2a. Apply 4x5 Color Grading Matrix
        double rOut = matrix[0] * rIn + matrix[1] * gIn + matrix[2] * bIn + matrix[4];
        double gOut = matrix[5] * rIn + matrix[6] * gIn + matrix[7] * bIn + matrix[9];
        double bOut = matrix[10] * rIn + matrix[11] * gIn + matrix[12] * bIn + matrix[14];

        // 2b. Organic Silver Halide Film Grain Synthesis
        if (grainAmount > 0.01) {
          // Box-Muller transform for realistic Gaussian noise
          final double u1 = random.nextDouble().clamp(0.0001, 1.0);
          final double u2 = random.nextDouble();
          final double gaussian = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);

          // Film grain is naturally more prominent in midtones than deep blacks/highlights
          final double luminance = (0.299 * rOut + 0.587 * gOut + 0.114 * bOut) / 255.0;
          final double midtoneMask = (1.0 - (luminance - 0.5).abs() * 1.5).clamp(0.2, 1.0);

          final double grainIntensity = gaussian * grainAmount * 45.0 * midtoneMask * (grainSize * 0.9);
          rOut += grainIntensity;
          gOut += grainIntensity;
          bOut += grainIntensity;
        }

        // 2c. Optical Vignette Falloff
        if (vignette > 0.01) {
          final double dx = x - centerX;
          final double dist = math.sqrt(dx * dx + dy * dy);
          final double normDist = (dist / maxDist).clamp(0.0, 1.0);
          final double falloff = 1.0 - (math.pow(normDist, 2.2) * vignette * 0.7);

          rOut *= falloff;
          gOut *= falloff;
          bOut *= falloff;
        }

        pixel.r = rOut.round().clamp(0, 255);
        pixel.g = gOut.round().clamp(0, 255);
        pixel.b = bOut.round().clamp(0, 255);
      }
    }

    // 3. Optional vintage film rebate / border framing
    if (addAnalogFrame) {
      final borderThickness = (width * 0.035).round();
      final framed = img.Image(
        width: width + borderThickness * 2,
        height: height + borderThickness * 2 + (width * 0.05).round(),
        numChannels: 4,
      );
      img.fill(framed, color: img.ColorRgb8(12, 13, 15)); // Film slate border
      img.compositeImage(framed, image, dstX: borderThickness, dstY: borderThickness);
      image = framed;
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }
}

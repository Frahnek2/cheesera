import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';
import 'color_matrix_utils.dart';
import 'cube_lut.dart';
import 'cube_lut_parser.dart';
import 'lut_manager.dart';
import 'lut_processor.dart';

/// The core image rendering engine for Cheesera.
/// Coordinates real-time GPU matrix transforms, 3D .cube LUT processing,
/// analog grain synthesis, vignette, and high-resolution export.
class FilmEngine {
  final LutProcessor lutProcessor;
  final LutManager lutManager;

  FilmEngine({
    LutProcessor? lutProcessor,
    LutManager? lutManager,
  })  : lutProcessor = lutProcessor ?? const DefaultLutProcessor(),
        lutManager = lutManager ?? LutManager(lutProcessor: lutProcessor);

  /// Returns real-time GPU ColorFilter matrix for instantaneous UI response.
  List<double> getPreviewColorMatrix(FilmRecipe recipe) {
    return ColorMatrixUtils.calculateMatrix(recipe);
  }

  /// Parses external .cube LUT file bytes and returns a [Lut3D].
  Lut3D parseCubeLut(Uint8List cubeFileBytes) {
    return CubeLutParser.parseBytes(cubeFileBytes);
  }

  /// Renders a full-resolution processed photo ready for export to camera roll.
  /// Applies 3D LUT (if attached to recipe), matrix grading, grain, and vignette.
  Future<Uint8List> renderFullResolution({
    required Uint8List sourceBytes,
    required FilmRecipe recipe,
    FrameRatio frameRatio = FrameRatio.ratio4_5,
    bool addAnalogFrame = false,
  }) async {
    Float32List? lutTable;
    int? lutSize;
    Float32List? lutMin;
    Float32List? lutMax;

    if (recipe.customLutId != null) {
      final lut = await lutManager.getLut(recipe.customLutId!);
      if (lut != null) {
        lutTable = lut.table;
        lutSize = lut.size;
        lutMin = lut.domainMin;
        lutMax = lut.domainMax;
      }
    }

    return compute(_renderPipeline, {
      'sourceBytes': sourceBytes,
      'matrix': ColorMatrixUtils.calculateMatrix(recipe),
      'grainAmount': recipe.grainAmount,
      'grainSize': recipe.grainSize,
      'vignette': recipe.vignette,
      'fade': recipe.fade,
      'aspectRatio': frameRatio.aspectRatio,
      'addAnalogFrame': addAnalogFrame,
      'lutTable': lutTable,
      'lutSize': lutSize,
      'lutMin': lutMin,
      'lutMax': lutMax,
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
    final Float32List? lutTable = params['lutTable'];
    final int? lutSize = params['lutSize'];
    final Float32List? lutMin = params['lutMin'];
    final Float32List? lutMax = params['lutMax'];

    img.Image? image = img.decodeImage(sourceBytes);
    if (image == null) return sourceBytes;

    // 1. Crop to target aspect ratio if needed
    final currentAspect = image.width / image.height;
    if ((currentAspect - aspectRatio).abs() > 0.05) {
      int targetW, targetH;
      if (currentAspect > aspectRatio) {
        targetH = image.height;
        targetW = (image.height * aspectRatio).round();
      } else {
        targetW = image.width;
        targetH = (image.width / aspectRatio).round();
      }
      final cropX = (image.width - targetW) ~/ 2;
      final cropY = (image.height - targetH) ~/ 2;
      image = img.copyCrop(image, x: cropX, y: cropY, width: targetW, height: targetH);
    }

    final int width = image.width;
    final int height = image.height;
    final random = math.Random(42);

    final double centerX = width / 2.0;
    final double centerY = height / 2.0;
    final double maxDist = math.sqrt(centerX * centerX + centerY * centerY);

    Lut3D? activeLut;
    if (lutTable != null && lutSize != null) {
      activeLut = Lut3D(
        size: lutSize,
        domainMin: lutMin,
        domainMax: lutMax,
        table: lutTable,
      );
    }

    // 2. Pixel-level processing: 3D LUT + Matrix + Grain + Vignette
    for (int y = 0; y < height; y++) {
      final double dy = y - centerY;
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);

        double r = pixel.r.toDouble();
        double g = pixel.g.toDouble();
        double b = pixel.b.toDouble();

        // 2a. Apply 3D LUT if present (via trilinear interpolation)
        if (activeLut != null) {
          final sampled = activeLut.sample(r / 255.0, g / 255.0, b / 255.0);
          r = sampled[0] * 255.0;
          g = sampled[1] * 255.0;
          b = sampled[2] * 255.0;
        }

        // 2b. Apply 4x5 Color Grading Matrix & Recipe offsets
        double rOut = matrix[0] * r + matrix[1] * g + matrix[2] * b + matrix[4];
        double gOut = matrix[5] * r + matrix[6] * g + matrix[7] * b + matrix[9];
        double bOut = matrix[10] * r + matrix[11] * g + matrix[12] * b + matrix[14];

        // 2c. Organic Silver Halide Film Grain Synthesis
        if (grainAmount > 0.01) {
          final double u1 = random.nextDouble().clamp(0.0001, 1.0);
          final double u2 = random.nextDouble();
          final double gaussian = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);

          final double luminance = (0.299 * rOut + 0.587 * gOut + 0.114 * bOut) / 255.0;
          final double midtoneMask = (1.0 - (luminance - 0.5).abs() * 1.5).clamp(0.2, 1.0);

          final double grainIntensity = gaussian * grainAmount * 45.0 * midtoneMask * (grainSize * 0.9);
          rOut += grainIntensity;
          gOut += grainIntensity;
          bOut += grainIntensity;
        }

        // 2d. Optical Vignette Falloff
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

    // 3. Optional vintage film rebate framing
    if (addAnalogFrame) {
      final borderThickness = (width * 0.035).round();
      final framed = img.Image(
        width: width + borderThickness * 2,
        height: height + borderThickness * 2 + (width * 0.05).round(),
        numChannels: 4,
      );
      img.fill(framed, color: img.ColorRgb8(12, 13, 15));
      img.compositeImage(framed, image, dstX: borderThickness, dstY: borderThickness);
      image = framed;
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }
}

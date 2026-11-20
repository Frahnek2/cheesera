import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../models/film_preset.dart';
import 'cube_lut.dart';

/// Clean abstraction interface for 3D Look-Up Table (LUT) processing.
/// This allows plugging in GPU shaders, CPU SIMD, or external .cube LUTs seamlessly.
abstract class LutProcessor {
  /// Applies a 3D LUT to an encoded image buffer (JPEG/PNG) and returns processed image bytes.
  Future<Uint8List> applyLut({
    required Uint8List sourceImageBytes,
    required Lut3D lut,
    double intensity = 1.0,
  });

  /// Samples an individual Color through the 3D LUT.
  Color sampleColor({
    required Lut3D lut,
    required Color color,
    double intensity = 1.0,
  });

  /// Dynamically synthesizes a 3D LUT grid from a [FilmPreset] matrix & tone curve.
  Lut3D generateLutForPreset(FilmPreset preset, {int size = 17});
}

/// Standard production implementation of [LutProcessor] using pure Dart.
class DefaultLutProcessor implements LutProcessor {
  const DefaultLutProcessor();

  @override
  Future<Uint8List> applyLut({
    required Uint8List sourceImageBytes,
    required Lut3D lut,
    double intensity = 1.0,
  }) async {
    final image = img.decodeImage(sourceImageBytes);
    if (image == null) return sourceImageBytes;

    final clampedIntensity = intensity.clamp(0.0, 1.0);
    if (clampedIntensity == 0.0) return sourceImageBytes;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        final double r = pixel.r / 255.0;
        final double g = pixel.g / 255.0;
        final double b = pixel.b / 255.0;

        final sampled = lut.sample(r, g, b);

        final int outR = ((r * (1 - clampedIntensity) + sampled[0] * clampedIntensity) * 255).round().clamp(0, 255);
        final int outG = ((g * (1 - clampedIntensity) + sampled[1] * clampedIntensity) * 255).round().clamp(0, 255);
        final int outB = ((b * (1 - clampedIntensity) + sampled[2] * clampedIntensity) * 255).round().clamp(0, 255);

        pixel.r = outR;
        pixel.g = outG;
        pixel.b = outB;
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 92));
  }

  @override
  Color sampleColor({
    required Lut3D lut,
    required Color color,
    double intensity = 1.0,
  }) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final sampled = lut.sample(r, g, b);
    final clamped = intensity.clamp(0.0, 1.0);

    return Color.fromARGB(
      color.alpha,
      ((r * (1 - clamped) + sampled[0] * clamped) * 255).round().clamp(0, 255),
      ((g * (1 - clamped) + sampled[1] * clamped) * 255).round().clamp(0, 255),
      ((b * (1 - clamped) + sampled[2] * clamped) * 255).round().clamp(0, 255),
    );
  }

  @override
  Lut3D generateLutForPreset(FilmPreset preset, {int size = 17}) {
    final total = size * size * size * 3;
    final table = Float32List(total);
    final step = 1.0 / (size - 1);
    final matrix = preset.colorMatrix;

    int idx = 0;
    for (int b = 0; b < size; b++) {
      final double bIn = b * step;
      for (int g = 0; g < size; g++) {
        final double gIn = g * step;
        for (int r = 0; r < size; r++) {
          final double rIn = r * step;

          // Multiply through 4x5 color grading matrix
          final double r255 = rIn * 255.0;
          final double g255 = gIn * 255.0;
          final double b255 = bIn * 255.0;

          final double outR = (matrix[0] * r255 + matrix[1] * g255 + matrix[2] * b255 + matrix[4]) / 255.0;
          final double outG = (matrix[5] * r255 + matrix[6] * g255 + matrix[7] * b255 + matrix[9]) / 255.0;
          final double outB = (matrix[10] * r255 + matrix[11] * g255 + matrix[12] * b255 + matrix[14]) / 255.0;

          table[idx++] = outR.clamp(0.0, 1.0);
          table[idx++] = outG.clamp(0.0, 1.0);
          table[idx++] = outB.clamp(0.0, 1.0);
        }
      }
    }

    return Lut3D(
      title: '${preset.name} Dynamic 3D LUT',
      size: size,
      table: table,
    );
  }
}

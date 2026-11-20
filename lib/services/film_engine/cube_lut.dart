import 'dart:math' as math;
import 'dart:typed_data';

/// Represents a 3D Look-Up Table (3D LUT) used in professional film color grading.
/// Commonly defined by Adobe .cube files (typically 17x17x17, 33x33x33, or 65x65x65).
class Lut3D {
  final String title;
  final int size; // e.g. 17 or 33
  final Float32List domainMin; // [minR, minG, minB], default [0, 0, 0]
  final Float32List domainMax; // [maxR, maxG, maxB], default [1, 1, 1]
  final Float32List table; // Size: size * size * size * 3 (flattened RGB entries)

  Lut3D({
    this.title = 'Untitled LUT',
    required this.size,
    Float32List? domainMin,
    Float32List? domainMax,
    required this.table,
  })  : domainMin = domainMin ?? Float32List.fromList([0.0, 0.0, 0.0]),
        domainMax = domainMax ?? Float32List.fromList([1.0, 1.0, 1.0]) {
    final expectedLength = size * size * size * 3;
    if (table.length != expectedLength) {
      throw ArgumentError(
        'Lut3D table length (${table.length}) does not match expected dimension $size^3 * 3 = $expectedLength',
      );
    }
  }

  /// Creates an identity 3D LUT where output color equals input color.
  factory Lut3D.identity({int size = 17, String title = 'Identity'}) {
    final total = size * size * size * 3;
    final table = Float32List(total);
    int idx = 0;
    final double step = 1.0 / (size - 1);

    // Standard .cube indexing order: B slowest, then G, then R fastest
    for (int b = 0; b < size; b++) {
      final double bVal = b * step;
      for (int g = 0; g < size; g++) {
        final double gVal = g * step;
        for (int r = 0; r < size; r++) {
          final double rVal = r * step;
          table[idx++] = rVal;
          table[idx++] = gVal;
          table[idx++] = bVal;
        }
      }
    }

    return Lut3D(
      title: title,
      size: size,
      table: table,
    );
  }

  /// Performs accurate 3D Trilinear Interpolation to sample color at normalized RGB coordinates [0.0 .. 1.0].
  List<double> sample(double r, double g, double b) {
    // Normalize according to domain bounds
    final double normR = ((r - domainMin[0]) / (domainMax[0] - domainMin[0])).clamp(0.0, 1.0);
    final double normG = ((g - domainMin[1]) / (domainMax[1] - domainMin[1])).clamp(0.0, 1.0);
    final double normB = ((b - domainMin[2]) / (domainMax[2] - domainMin[2])).clamp(0.0, 1.0);

    final double scale = (size - 1).toDouble();
    final double rCoord = normR * scale;
    final double gCoord = normG * scale;
    final double bCoord = normB * scale;

    final int r0 = rCoord.floor().clamp(0, size - 1);
    final int r1 = math.min(r0 + 1, size - 1);
    final int g0 = gCoord.floor().clamp(0, size - 1);
    final int g1 = math.min(g0 + 1, size - 1);
    final int b0 = bCoord.floor().clamp(0, size - 1);
    final int b1 = math.min(b0 + 1, size - 1);

    final double dr = rCoord - r0;
    final double dg = gCoord - g0;
    final double db = bCoord - b0;

    // Helper to get RGB from flattened table
    List<double> getNode(int rIdx, int gIdx, int bIdx) {
      final int offset = ((bIdx * size + gIdx) * size + rIdx) * 3;
      return [table[offset], table[offset + 1], table[offset + 2]];
    }

    final c000 = getNode(r0, g0, b0);
    final c100 = getNode(r1, g0, b0);
    final c010 = getNode(r0, g1, b0);
    final c110 = getNode(r1, g1, b0);
    final c001 = getNode(r0, g0, b1);
    final c101 = getNode(r1, g0, b1);
    final c011 = getNode(r0, g1, b1);
    final c111 = getNode(r1, g1, b1);

    // Trilinear blend
    final List<double> result = [0.0, 0.0, 0.0];
    for (int i = 0; i < 3; i++) {
      final double c00 = c000[i] * (1 - dr) + c100[i] * dr;
      final double c10 = c010[i] * (1 - dr) + c110[i] * dr;
      final double c01 = c001[i] * (1 - dr) + c101[i] * dr;
      final double c11 = c011[i] * (1 - dr) + c111[i] * dr;

      final double c0 = c00 * (1 - dg) + c10 * dg;
      final double c1 = c01 * (1 - dg) + c11 * dg;

      result[i] = (c0 * (1 - db) + c1 * db).clamp(0.0, 1.0);
    }

    return result;
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'cube_lut.dart';

/// Specification parser for Adobe .cube 3D LUT files.
/// Ready to parse full external .cube LUTs imported by the user or bundled in assets.
class CubeLutParser {
  CubeLutParser._();

  /// Parses an Adobe .cube formatted text content into a [Lut3D] structure.
  static Lut3D parse(String content) {
    final lines = const LineSplitter().convert(content);

    String title = 'External Cube LUT';
    int? lutSize;
    Float32List domainMin = Float32List.fromList([0.0, 0.0, 0.0]);
    Float32List domainMax = Float32List.fromList([1.0, 1.0, 1.0]);

    List<double> values = [];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('TITLE')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length > 1) {
          title = parts.sublist(1).join(' ').replaceAll('"', '');
        }
      } else if (line.startsWith('LUT_3D_SIZE')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length > 1) {
          lutSize = int.tryParse(parts[1]);
        }
      } else if (line.startsWith('DOMAIN_MIN')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          domainMin[0] = double.tryParse(parts[1]) ?? 0.0;
          domainMin[1] = double.tryParse(parts[2]) ?? 0.0;
          domainMin[2] = double.tryParse(parts[3]) ?? 0.0;
        }
      } else if (line.startsWith('DOMAIN_MAX')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          domainMax[0] = double.tryParse(parts[1]) ?? 1.0;
          domainMax[1] = double.tryParse(parts[2]) ?? 1.0;
          domainMax[2] = double.tryParse(parts[3]) ?? 1.0;
        }
      } else {
        // Data line: R G B floats
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          final r = double.tryParse(parts[0]);
          final g = double.tryParse(parts[1]);
          final b = double.tryParse(parts[2]);
          if (r != null && g != null && b != null) {
            values.add(r);
            values.add(g);
            values.add(b);
          }
        }
      }
    }

    if (lutSize == null) {
      // Guess size from values count if not specified
      final cubeLength = values.length ~/ 3;
      final guessedSize = (cubeLength > 0) ? (cubeLength.toDouble() == 0 ? 0 : 17) : 17;
      lutSize = guessedSize;
    }

    final table = Float32List.fromList(values);

    return Lut3D(
      title: title,
      size: lutSize,
      domainMin: domainMin,
      domainMax: domainMax,
      table: table,
    );
  }

  /// Parses from raw byte data.
  static Lut3D parseBytes(Uint8List bytes) {
    final content = utf8.decode(bytes);
    return parse(content);
  }
}

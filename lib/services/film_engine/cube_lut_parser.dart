import 'dart:convert';
import 'dart:typed_data';
import 'cube_lut.dart';

/// Specification parser for Adobe .cube 3D Look-Up Table files.
/// Fully conforms to Adobe Cube LUT Specification (version 1.0).
/// Supports comments (#), TITLE, LUT_3D_SIZE, DOMAIN_MIN, DOMAIN_MAX,
/// and scientific floating point notation.
class CubeLutParser {
  CubeLutParser._();

  /// Parses Adobe .cube formatted text into a [Lut3D] structure.
  /// Throws [FormatException] if the format is invalid or data length does not match size.
  static Lut3D parse(String content) {
    final lines = const LineSplitter().convert(content);

    String title = 'Untitled 3D LUT';
    int? lutSize;
    Float32List domainMin = Float32List.fromList([0.0, 0.0, 0.0]);
    Float32List domainMax = Float32List.fromList([1.0, 1.0, 1.0]);

    List<double> values = [];

    for (int lineNum = 0; lineNum < lines.length; lineNum++) {
      String line = lines[lineNum].trim();
      if (line.isEmpty) continue;

      // Strip inline comments starting with '#'
      final commentIdx = line.indexOf('#');
      if (commentIdx != -1) {
        line = line.substring(0, commentIdx).trim();
        if (line.isEmpty) continue;
      }

      if (line.startsWith('LUT_1D_SIZE')) {
        throw const FormatException(
          'LUT_1D_SIZE detected. Cheesera only processes 3D LUTs (.cube 3D).',
        );
      }

      if (line.startsWith('TITLE')) {
        final match = RegExp(r'^TITLE\s+(?:"([^"]+)"|(\S+))').firstMatch(line);
        if (match != null) {
          title = match.group(1) ?? match.group(2) ?? title;
        } else {
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length > 1) {
            title = parts.sublist(1).join(' ').replaceAll('"', '');
          }
        }
      } else if (line.startsWith('LUT_3D_SIZE')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length > 1) {
          lutSize = int.tryParse(parts[1]);
          if (lutSize == null || lutSize < 2) {
            throw FormatException('Invalid LUT_3D_SIZE on line ${lineNum + 1}: ${parts[1]}');
          }
        }
      } else if (line.startsWith('DOMAIN_MIN')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          final r = double.tryParse(parts[1]);
          final g = double.tryParse(parts[2]);
          final b = double.tryParse(parts[3]);
          if (r != null && g != null && b != null) {
            domainMin = Float32List.fromList([r, g, b]);
          }
        }
      } else if (line.startsWith('DOMAIN_MAX')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          final r = double.tryParse(parts[1]);
          final g = double.tryParse(parts[2]);
          final b = double.tryParse(parts[3]);
          if (r != null && g != null && b != null) {
            domainMax = Float32List.fromList([r, g, b]);
          }
        }
      } else {
        // Data line containing R G B floats separated by whitespace or comma
        final parts = line.split(RegExp(r'[\s,]+'));
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
      if (values.isEmpty) {
        throw const FormatException('Empty .cube file: No LUT_3D_SIZE or color data found.');
      }
      // Infer size from cubic root of value triplets
      final triplets = values.length ~/ 3;
      final cubeRoot = _findExactCubeRoot(triplets);
      if (cubeRoot == null) {
        throw FormatException(
          'Missing LUT_3D_SIZE and could not infer cubic dimension from $triplets color entries.',
        );
      }
      lutSize = cubeRoot;
    }

    final expectedValues = lutSize * lutSize * lutSize * 3;
    if (values.length != expectedValues) {
      throw FormatException(
        'LUT data count mismatch: expected $expectedValues values ($lutSize^3 * 3), but found ${values.length}.',
      );
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

  /// Parses from raw byte stream.
  static Lut3D parseBytes(Uint8List bytes) {
    final content = utf8.decode(bytes);
    return parse(content);
  }

  static int? _findExactCubeRoot(int n) {
    if (n <= 0) return null;
    for (int i = 2; i <= 65; i++) {
      if (i * i * i == n) return i;
    }
    return null;
  }
}

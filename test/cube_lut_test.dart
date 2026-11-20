import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/services/film_engine/cube_lut.dart';
import 'package:cheesera/services/film_engine/cube_lut_parser.dart';
import 'package:cheesera/services/film_engine/lut_manager.dart';

void main() {
  group('Adobe .cube 3D LUT Parser & LutManager Tests', () {
    test('Parses standard 2x2x2 3D LUT with headers, comments and scientific notation', () {
      const cubeContent = '''
# Adobe Cube LUT test file
TITLE "Cheesera Test 3D"
LUT_3D_SIZE 2
DOMAIN_MIN 0.0 0.0 0.0
DOMAIN_MAX 1.0 1.0 1.0

# Slice B=0
0.000000 0.000000 0.000000 # Black
1.000000 0.000000 0.000000
0.000000 1.000000 0.000000
1.000000 1.000000 0.000000

# Slice B=1 with scientific notation
0.000000 0.000000 1.000000e+00
1.000000 0.000000 1.000000
0.000000 1.000000 1.000000
1.000000 1.000000 1.000000 # White
''';

      final lut = CubeLutParser.parse(cubeContent);
      expect(lut.title, 'Cheesera Test 3D');
      expect(lut.size, 2);
      expect(lut.table.length, 2 * 2 * 2 * 3);

      // Verify origin corner (0,0,0) -> (0,0,0)
      final black = lut.sample(0.0, 0.0, 0.0);
      expect(black[0], closeTo(0.0, 0.001));
      expect(black[1], closeTo(0.0, 0.001));
      expect(black[2], closeTo(0.0, 0.001));

      // Verify opposite corner (1,1,1) -> (1,1,1)
      final white = lut.sample(1.0, 1.0, 1.0);
      expect(white[0], closeTo(1.0, 0.001));
      expect(white[1], closeTo(1.0, 0.001));
      expect(white[2], closeTo(1.0, 0.001));

      // Verify midpoint trilinear interpolation
      final mid = lut.sample(0.5, 0.5, 0.5);
      expect(mid[0], closeTo(0.5, 0.01));
      expect(mid[1], closeTo(0.5, 0.01));
      expect(mid[2], closeTo(0.5, 0.01));
    });

    test('Throws FormatException on 1D LUTs', () {
      const cube1D = '''
TITLE "Unsupported 1D"
LUT_1D_SIZE 256
0.0 0.0 0.0
1.0 1.0 1.0
''';
      expect(
        () => CubeLutParser.parse(cube1D),
        throwsA(isA<FormatException>()),
      );
    });

    test('Throws FormatException on data length mismatch', () {
      const invalidCube = '''
LUT_3D_SIZE 2
0.0 0.0 0.0
1.0 1.0 1.0
# Missing remaining 6 entries!
''';
      expect(
        () => CubeLutParser.parse(invalidCube),
        throwsA(isA<FormatException>()),
      );
    });

    test('Parses from raw byte stream', () {
      const content = '''
LUT_3D_SIZE 2
0.0 0.0 0.0
1.0 0.0 0.0
0.0 1.0 0.0
1.0 1.0 0.0
0.0 0.0 1.0
1.0 0.0 1.0
0.0 1.0 1.0
1.0 1.0 1.0
''';
      final bytes = Uint8List.fromList(content.codeUnits);
      final lut = CubeLutParser.parseBytes(bytes);
      expect(lut.size, 2);
    });

    test('LutManager imports and registers custom LUT from bytes', () {
      final manager = LutManager();
      const content = '''
TITLE "User Custom Film LUT"
LUT_3D_SIZE 2
0.0 0.0 0.0
1.0 0.0 0.0
0.0 1.0 0.0
1.0 1.0 0.0
0.0 0.0 1.0
1.0 0.0 1.0
0.0 1.0 1.0
1.0 1.0 1.0
''';
      final bytes = Uint8List.fromList(content.codeUnits);
      final meta = manager.importLutFromBytes(bytes: bytes, filename: 'custom_lut.cube');

      expect(meta.title, 'User Custom Film LUT');
      expect(meta.source, LutSource.userImported);
      expect(manager.availableLuts.any((l) => l.id == meta.id), isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/services/film_engine/cube_lut.dart';
import 'package:cheesera/services/film_engine/cube_lut_parser.dart';

void main() {
  group('Lut3D & CubeLutParser Tests', () {
    test('Identity Lut3D samples correctly', () {
      final identityLut = Lut3D.identity(size: 17);
      expect(identityLut.size, 17);

      // Identity should map (0.5, 0.5, 0.5) to approximately (0.5, 0.5, 0.5)
      final sampled = identityLut.sample(0.5, 0.5, 0.5);
      expect(sampled[0], closeTo(0.5, 0.01));
      expect(sampled[1], closeTo(0.5, 0.01));
      expect(sampled[2], closeTo(0.5, 0.01));

      // Extremes
      final black = identityLut.sample(0.0, 0.0, 0.0);
      expect(black[0], closeTo(0.0, 0.001));

      final white = identityLut.sample(1.0, 1.0, 1.0);
      expect(white[0], closeTo(1.0, 0.001));
    });

    test('CubeLutParser parses .cube format correctly', () {
      const cubeData = '''
TITLE "Test LUT"
LUT_3D_SIZE 2
DOMAIN_MIN 0.0 0.0 0.0
DOMAIN_MAX 1.0 1.0 1.0

0.0 0.0 0.0
1.0 0.0 0.0
0.0 1.0 0.0
1.0 1.0 0.0
0.0 0.0 1.0
1.0 0.0 1.0
0.0 1.0 1.0
1.0 1.0 1.0
''';

      final lut = CubeLutParser.parse(cubeData);
      expect(lut.title, 'Test LUT');
      expect(lut.size, 2);
      expect(lut.table.length, 2 * 2 * 2 * 3);

      final sampleMid = lut.sample(0.5, 0.5, 0.5);
      expect(sampleMid[0], closeTo(0.5, 0.05));
    });
  });
}

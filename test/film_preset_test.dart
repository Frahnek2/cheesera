import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/models/film_preset.dart';
import 'package:cheesera/models/film_recipe.dart';
import 'package:cheesera/services/film_engine/color_matrix_utils.dart';

void main() {
  group('FilmPreset & FilmRecipe Tests', () {
    test('Default presets have valid 4x5 color matrices and metadata', () {
      expect(FilmPreset.allPresets.isNotEmpty, true);
      for (final preset in FilmPreset.allPresets) {
        expect(preset.colorMatrix.length, 20); // 4x5 matrix
        expect(preset.name.isNotEmpty, true);
        expect(preset.code.isNotEmpty, true);
        expect(preset.iso, greaterThan(0));
      }
    });

    test('FilmRecipe correctly computes combined color matrix', () {
      final recipe = FilmRecipe.fromPreset(FilmPreset.portra400).copyWith(
        exposure: 0.5,
        warmth: 0.2,
      );

      final matrix = ColorMatrixUtils.calculateMatrix(recipe);
      expect(matrix.length, 20);

      // Reset works
      final resetRecipe = recipe.reset();
      expect(resetRecipe.exposure, FilmPreset.portra400.defaultExposure);
    });
  });
}

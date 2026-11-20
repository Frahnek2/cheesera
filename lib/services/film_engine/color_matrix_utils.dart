import '../../models/film_recipe.dart';

/// Helper to generate composite 4x5 ColorMatrix for Flutter's [ColorFilter.matrix].
/// This enables zero-latency 60/120 FPS real-time tactile editing directly on the GPU.
class ColorMatrixUtils {
  ColorMatrixUtils._();

  /// Calculates a unified 4x5 ColorMatrix combining the film preset baseline with
  /// recipe exposure, warmth, tint, contrast, and fade.
  static List<double> calculateMatrix(FilmRecipe recipe) {
    final base = List<double>.from(recipe.preset.colorMatrix);

    // 1. Exposure compensation (shifts brightness baseline)
    final double exposureOffset = recipe.exposure * 35.0;

    // 2. Warmth (amber vs cool cyan shift)
    final double warmthR = recipe.warmth * 18.0;
    final double warmthB = -recipe.warmth * 18.0;

    // 3. Tint (magenta vs green shift)
    final double tintG = -recipe.tint * 15.0;
    final double tintR = recipe.tint * 8.0;
    final double tintB = recipe.tint * 8.0;

    // 4. Contrast scaling
    final double contrastScale = 1.0 + recipe.contrast * 0.4;
    final double contrastOffset = 128.0 * (1.0 - contrastScale);

    // 5. Matte black fade (lifts shadows)
    final double fadeOffset = recipe.fade * 40.0;

    // Apply scaling and offsets to 4x5 matrix
    return [
      base[0] * contrastScale, base[1], base[2], base[3], base[4] + exposureOffset + warmthR + tintR + contrastOffset + fadeOffset,
      base[5], base[6] * contrastScale, base[7], base[8], base[9] + exposureOffset + tintG + contrastOffset + fadeOffset,
      base[10], base[11], base[12] * contrastScale, base[13], base[14] + exposureOffset + warmthB + tintB + contrastOffset + fadeOffset,
      base[15], base[16], base[17], base[18], base[19],
    ];
  }

  /// Identity matrix (no alteration)
  static const List<double> identity = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

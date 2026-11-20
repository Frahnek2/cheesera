import 'film_preset.dart';

/// Represents a configurable recipe adjusting film stock, grain, and color chemistry.
class FilmRecipe {
  final String id;
  final String title;
  final FilmPreset preset;

  // Exposure & Tone adjustments
  final double exposure; // -2.0 to +2.0 EV
  final double contrast; // -1.0 to +1.0
  final double warmth; // -1.0 (cool) to +1.0 (warm)
  final double tint; // -1.0 (green) to +1.0 (magenta)
  final double highlights; // -1.0 to +1.0
  final double shadows; // -1.0 to +1.0

  // Film texture & optics
  final double grainAmount; // 0.0 to 1.0
  final double grainSize; // 0.5 to 2.0
  final double fade; // 0.0 to 0.5 (matte black floor)
  final double vignette; // 0.0 to 1.0

  const FilmRecipe({
    required this.id,
    required this.title,
    required this.preset,
    this.exposure = 0.0,
    this.contrast = 0.0,
    this.warmth = 0.0,
    this.tint = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.grainAmount = 0.25,
    this.grainSize = 1.0,
    this.fade = 0.05,
    this.vignette = 0.15,
  });

  /// Creates a recipe initialized to the preset's natural baseline.
  factory FilmRecipe.fromPreset(FilmPreset preset, {String? customTitle}) {
    return FilmRecipe(
      id: '${preset.id}_default',
      title: customTitle ?? preset.name,
      preset: preset,
      exposure: preset.defaultExposure,
      contrast: preset.defaultContrast,
      warmth: preset.defaultWarmth,
      tint: preset.defaultTint,
      highlights: preset.defaultHighlights,
      shadows: preset.defaultShadows,
      grainAmount: preset.defaultGrain,
      grainSize: preset.defaultGrainSize,
      fade: preset.defaultFade,
      vignette: preset.defaultVignette,
    );
  }

  FilmRecipe copyWith({
    String? id,
    String? title,
    FilmPreset? preset,
    double? exposure,
    double? contrast,
    double? warmth,
    double? tint,
    double? highlights,
    double? shadows,
    double? grainAmount,
    double? grainSize,
    double? fade,
    double? vignette,
  }) {
    return FilmRecipe(
      id: id ?? this.id,
      title: title ?? this.title,
      preset: preset ?? this.preset,
      exposure: exposure ?? this.exposure,
      contrast: contrast ?? this.contrast,
      warmth: warmth ?? this.warmth,
      tint: tint ?? this.tint,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      grainAmount: grainAmount ?? this.grainAmount,
      grainSize: grainSize ?? this.grainSize,
      fade: fade ?? this.fade,
      vignette: vignette ?? this.vignette,
    );
  }

  /// Reset to baseline preset values
  FilmRecipe reset() {
    return FilmRecipe.fromPreset(preset, customTitle: title);
  }

  // =========================================================================
  // SAMPLE CURATED RECIPES (Pre-baked photographer favorites)
  // =========================================================================

  static final List<FilmRecipe> defaultSampleRecipes = [
    FilmRecipe.fromPreset(FilmPreset.portra400, customTitle: 'Sunset Portra 400'),
    FilmRecipe.fromPreset(FilmPreset.cinestill800T, customTitle: 'Tokyo Night 800T').copyWith(
      exposure: 0.15,
      contrast: 0.25,
      warmth: -0.20,
      vignette: 0.35,
    ),
    FilmRecipe.fromPreset(FilmPreset.triX400, customTitle: 'Street Noir TX400').copyWith(
      contrast: 0.40,
      shadows: -0.30,
      grainAmount: 0.65,
    ),
    FilmRecipe.fromPreset(FilmPreset.gold200, customTitle: 'Summer Nostalgia 200').copyWith(
      warmth: 0.40,
      exposure: 0.15,
      fade: 0.12,
    ),
    FilmRecipe.fromPreset(FilmPreset.cheeseraVelvet, customTitle: 'Signature Velvet'),
  ];
}

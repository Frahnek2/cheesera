import 'film_preset.dart';

enum GrainRoughness { off, weak, strong }
enum GrainSize { small, large }
enum ColorChromeState { off, weak, strong }
enum WhiteBalanceMode { auto, daylight, shade, fluorescent, incandescent, kelvin }

/// Represents an analog film recipe, supporting both Cheesera continuous sliders
/// and authentic Fujifilm camera recipe parameters (Fuji X-Series / X100VI / X-T5 style).
class FilmRecipe {
  final String id;
  final String title;
  final FilmPreset preset;
  final bool isCustom;
  final String? author;
  final String? notes;
  final DateTime createdAt;

  // ---------------------------------------------------------------------------
  // Continuous Color & Optical Parameters (Cheesera Core)
  // ---------------------------------------------------------------------------
  final double exposure; // -2.0 to +2.0 EV
  final double contrast; // -1.0 to +1.0
  final double warmth; // -1.0 (cool) to +1.0 (warm)
  final double tint; // -1.0 (green) to +1.0 (magenta)
  final double highlights; // -1.0 to +1.0
  final double shadows; // -1.0 to +1.0
  final double grainAmount; // 0.0 to 1.0
  final double grainSizeValue; // 0.5 to 2.0
  double get grainSize => grainSizeValue;
  final double fade; // 0.0 to 0.5 (matte black floor)
  final double vignette; // 0.0 to 1.0

  // ---------------------------------------------------------------------------
  // Authentic Fujifilm Camera Parameters (X Weekly Compatible)
  // ---------------------------------------------------------------------------
  final String dynamicRange; // "DR100", "DR200", "DR400", "Auto"
  final double highlightTone; // -2 to +4 in 0.5/1.0 steps
  final double shadowTone; // -2 to +4
  final double colorSaturation; // -4 to +4
  final double sharpness; // -4 to +4
  final double noiseReduction; // -4 to +4
  final double clarity; // -5 to +5
  final GrainRoughness grainRoughness;
  final GrainSize grainSize;
  final ColorChromeState colorChromeEffect;
  final ColorChromeState colorChromeFxBlue;
  final WhiteBalanceMode whiteBalanceMode;
  final int wbColorTemp; // 2500K to 10000K
  final int wbShiftR; // -9 to +9 Red
  final int wbShiftB; // -9 to +9 Blue

  // ---------------------------------------------------------------------------
  // 3D .cube LUT Linking
  // ---------------------------------------------------------------------------
  final String? customLutId;

  FilmRecipe({
    required this.id,
    required this.title,
    required this.preset,
    this.isCustom = false,
    this.author,
    this.notes,
    DateTime? createdAt,
    // Core parameters
    this.exposure = 0.0,
    this.contrast = 0.0,
    this.warmth = 0.0,
    this.tint = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.grainAmount = 0.25,
    this.grainSizeValue = 1.0,
    this.fade = 0.05,
    this.vignette = 0.15,
    // Fuji parameters
    this.dynamicRange = 'DR200',
    this.highlightTone = 0.0,
    this.shadowTone = 0.0,
    this.colorSaturation = 0.0,
    this.sharpness = 0.0,
    this.noiseReduction = -2.0,
    this.clarity = 0.0,
    this.grainRoughness = GrainRoughness.weak,
    this.grainSize = GrainSize.small,
    this.colorChromeEffect = ColorChromeState.off,
    this.colorChromeFxBlue = ColorChromeState.off,
    this.whiteBalanceMode = WhiteBalanceMode.auto,
    this.wbColorTemp = 5500,
    this.wbShiftR = 0,
    this.wbShiftB = 0,
    this.customLutId,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a recipe initialized to the baseline preset.
  factory FilmRecipe.fromPreset(FilmPreset preset, {String? customTitle, bool isCustom = false}) {
    return FilmRecipe(
      id: '${preset.id}_default',
      title: customTitle ?? preset.name,
      preset: preset,
      isCustom: isCustom,
      exposure: preset.defaultExposure,
      contrast: preset.defaultContrast,
      warmth: preset.defaultWarmth,
      tint: preset.defaultTint,
      highlights: preset.defaultHighlights,
      shadows: preset.defaultShadows,
      grainAmount: preset.defaultGrain,
      grainSizeValue: preset.defaultGrainSize,
      fade: preset.defaultFade,
      vignette: preset.defaultVignette,
    );
  }

  FilmRecipe copyWith({
    String? id,
    String? title,
    FilmPreset? preset,
    bool? isCustom,
    String? author,
    String? notes,
    DateTime? createdAt,
    double? exposure,
    double? contrast,
    double? warmth,
    double? tint,
    double? highlights,
    double? shadows,
    double? grainAmount,
    double? grainSizeValue,
    double? fade,
    double? vignette,
    String? dynamicRange,
    double? highlightTone,
    double? shadowTone,
    double? colorSaturation,
    double? sharpness,
    double? noiseReduction,
    double? clarity,
    GrainRoughness? grainRoughness,
    GrainSize? grainSize,
    ColorChromeState? colorChromeEffect,
    ColorChromeState? colorChromeFxBlue,
    WhiteBalanceMode? whiteBalanceMode,
    int? wbColorTemp,
    int? wbShiftR,
    int? wbShiftB,
    String? customLutId,
  }) {
    return FilmRecipe(
      id: id ?? this.id,
      title: title ?? this.title,
      preset: preset ?? this.preset,
      isCustom: isCustom ?? this.isCustom,
      author: author ?? this.author,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      exposure: exposure ?? this.exposure,
      contrast: contrast ?? this.contrast,
      warmth: warmth ?? this.warmth,
      tint: tint ?? this.tint,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      grainAmount: grainAmount ?? this.grainAmount,
      grainSizeValue: grainSizeValue ?? this.grainSizeValue,
      fade: fade ?? this.fade,
      vignette: vignette ?? this.vignette,
      dynamicRange: dynamicRange ?? this.dynamicRange,
      highlightTone: highlightTone ?? this.highlightTone,
      shadowTone: shadowTone ?? this.shadowTone,
      colorSaturation: colorSaturation ?? this.colorSaturation,
      sharpness: sharpness ?? this.sharpness,
      noiseReduction: noiseReduction ?? this.noiseReduction,
      clarity: clarity ?? this.clarity,
      grainRoughness: grainRoughness ?? this.grainRoughness,
      grainSize: grainSize ?? this.grainSize,
      colorChromeEffect: colorChromeEffect ?? this.colorChromeEffect,
      colorChromeFxBlue: colorChromeFxBlue ?? this.colorChromeFxBlue,
      whiteBalanceMode: whiteBalanceMode ?? this.whiteBalanceMode,
      wbColorTemp: wbColorTemp ?? this.wbColorTemp,
      wbShiftR: wbShiftR ?? this.wbShiftR,
      wbShiftB: wbShiftB ?? this.wbShiftB,
      customLutId: customLutId ?? this.customLutId,
    );
  }

  FilmRecipe reset() {
    return FilmRecipe.fromPreset(preset, customTitle: title, isCustom: isCustom);
  }

  // ---------------------------------------------------------------------------
  // BUILT-IN CURATED RECIPES
  // ---------------------------------------------------------------------------

  static final List<FilmRecipe> defaultSampleRecipes = [
    FilmRecipe(
      id: 'sunset_portra_400',
      title: 'Sunset Portra 400',
      preset: FilmPreset.portra400,
      author: 'Cheesera Lab',
      notes: 'Golden hour skin tones with subtle amber highlight roll-off.',
      exposure: 0.15,
      contrast: 0.08,
      warmth: 0.28,
      tint: 0.04,
      highlights: -0.15,
      shadows: 0.10,
      grainAmount: 0.28,
      vignette: 0.12,
      dynamicRange: 'DR400',
      highlightTone: -1.0,
      shadowTone: 1.0,
      colorSaturation: 2.0,
      whiteBalanceMode: WhiteBalanceMode.daylight,
      wbShiftR: 2,
      wbShiftB: -3,
    ),
    FilmRecipe(
      id: 'tokyo_night_800t',
      title: 'Tokyo Night 800T',
      preset: FilmPreset.cinestill800T,
      author: 'Cheesera Lab',
      notes: 'Tungsten balanced neon tones with deep cyan shadows and warm glows.',
      exposure: 0.10,
      contrast: 0.25,
      warmth: -0.22,
      tint: -0.06,
      highlights: 0.25,
      shadows: -0.15,
      grainAmount: 0.42,
      vignette: 0.32,
      dynamicRange: 'DR200',
      highlightTone: 2.0,
      shadowTone: -1.0,
      whiteBalanceMode: WhiteBalanceMode.incandescent,
      wbShiftR: -2,
      wbShiftB: 4,
    ),
    FilmRecipe(
      id: 'street_noir_tx400',
      title: 'Street Noir TX400',
      preset: FilmPreset.triX400,
      author: 'Cheesera Lab',
      notes: 'Hard-hitting documentary monochrome with organic silver halide grain.',
      contrast: 0.45,
      shadows: -0.35,
      grainAmount: 0.65,
      grainSizeValue: 1.3,
      vignette: 0.25,
      dynamicRange: 'DR100',
      highlightTone: 1.0,
      shadowTone: 3.0,
      sharpness: 2.0,
      grainRoughness: GrainRoughness.strong,
      grainSize: GrainSize.large,
    ),
    FilmRecipe(
      id: 'summer_nostalgia_200',
      title: 'Summer Nostalgia 200',
      preset: FilmPreset.gold200,
      author: 'Cheesera Lab',
      notes: 'Nostalgic sunlit warmth with pastel yellow cast and soft contrast.',
      exposure: 0.18,
      contrast: 0.12,
      warmth: 0.42,
      tint: 0.05,
      fade: 0.12,
      grainAmount: 0.30,
      vignette: 0.20,
      dynamicRange: 'DR400',
      highlightTone: -1.5,
      shadowTone: 0.5,
      colorSaturation: 3.0,
      wbShiftR: 4,
      wbShiftB: -4,
    ),
    FilmRecipe(
      id: 'signature_velvet',
      title: 'Signature Velvet',
      preset: FilmPreset.cheeseraVelvet,
      author: 'Cheesera Lab',
      notes: 'Velvety matte shadows, creamy highlights, and rich analog warmth.',
      exposure: 0.08,
      contrast: 0.16,
      warmth: 0.22,
      fade: 0.08,
      grainAmount: 0.30,
      vignette: 0.20,
    ),
  ];
}

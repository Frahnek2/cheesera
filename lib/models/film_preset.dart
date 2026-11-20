import 'package:flutter/material.dart';

enum FilmStockCategory {
  colorNegative,
  blackAndWhite,
  colorReversal, // Slide film
  tungstenBalanced,
}

/// Represents an iconic analog film simulation preset.
class FilmPreset {
  final String id;
  final String name;
  final String code;
  final String manufacturer;
  final int iso;
  final FilmStockCategory category;
  final String character;
  final Color badgeColor;

  // Color grading matrix (4x5) for fast real-time hardware color filtering
  final List<double> colorMatrix;

  // Tone curve & film characteristics
  final double defaultExposure;
  final double defaultContrast;
  final double defaultWarmth;
  final double defaultTint;
  final double defaultHighlights;
  final double defaultShadows;
  final double defaultGrain;
  final double defaultGrainSize;
  final double defaultFade;
  final double defaultVignette;

  const FilmPreset({
    required this.id,
    required this.name,
    required this.code,
    required this.manufacturer,
    required this.iso,
    required this.category,
    required this.character,
    required this.badgeColor,
    required this.colorMatrix,
    this.defaultExposure = 0.0,
    this.defaultContrast = 0.0,
    this.defaultWarmth = 0.0,
    this.defaultTint = 0.0,
    this.defaultHighlights = 0.0,
    this.defaultShadows = 0.0,
    this.defaultGrain = 0.25,
    this.defaultGrainSize = 1.0,
    this.defaultFade = 0.05,
    this.defaultVignette = 0.15,
  });

  bool get isMonochrome => category == FilmStockCategory.blackAndWhite;

  // =========================================================================
  // BUILT-IN ICONIC FILM PRESETS (100% Zero-External-File Out-of-the-Box)
  // =========================================================================

  /// Kodak Portra 400 - Golden skin tones, soft pastel highlights, smooth contrast.
  static const FilmPreset portra400 = FilmPreset(
    id: 'portra_400',
    name: 'Portra 400',
    code: 'P400',
    manufacturer: 'Kodak',
    iso: 400,
    category: FilmStockCategory.colorNegative,
    character: 'Warm golden skin tones, gentle highlight roll-off, soft pastel midtones',
    badgeColor: Color(0xFFF7B267),
    colorMatrix: [
      1.12, 0.02, 0.00, 0.0, 10.0,
      0.02, 1.04, 0.00, 0.0, 5.0,
      0.00, 0.03, 0.94, 0.0, -8.0,
      0.00, 0.00, 0.00, 1.0, 0.0,
    ],
    defaultExposure: 0.1,
    defaultContrast: 0.05,
    defaultWarmth: 0.20,
    defaultHighlights: -0.10,
    defaultShadows: 0.15,
    defaultGrain: 0.22,
    defaultFade: 0.08,
  );

  /// Kodak Tri-X 400 - Punchy high contrast black & white with gritty silver halide grain.
  static const FilmPreset triX400 = FilmPreset(
    id: 'trix_400',
    name: 'Tri-X 400',
    code: 'TX400',
    manufacturer: 'Kodak',
    iso: 400,
    category: FilmStockCategory.blackAndWhite,
    character: 'High contrast documentary monochrome, deep blacks, punchy silver halide grain',
    badgeColor: Color(0xFFD6D6D6),
    colorMatrix: [
      0.299 * 1.25, 0.587 * 1.25, 0.114 * 1.25, 0.0, -15.0,
      0.299 * 1.25, 0.587 * 1.25, 0.114 * 1.25, 0.0, -15.0,
      0.299 * 1.25, 0.587 * 1.25, 0.114 * 1.25, 0.0, -15.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ],
    defaultExposure: 0.0,
    defaultContrast: 0.35,
    defaultHighlights: 0.10,
    defaultShadows: -0.25,
    defaultGrain: 0.50,
    defaultGrainSize: 1.3,
    defaultFade: 0.02,
    defaultVignette: 0.25,
  );

  /// CineStill 800T - Motion picture stock with tungsten balance, cyan shadows & halation.
  static const FilmPreset cinestill800T = FilmPreset(
    id: 'cinestill_800t',
    name: 'CineStill 800T',
    code: 'CS800',
    manufacturer: 'CineStill',
    iso: 800,
    category: FilmStockCategory.tungstenBalanced,
    character: 'Tungsten balanced, deep teal shadows with warm incandescent neon glow',
    badgeColor: Color(0xFF48CAE4),
    colorMatrix: [
      0.98, 0.02, 0.08, 0.0, 18.0,
      0.00, 1.02, 0.02, 0.0, 2.0,
      0.08, 0.04, 1.18, 0.0, 22.0,
      0.00, 0.00, 0.00, 1.0, 0.0,
    ],
    defaultExposure: 0.05,
    defaultContrast: 0.18,
    defaultWarmth: -0.15,
    defaultTint: -0.05,
    defaultHighlights: 0.20,
    defaultShadows: -0.10,
    defaultGrain: 0.38,
    defaultGrainSize: 1.1,
    defaultFade: 0.06,
    defaultVignette: 0.20,
  );

  /// Fujifilm Classic Chrome - Desaturated documentary colors with rich deep shadows.
  static const FilmPreset classicChrome = FilmPreset(
    id: 'classic_chrome',
    name: 'Classic Chrome',
    code: 'CC',
    manufacturer: 'Fujifilm',
    iso: 200,
    category: FilmStockCategory.colorNegative,
    character: 'Muted saturation, hard documentary shadow gradations, nostalgic reportage look',
    badgeColor: Color(0xFF90A955),
    colorMatrix: [
      0.95, 0.06, 0.02, 0.0, -4.0,
      0.04, 0.92, 0.04, 0.0, -6.0,
      0.02, 0.05, 0.88, 0.0, -8.0,
      0.00, 0.00, 0.00, 1.0, 0.0,
    ],
    defaultExposure: -0.05,
    defaultContrast: 0.22,
    defaultWarmth: 0.08,
    defaultHighlights: -0.15,
    defaultShadows: -0.15,
    defaultGrain: 0.20,
    defaultFade: 0.04,
  );

  /// Kodak Ektachrome E100 - Vivid slide film with saturated blues and crisp punch.
  static const FilmPreset ektachromeE100 = FilmPreset(
    id: 'ektachrome_e100',
    name: 'Ektachrome E100',
    code: 'E100',
    manufacturer: 'Kodak',
    iso: 100,
    category: FilmStockCategory.colorReversal,
    character: 'Fine-grained reversal slide film, rich vibrant blues, clean white highlights',
    badgeColor: Color(0xFF0077B6),
    colorMatrix: [
      1.10, 0.00, 0.00, 0.0, 5.0,
      0.00, 1.08, 0.02, 0.0, 4.0,
      0.02, 0.02, 1.22, 0.0, 12.0,
      0.00, 0.00, 0.00, 1.0, 0.0,
    ],
    defaultExposure: 0.0,
    defaultContrast: 0.25,
    defaultWarmth: -0.05,
    defaultHighlights: 0.12,
    defaultShadows: -0.12,
    defaultGrain: 0.12,
    defaultFade: 0.01,
  );

  /// Ilford HP5 Plus - Smooth tonal transitions, forgiving latitude, timeless street film.
  static const FilmPreset ilfordHP5 = FilmPreset(
    id: 'ilford_hp5',
    name: 'Ilford HP5 Plus',
    code: 'HP5',
    manufacturer: 'Ilford',
    iso: 400,
    category: FilmStockCategory.blackAndWhite,
    character: 'Classic British monochrome, velvety midtones, soft highlights, medium grain',
    badgeColor: Color(0xFFA8B2D1),
    colorMatrix: [
      0.30, 0.59, 0.11, 0.0, 4.0,
      0.30, 0.59, 0.11, 0.0, 4.0,
      0.30, 0.59, 0.11, 0.0, 4.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ],
    defaultExposure: 0.05,
    defaultContrast: 0.12,
    defaultHighlights: -0.05,
    defaultShadows: 0.10,
    defaultGrain: 0.32,
    defaultGrainSize: 1.0,
    defaultFade: 0.09,
    defaultVignette: 0.12,
  );

  /// Kodak Gold 200 - Warm nostalgic 90s snapshot feel with sun-drenched amber tones.
  static const FilmPreset gold200 = FilmPreset(
    id: 'gold_200',
    name: 'Gold 200',
    code: 'G200',
    manufacturer: 'Kodak',
    iso: 200,
    category: FilmStockCategory.colorNegative,
    character: 'Sunlit everyday warmth, rich golden yellow cast, nostalgic 90s album look',
    badgeColor: Color(0xFFE5A93C),
    colorMatrix: [
      1.16, 0.03, 0.00, 0.0, 12.0,
      0.03, 1.06, 0.00, 0.0, 8.0,
      0.00, 0.02, 0.88, 0.0, -14.0,
      0.00, 0.00, 0.00, 1.0, 0.0,
    ],
    defaultExposure: 0.10,
    defaultContrast: 0.15,
    defaultWarmth: 0.35,
    defaultHighlights: -0.05,
    defaultShadows: 0.05,
    defaultGrain: 0.28,
    defaultFade: 0.06,
    defaultVignette: 0.18,
  );

  /// Cheesera Velvet - Signature modern aesthetic with lush deep blacks and creamy highlights.
  static const FilmPreset cheeseraVelvet = FilmPreset(
    id: 'cheesera_velvet',
    name: 'Cheesera Velvet',
    code: 'VELV',
    manufacturer: 'Cheesera',
    iso: 160,
    category: FilmStockCategory.colorNegative,
    character: 'Signature aesthetic: lush velvety shadows, creamy highlights, warm analog glow',
    badgeColor: Color(0xFFFF9E3B),
    colorMatrix: [
      1.14, 0.02, 0.02, 0.0, 14.0,
      0.01, 1.05, 0.01, 0.0, 6.0,
      0.00, 0.04, 0.96, 0.0, -2.0,
      0.00, 0.00, 0.00, 1.0, 0.0,
    ],
    defaultExposure: 0.08,
    defaultContrast: 0.18,
    defaultWarmth: 0.25,
    defaultHighlights: -0.08,
    defaultShadows: 0.12,
    defaultGrain: 0.30,
    defaultGrainSize: 1.1,
    defaultFade: 0.07,
    defaultVignette: 0.20,
  );

  /// All default built-in presets
  static const List<FilmPreset> allPresets = [
    portra400,
    triX400,
    cinestill800T,
    classicChrome,
    ektachromeE100,
    ilfordHP5,
    gold200,
    cheeseraVelvet,
  ];

  static FilmPreset findById(String id) {
    return allPresets.firstWhere(
      (preset) => preset.id == id,
      orElse: () => portra400,
    );
  }
}

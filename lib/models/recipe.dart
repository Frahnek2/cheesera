class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final String filmSimulation;
  final int dynamicRange;
  final int highlightShadow;
  final int color;
  final int noiseReduction;
  final int sharpness;
  final int grainEffect;
  final int colorChromeEffect;
  final int whiteBalance;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.filmSimulation,
    required this.dynamicRange,
    required this.highlightShadow,
    required this.color,
    required this.noiseReduction,
    required this.sharpness,
    required this.grainEffect,
    required this.colorChromeEffect,
    required this.whiteBalance,
  });

  // Sample Fujifilm-style recipes
  static List<Recipe> getSampleRecipes() {
    return [
      Recipe(
        id: '1',
        name: 'Classic Chrome',
        description: 'Low contrast, muted colors for timeless look',
        tags: ['moody', 'vintage', 'low contrast', 'portrait', 'soft'],
        filmSimulation: 'Classic Chrome',
        dynamicRange: 200,
        highlightShadow: -1,
        color: -2,
        noiseReduction: -2,
        sharpness: -1,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
      Recipe(
        id: '2',
        name: 'Velvia',
        description: 'Vivid colors and high contrast',
        tags: ['vibrant', 'high contrast', 'landscape', 'golden hour', 'saturated'],
        filmSimulation: 'Velvia',
        dynamicRange: 100,
        highlightShadow: 0,
        color: 2,
        noiseReduction: -2,
        sharpness: 0,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
      Recipe(
        id: '3',
        name: 'Acros',
        description: 'Monochrome with rich tonality',
        tags: ['monochrome', 'high contrast', 'urban', 'moody urban', 'street'],
        filmSimulation: 'Acros',
        dynamicRange: 200,
        highlightShadow: -1,
        color: 0,
        noiseReduction: -4,
        sharpness: 2,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
      Recipe(
        id: '4',
        name: 'Provia',
        description: 'Standard colors with natural reproduction',
        tags: ['natural', 'portrait', 'bright', 'everyday', 'balanced'],
        filmSimulation: 'Provia',
        dynamicRange: 100,
        highlightShadow: 0,
        color: 0,
        noiseReduction: 0,
        sharpness: 0,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
      Recipe(
        id: '5',
        name: 'Astia',
        description: 'Soft colors with smooth skin tones',
        tags: ['soft', 'portrait', 'pastel', 'warm', 'golden hour'],
        filmSimulation: 'Astia',
        dynamicRange: 200,
        highlightShadow: -1,
        color: -1,
        noiseReduction: 0,
        sharpness: -1,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
      Recipe(
        id: '6',
        name: 'Eterna',
        description: 'Cinema-like colors with low saturation',
        tags: ['cinematic', 'moody', 'low contrast', 'film look', 'soft'],
        filmSimulation: 'Eterna',
        dynamicRange: 400,
        highlightShadow: -2,
        color: -2,
        noiseReduction: -2,
        sharpness: -2,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
      Recipe(
        id: '7',
        name: 'Nostalgic Neg',
        description: 'Warm tones with soft contrast',
        tags: ['vintage', 'warm', 'soft', 'golden hour', 'film look'],
        filmSimulation: 'Nostalgic Neg',
        dynamicRange: 200,
        highlightShadow: -1,
        color: 0,
        noiseReduction: -2,
        sharpness: -1,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
      Recipe(
        id: '8',
        name: 'Street Night',
        description: 'High contrast for night photography',
        tags: ['high contrast', 'urban', 'night', 'moody urban', 'street'],
        filmSimulation: 'Classic Chrome',
        dynamicRange: 400,
        highlightShadow: -2,
        color: -1,
        noiseReduction: -2,
        sharpness: 1,
        grainEffect: 0,
        colorChromeEffect: 0,
        whiteBalance: 0,
      ),
    ];
  }
}

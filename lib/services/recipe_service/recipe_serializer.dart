import 'dart:convert';
import '../../models/film_preset.dart';
import '../../models/film_recipe.dart';

/// Handles bidirectional JSON serialization and parsing of Fujifilm & Cheesera recipes.
/// Supports both native structured format and Fuji X Weekly community recipe string formats.
class RecipeSerializer {
  RecipeSerializer._();

  /// Converts a [FilmRecipe] into a structured JSON map.
  static Map<String, dynamic> toJson(FilmRecipe recipe) {
    return {
      'id': recipe.id,
      'title': recipe.title,
      'presetId': recipe.preset.id,
      'isCustom': recipe.isCustom,
      'author': recipe.author,
      'notes': recipe.notes,
      'createdAt': recipe.createdAt.toIso8601String(),
      // Continuous params
      'exposure': recipe.exposure,
      'contrast': recipe.contrast,
      'warmth': recipe.warmth,
      'tint': recipe.tint,
      'highlights': recipe.highlights,
      'shadows': recipe.shadows,
      'grainAmount': recipe.grainAmount,
      'grainSizeValue': recipe.grainSizeValue,
      'fade': recipe.fade,
      'vignette': recipe.vignette,
      // Fuji camera params
      'dynamicRange': recipe.dynamicRange,
      'highlightTone': recipe.highlightTone,
      'shadowTone': recipe.shadowTone,
      'colorSaturation': recipe.colorSaturation,
      'sharpness': recipe.sharpness,
      'noiseReduction': recipe.noiseReduction,
      'clarity': recipe.clarity,
      'grainRoughness': recipe.grainRoughness.name,
      'grainSize': recipe.grainSize.name,
      'colorChromeEffect': recipe.colorChromeEffect.name,
      'colorChromeFxBlue': recipe.colorChromeFxBlue.name,
      'whiteBalanceMode': recipe.whiteBalanceMode.name,
      'wbColorTemp': recipe.wbColorTemp,
      'wbShiftR': recipe.wbShiftR,
      'wbShiftB': recipe.wbShiftB,
      // Optional LUT
      'customLutId': recipe.customLutId,
    };
  }

  /// Deserializes a structured JSON map into a [FilmRecipe].
  /// Fallbacks gracefully to baseline preset values if fields are missing or corrupted.
  static FilmRecipe fromJson(Map<String, dynamic> json) {
    final presetId = json['presetId']?.toString() ?? 'portra_400';
    final preset = FilmPreset.findById(presetId);

    return FilmRecipe(
      id: json['id']?.toString() ?? 'recipe_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? preset.name,
      preset: preset,
      isCustom: json['isCustom'] == true,
      author: json['author']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      // Continuous
      exposure: _toDouble(json['exposure'], preset.defaultExposure),
      contrast: _toDouble(json['contrast'], preset.defaultContrast),
      warmth: _toDouble(json['warmth'], preset.defaultWarmth),
      tint: _toDouble(json['tint'], preset.defaultTint),
      highlights: _toDouble(json['highlights'], preset.defaultHighlights),
      shadows: _toDouble(json['shadows'], preset.defaultShadows),
      grainAmount: _toDouble(json['grainAmount'], preset.defaultGrain),
      grainSizeValue: _toDouble(json['grainSizeValue'], preset.defaultGrainSize),
      fade: _toDouble(json['fade'], preset.defaultFade),
      vignette: _toDouble(json['vignette'], preset.defaultVignette),
      // Fuji
      dynamicRange: json['dynamicRange']?.toString() ?? 'DR200',
      highlightTone: _toDouble(json['highlightTone'], 0.0),
      shadowTone: _toDouble(json['shadowTone'], 0.0),
      colorSaturation: _toDouble(json['colorSaturation'], 0.0),
      sharpness: _toDouble(json['sharpness'], 0.0),
      noiseReduction: _toDouble(json['noiseReduction'], -2.0),
      clarity: _toDouble(json['clarity'], 0.0),
      grainRoughness: _parseEnum(GrainRoughness.values, json['grainRoughness'], GrainRoughness.weak),
      grainSize: _parseEnum(GrainSize.values, json['grainSize'], GrainSize.small),
      colorChromeEffect: _parseEnum(ColorChromeState.values, json['colorChromeEffect'], ColorChromeState.off),
      colorChromeFxBlue: _parseEnum(ColorChromeState.values, json['colorChromeFxBlue'], ColorChromeState.off),
      whiteBalanceMode: _parseEnum(WhiteBalanceMode.values, json['whiteBalanceMode'], WhiteBalanceMode.auto),
      wbColorTemp: _toInt(json['wbColorTemp'], 5500),
      wbShiftR: _toInt(json['wbShiftR'], 0),
      wbShiftB: _toInt(json['wbShiftB'], 0),
      customLutId: json['customLutId']?.toString(),
    );
  }

  /// Parses Fuji X Weekly formatted strings into a [FilmRecipe].
  /// Example inputs from community X Weekly articles:
  /// {
  ///   "Title": "Kodak Portra 400 v2",
  ///   "Film Simulation": "Classic Chrome",
  ///   "Dynamic Range": "DR400",
  ///   "Grain Effect": "Strong, Small",
  ///   "Color Chrome Effect": "Strong",
  ///   "Color Chrome FX Blue": "Weak",
  ///   "White Balance": "Auto, +2 Red & -4 Blue",
  ///   "Highlight": "-1",
  ///   "Shadow": "+2",
  ///   "Color": "+2",
  ///   "Sharpness": "-2",
  ///   "Noise Reduction": "-4",
  ///   "Clarity": "-3",
  ///   "Exposure Compensation": "+1/3 to +2/3"
  /// }
  static FilmRecipe parseXWeeklyFormat(Map<String, dynamic> map) {
    // 1. Match Film Simulation
    final simString = (map['Film Simulation'] ?? map['Simulation'] ?? map['Film Base'] ?? '').toString().toLowerCase();
    FilmPreset matchedPreset = FilmPreset.classicChrome;
    if (simString.contains('portra')) {
      matchedPreset = FilmPreset.portra400;
    } else if (simString.contains('tri-x') || simString.contains('trix') || simString.contains('black') || simString.contains('acros')) {
      matchedPreset = FilmPreset.triX400;
    } else if (simString.contains('cinestill') || simString.contains('800t')) {
      matchedPreset = FilmPreset.cinestill800T;
    } else if (simString.contains('ektachrome') || simString.contains('velvia') || simString.contains('slide')) {
      matchedPreset = FilmPreset.ektachromeE100;
    } else if (simString.contains('gold')) {
      matchedPreset = FilmPreset.gold200;
    } else if (simString.contains('hp5') || simString.contains('ilford')) {
      matchedPreset = FilmPreset.ilfordHP5;
    }

    // 2. Parse Dynamic Range
    final drString = (map['Dynamic Range'] ?? map['DR'] ?? 'DR200').toString();

    // 3. Parse Grain Effect: e.g. "Strong, Small" or "Weak, Large" or "Off"
    final grainRaw = (map['Grain Effect'] ?? map['Grain'] ?? '').toString().toLowerCase();
    GrainRoughness roughness = GrainRoughness.weak;
    GrainSize grainSize = GrainSize.small;
    if (grainRaw.contains('off')) {
      roughness = GrainRoughness.off;
    } else if (grainRaw.contains('strong')) {
      roughness = GrainRoughness.strong;
    }
    if (grainRaw.contains('large')) {
      grainSize = GrainSize.large;
    }

    // 4. Color Chrome
    final ccRaw = (map['Color Chrome Effect'] ?? '').toString().toLowerCase();
    final ColorChromeState ccEffect = ccRaw.contains('strong')
        ? ColorChromeState.strong
        : (ccRaw.contains('weak') ? ColorChromeState.weak : ColorChromeState.off);

    final ccBlueRaw = (map['Color Chrome FX Blue'] ?? '').toString().toLowerCase();
    final ColorChromeState ccBlue = ccBlueRaw.contains('strong')
        ? ColorChromeState.strong
        : (ccBlueRaw.contains('weak') ? ColorChromeState.weak : ColorChromeState.off);

    // 5. White Balance: e.g. "Auto, +2 Red & -4 Blue"
    final wbRaw = (map['White Balance'] ?? map['WB'] ?? 'Auto').toString();
    WhiteBalanceMode wbMode = WhiteBalanceMode.auto;
    final lowerWb = wbRaw.toLowerCase();
    if (lowerWb.contains('daylight')) wbMode = WhiteBalanceMode.daylight;
    if (lowerWb.contains('shade')) wbMode = WhiteBalanceMode.shade;
    if (lowerWb.contains('fluorescent')) wbMode = WhiteBalanceMode.fluorescent;
    if (lowerWb.contains('incandescent') || lowerWb.contains('tungsten')) wbMode = WhiteBalanceMode.incandescent;
    if (lowerWb.contains('kelvin') || lowerWb.contains('k')) wbMode = WhiteBalanceMode.kelvin;

    int shiftR = 0;
    int shiftB = 0;
    final rMatch = RegExp(r'([+-]?\d+)\s*(?:Red|R)', caseSensitive: false).firstMatch(wbRaw);
    if (rMatch != null) shiftR = int.tryParse(rMatch.group(1)!) ?? 0;

    final bMatch = RegExp(r'([+-]?\d+)\s*(?:Blue|B)', caseSensitive: false).firstMatch(wbRaw);
    if (bMatch != null) shiftB = int.tryParse(bMatch.group(1)!) ?? 0;

    // 6. Highlight & Shadow tones
    final highlightTone = _parseNumberString(map['Highlight'] ?? map['Highlight Tone']);
    final shadowTone = _parseNumberString(map['Shadow'] ?? map['Shadow Tone']);
    final colorSat = _parseNumberString(map['Color']);
    final sharpness = _parseNumberString(map['Sharpness']);
    final noiseReduction = _parseNumberString(map['Noise Reduction'] ?? map['NR'], fallback: -2.0);
    final clarity = _parseNumberString(map['Clarity']);

    // 7. Exposure compensation
    final expCompRaw = (map['Exposure Compensation'] ?? map['Exposure'] ?? '0').toString();
    double exposure = 0.0;
    if (expCompRaw.contains('1/3')) exposure += 0.33;
    if (expCompRaw.contains('2/3')) exposure += 0.67;
    if (expCompRaw.contains('+1')) exposure += 1.0;
    if (expCompRaw.contains('-1')) exposure -= 1.0;

    final title = (map['Title'] ?? map['Name'] ?? 'Fuji Recipe').toString();

    // Map Fuji values to Cheesera continuous color rendering
    final double computedWarmth = (shiftR * 0.05 - shiftB * 0.04).clamp(-1.0, 1.0);
    final double computedGrain = roughness == GrainRoughness.strong
        ? 0.55
        : (roughness == GrainRoughness.weak ? 0.28 : 0.0);

    return FilmRecipe(
      id: 'xweekly_${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      preset: matchedPreset,
      isCustom: true,
      author: map['Author']?.toString() ?? 'Fuji X Weekly',
      notes: map['Notes']?.toString() ?? 'Imported from Fuji X Weekly community recipe.',
      exposure: exposure,
      contrast: (highlightTone + shadowTone) * 0.08,
      warmth: computedWarmth,
      tint: (shiftR * 0.02).clamp(-1.0, 1.0),
      highlights: highlightTone * 0.1,
      shadows: shadowTone * 0.1,
      grainAmount: computedGrain,
      grainSizeValue: grainSize == GrainSize.large ? 1.4 : 1.0,
      fade: 0.06,
      vignette: 0.15,
      // Fuji camera params
      dynamicRange: drString,
      highlightTone: highlightTone,
      shadowTone: shadowTone,
      colorSaturation: colorSat,
      sharpness: sharpness,
      noiseReduction: noiseReduction,
      clarity: clarity,
      grainRoughness: roughness,
      grainSize: grainSize,
      colorChromeEffect: ccEffect,
      colorChromeFxBlue: ccBlue,
      whiteBalanceMode: wbMode,
      wbShiftR: shiftR,
      wbShiftB: shiftB,
      customLutId: map['Custom LUT']?.toString(),
    );
  }

  /// Serializes a list of recipes into a JSON string.
  static String serializeList(List<FilmRecipe> recipes) {
    final list = recipes.map(toJson).toList();
    return jsonEncode(list);
  }

  /// Deserializes a JSON string into a list of [FilmRecipe].
  static List<FilmRecipe> deserializeList(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static double _toDouble(dynamic val, double fallback) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? fallback;
  }

  static int _toInt(dynamic val, int fallback) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? fallback;
  }

  static double _parseNumberString(dynamic val, {double fallback = 0.0}) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    final str = val.toString().replaceAll('+', '').trim();
    return double.tryParse(str) ?? fallback;
  }

  static T _parseEnum<T extends Enum>(List<T> values, dynamic val, T fallback) {
    if (val == null) return fallback;
    final str = val.toString().toLowerCase();
    for (final e in values) {
      if (e.name.toLowerCase() == str) return e;
    }
    return fallback;
  }
}

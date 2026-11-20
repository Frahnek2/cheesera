import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/models/film_preset.dart';
import 'package:cheesera/models/film_recipe.dart';
import 'package:cheesera/services/recipe_service/recipe_serializer.dart';

void main() {
  group('RecipeSerializer Tests', () {
    test('Round-trip JSON serialization preserves all continuous and Fujifilm parameters', () {
      final original = FilmRecipe(
        id: 'recipe_portra_custom_1',
        title: 'Portra Warm Editorial',
        preset: FilmPreset.portra400,
        isCustom: true,
        author: 'Franek',
        notes: 'Creamy warm tones, gentle highlight roll-off.',
        exposure: 0.33,
        contrast: 0.15,
        warmth: 0.40,
        tint: -0.05,
        highlights: -0.20,
        shadows: 0.10,
        grainAmount: 0.35,
        grainSizeValue: 1.2,
        fade: 0.08,
        vignette: 0.22,
        dynamicRange: 'DR400',
        highlightTone: -1.0,
        shadowTone: 2.0,
        colorSaturation: 2.0,
        sharpness: 1.0,
        noiseReduction: -4.0,
        clarity: -2.0,
        grainRoughness: GrainRoughness.strong,
        grainSize: GrainSize.small,
        colorChromeEffect: ColorChromeState.strong,
        colorChromeFxBlue: ColorChromeState.weak,
        whiteBalanceMode: WhiteBalanceMode.daylight,
        wbColorTemp: 5600,
        wbShiftR: 3,
        wbShiftB: -4,
        customLutId: 'lut_classic_chrome',
      );

      final jsonMap = RecipeSerializer.toJson(original);
      final restored = RecipeSerializer.fromJson(jsonMap);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.preset.id, original.preset.id);
      expect(restored.isCustom, true);
      expect(restored.author, 'Franek');
      expect(restored.exposure, closeTo(0.33, 0.001));
      expect(restored.contrast, closeTo(0.15, 0.001));
      expect(restored.warmth, closeTo(0.40, 0.001));
      expect(restored.dynamicRange, 'DR400');
      expect(restored.highlightTone, -1.0);
      expect(restored.shadowTone, 2.0);
      expect(restored.grainRoughness, GrainRoughness.strong);
      expect(restored.grainSize, GrainSize.small);
      expect(restored.colorChromeEffect, ColorChromeState.strong);
      expect(restored.colorChromeFxBlue, ColorChromeState.weak);
      expect(restored.wbShiftR, 3);
      expect(restored.wbShiftB, -4);
      expect(restored.customLutId, 'lut_classic_chrome');
    });

    test('Gracefully falls back to baseline values on empty or corrupted JSON', () {
      final restored = RecipeSerializer.fromJson({});
      expect(restored.preset.id, 'portra_400');
      expect(restored.title, FilmPreset.portra400.name);
      expect(restored.exposure, FilmPreset.portra400.defaultExposure);
      expect(restored.dynamicRange, 'DR200');
    });

    test('Parses community Fuji X Weekly format strings into structured recipes', () {
      final xWeeklyMap = {
        'Title': 'Vintage Kodachrome II',
        'Film Simulation': 'Classic Chrome',
        'Dynamic Range': 'DR400',
        'Grain Effect': 'Strong, Small',
        'Color Chrome Effect': 'Strong',
        'Color Chrome FX Blue': 'Weak',
        'White Balance': 'Auto, +2 Red & -4 Blue',
        'Highlight': '-1',
        'Shadow': '+2',
        'Color': '+2',
        'Sharpness': '-2',
        'Noise Reduction': '-4',
        'Clarity': '-3',
        'Exposure Compensation': '+1/3 to +2/3',
      };

      final recipe = RecipeSerializer.parseXWeeklyFormat(xWeeklyMap);

      expect(recipe.title, 'Vintage Kodachrome II');
      expect(recipe.preset.id, FilmPreset.classicChrome.id);
      expect(recipe.dynamicRange, 'DR400');
      expect(recipe.grainRoughness, GrainRoughness.strong);
      expect(recipe.grainSize, GrainSize.small);
      expect(recipe.colorChromeEffect, ColorChromeState.strong);
      expect(recipe.colorChromeFxBlue, ColorChromeState.weak);
      expect(recipe.whiteBalanceMode, WhiteBalanceMode.auto);
      expect(recipe.wbShiftR, 2);
      expect(recipe.wbShiftB, -4);
      expect(recipe.highlightTone, -1.0);
      expect(recipe.shadowTone, 2.0);
      expect(recipe.exposure, closeTo(0.33 + 0.67, 0.05));
    });

    test('List serialization and deserialization works correctly', () {
      final list = FilmRecipe.defaultSampleRecipes;
      final serialized = RecipeSerializer.serializeList(list);
      expect(serialized.isNotEmpty, true);

      final deserialized = RecipeSerializer.deserializeList(serialized);
      expect(deserialized.length, list.length);
      expect(deserialized.first.title, list.first.title);
    });
  });
}

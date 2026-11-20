import 'dart:math' as math;
import '../../models/film_preset.dart';
import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';
import 'image_feature_extractor.dart';
import 'llm_models.dart';

/// Photographic expert heuristic engine used when no on-device GGUF model is loaded.
/// Evaluates color temperature, contrast, dynamic range, and semantic criteria.
class HeuristicCurationEngine {
  const HeuristicCurationEngine();

  /// Suggests the best recipe for an individual photo with human-like photographic rationale.
  RecipeSuggestionResult suggestRecipe({
    required PhotoItem photo,
    required List<FilmRecipe> availableRecipes,
    ImageAnalysisMetadata? analysis,
  }) {
    final meta = analysis ?? ImageFeatureExtractor.analyze(photo.originalBytes);

    FilmPreset chosenPreset;
    String reason;
    final List<String> matchedAttributes = [];

    if (meta.lightingAtmosphere.contains('Night') || (meta.averageLuminance < 0.30 && meta.warmthScore < 0)) {
      chosenPreset = FilmPreset.cinestill800T;
      reason = 'Tungsten balance with distinctive teal shadows and halation glow beautifully complements low-key neon and street night lights.';
      matchedAttributes.addAll(['Low-key Night', 'Teal Shadow Cast', 'Incandescent Lights']);
    } else if (meta.lightingAtmosphere.contains('Golden Hour') || meta.warmthScore > 0.22) {
      chosenPreset = FilmPreset.portra400;
      reason = 'Warm late-afternoon color temperature (~${meta.colorTemperatureK.round()}K) and soft highlight roll-off pair naturally with Portra\'s pastel skin tones.';
      matchedAttributes.addAll(['Golden Hour', 'Warm Highlights', 'Gentle Contrast']);
    } else if (meta.contrastRatio > 0.70 && meta.saturationLevel < 0.40) {
      chosenPreset = FilmPreset.triX400;
      reason = 'High dynamic contrast ratio (${(meta.contrastRatio * 100).round()}%) and strong structural shadows are enhanced by gritty silver halide grain and deep documentary blacks.';
      matchedAttributes.addAll(['High Microcontrast', 'Deep Shadows', 'Graphic Architecture']);
    } else if (meta.lightingAtmosphere.contains('Portrait')) {
      chosenPreset = FilmPreset.cheeseraVelvet;
      reason = 'Creamy midtones and velvety shadow floor provide a smooth editorial finish for studio and portraiture subjects.';
      matchedAttributes.addAll(['Balanced Skin Tones', 'Creamy Roll-Off', 'Studio Lighting']);
    } else if (meta.saturationLevel > 0.60) {
      chosenPreset = FilmPreset.ektachromeE100;
      reason = 'Vibrant color saturation and clean daylight midtones reproduce vivid blues and clean whites like iconic reversal slide film.';
      matchedAttributes.addAll(['Vibrant Saturation', 'Clean White Point', 'Slide Clarity']);
    } else {
      chosenPreset = FilmPreset.classicChrome;
      reason = 'Subtle desaturation and restrained documentary tonality preserve natural texture without color exaggeration.';
      matchedAttributes.addAll(['Documentary Mood', 'Muted Saturation', 'Balanced Daylight']);
    }

    // Match against available recipes or build from preset
    final matchedRecipe = availableRecipes.firstWhere(
      (r) => r.preset.id == chosenPreset.id,
      orElse: () => FilmRecipe.fromPreset(chosenPreset),
    );

    return RecipeSuggestionResult(
      suggestedRecipe: matchedRecipe,
      reasoning: reason,
      confidence: 0.90,
      matchedAttributes: matchedAttributes,
      backendUsed: LlmBackendType.heuristicFallback,
    );
  }

  /// Curates and ranks a batch of photos according to natural language criteria.
  BatchCurationResult curateBatch({
    required List<PhotoItem> photos,
    required String userPrompt,
    required List<FilmRecipe> availableRecipes,
    int? targetCount,
  }) {
    if (photos.isEmpty) {
      return BatchCurationResult(
        prompt: userPrompt,
        rankedPhotos: [],
        selectedTopPicks: [],
        summaryReasoning: 'No photos provided to curate.',
        backendUsed: LlmBackendType.heuristicFallback,
      );
    }

    final lowerPrompt = userPrompt.toLowerCase();
    final List<Map<String, dynamic>> scoredList = [];

    for (final photo in photos) {
      final meta = ImageFeatureExtractor.analyze(photo.originalBytes);
      double score = 0.50; // Base score
      final List<String> reasons = [];

      // Evaluate prompt intents
      if (lowerPrompt.contains('warm') || lowerPrompt.contains('golden') || lowerPrompt.contains('sunset')) {
        if (meta.warmthScore > 0.15) {
          score += 0.35 * (meta.warmthScore.clamp(0.0, 1.0));
          reasons.add('Strong golden warmth (${meta.colorTemperatureK.round()}K)');
        } else {
          score -= 0.15;
        }
      }

      if (lowerPrompt.contains('street') || lowerPrompt.contains('punchy') || lowerPrompt.contains('contrast')) {
        if (meta.contrastRatio > 0.55) {
          score += 0.30 * meta.contrastRatio;
          reasons.add('Punchy dynamic range & shadow structure');
        }
      }

      if (lowerPrompt.contains('night') || lowerPrompt.contains('neon') || lowerPrompt.contains('moody')) {
        if (meta.averageLuminance < 0.35) {
          score += 0.35;
          reasons.add('Atmospheric low-key lighting');
        }
      }

      if (lowerPrompt.contains('minimalist') || lowerPrompt.contains('composition') || lowerPrompt.contains('clean')) {
        if (meta.contrastRatio > 0.40 && (meta.averageLuminance - 0.5).abs() < 0.3) {
          score += 0.25;
          reasons.add('Balanced negative space & clean tonal spread');
        }
      }

      if (lowerPrompt.contains('bw') || lowerPrompt.contains('black and white') || lowerPrompt.contains('monochrome')) {
        if (meta.contrastRatio > 0.60) {
          score += 0.30;
          reasons.add('High tonal gradation ideal for silver halide monochrome');
        }
      }

      final suggestion = suggestRecipe(
        photo: photo,
        availableRecipes: availableRecipes,
        analysis: meta,
      );

      final finalScore = score.clamp(0.10, 0.99);
      final reasonStr = reasons.isNotEmpty
          ? reasons.join(', ')
          : 'Well-exposed frame with ${meta.lightingAtmosphere} atmosphere.';

      scoredList.add({
        'photo': photo,
        'score': finalScore,
        'reason': reasonStr,
        'recipe': suggestion.suggestedRecipe,
      });
    }

    // Sort descending by score
    scoredList.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    final int pickCount = targetCount ?? math.max(1, (photos.length / 2).ceil());
    final List<CuratedPhotoRank> ranked = [];
    final List<PhotoItem> topPicks = [];

    for (int i = 0; i < scoredList.length; i++) {
      final entry = scoredList[i];
      final photo = entry['photo'] as PhotoItem;
      final rank = i + 1;
      final score = entry['score'] as double;
      final reason = entry['reason'] as String;
      final recipe = entry['recipe'] as FilmRecipe;

      ranked.add(CuratedPhotoRank(
        photo: photo,
        rank: rank,
        score: score,
        reason: reason,
        recommendedRecipe: recipe,
      ));

      if (i < pickCount) {
        topPicks.add(photo.copyWith(recipe: recipe));
      }
    }

    final summary = 'Evaluated ${photos.length} frames against criteria "$userPrompt". Selected $pickCount top candidates matching lighting, tonal balance, and compositional clarity.';

    return BatchCurationResult(
      prompt: userPrompt,
      rankedPhotos: ranked,
      selectedTopPicks: topPicks,
      summaryReasoning: summary,
      backendUsed: LlmBackendType.heuristicFallback,
    );
  }
}

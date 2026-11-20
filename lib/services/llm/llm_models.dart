import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';

enum LlmBackendType {
  onDeviceGguf,       // Local llama.cpp / GGUF model via on-device inference
  mediaPipeGenAi,     // Google MediaPipe on-device LLM Inference
  heuristicFallback,  // Built-in photographic rules engine (active when no model file loaded)
}

/// Visual and histogram analysis of an image extracted on-device.
class ImageAnalysisMetadata {
  final double averageLuminance; // 0.0 (dark) to 1.0 (bright)
  final double colorTemperatureK; // Estimated Kelvin: 2500K (warm) to 9000K (cool)
  final double warmthScore; // -1.0 (cool/blue) to +1.0 (warm/amber)
  final double contrastRatio; // Dynamic range spread (0.0 to 1.0)
  final double saturationLevel; // 0.0 (monochrome) to 1.0 (vivid)
  final String lightingAtmosphere; // "Golden Hour", "Night/Tungsten", "Overcast/Soft", "High Contrast Noon", "Studio"
  final List<String> dominantTones; // e.g. ["Warm Amber", "Deep Cyan", "Skin Tone Midtones"]

  const ImageAnalysisMetadata({
    required this.averageLuminance,
    required this.colorTemperatureK,
    required this.warmthScore,
    required this.contrastRatio,
    required this.saturationLevel,
    required this.lightingAtmosphere,
    required this.dominantTones,
  });

  Map<String, dynamic> toJson() => {
    'averageLuminance': averageLuminance,
    'colorTemperatureK': colorTemperatureK,
    'warmthScore': warmthScore,
    'contrastRatio': contrastRatio,
    'saturationLevel': saturationLevel,
    'lightingAtmosphere': lightingAtmosphere,
    'dominantTones': dominantTones,
  };
}

/// Result returned when suggesting a film simulation / recipe.
class RecipeSuggestionResult {
  final FilmRecipe suggestedRecipe;
  final String reasoning;
  final double confidence;
  final List<String> matchedAttributes;
  final LlmBackendType backendUsed;

  const RecipeSuggestionResult({
    required this.suggestedRecipe,
    required this.reasoning,
    this.confidence = 0.85,
    this.matchedAttributes = const [],
    required this.backendUsed,
  });
}

/// Individual scored item within a batch curation request.
class CuratedPhotoRank {
  final PhotoItem photo;
  final int rank; // 1 = best
  final double score; // 0.0 to 1.0
  final String reason;
  final FilmRecipe recommendedRecipe;

  const CuratedPhotoRank({
    required this.photo,
    required this.rank,
    required this.score,
    required this.reason,
    required this.recommendedRecipe,
  });
}

/// Result returned when ranking and curating a batch of photos according to a user prompt.
class BatchCurationResult {
  final String prompt;
  final List<CuratedPhotoRank> rankedPhotos;
  final List<PhotoItem> selectedTopPicks;
  final String summaryReasoning;
  final LlmBackendType backendUsed;

  const BatchCurationResult({
    required this.prompt,
    required this.rankedPhotos,
    required this.selectedTopPicks,
    required this.summaryReasoning,
    required this.backendUsed,
  });
}

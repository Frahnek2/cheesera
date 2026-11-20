import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';
import 'llm_models.dart';

/// Clean interface for on-device local LLM curation and photographic recipe suggestion.
abstract class LlmCurationService {
  /// Whether an on-device local model file (.gguf or .bin) is currently loaded into memory.
  bool get isModelLoaded;

  /// Human-readable name of the active model (or 'Heuristic Fallback Engine').
  String get activeModelName;

  /// Current active backend type (onDeviceGguf vs heuristicFallback).
  LlmBackendType get activeBackend;

  /// Suggests the best analog film simulation/recipe for a photo with a photographic rationale.
  Future<RecipeSuggestionResult> suggestRecipe({
    required PhotoItem photo,
    required List<FilmRecipe> availableRecipes,
    ImageAnalysisMetadata? precomputedAnalysis,
  });

  /// Curates and ranks a batch of photos according to natural language criteria
  /// (e.g. "warm golden hour vibe", "punchy street colors", "minimalist compositions").
  Future<BatchCurationResult> curateBatch({
    required List<PhotoItem> photos,
    required String userPrompt,
    required List<FilmRecipe> availableRecipes,
    int? targetCount,
  });

  /// Loads an on-device GGUF / MediaPipe model from disk path.
  Future<bool> loadLocalModel({
    required String modelFilePath,
    String? modelDisplayName,
  });

  /// Unloads the local model from memory, returning to the heuristic fallback engine.
  Future<void> unloadModel();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/core/utils/sample_images_data.dart';
import 'package:cheesera/models/film_preset.dart';
import 'package:cheesera/models/film_recipe.dart';
import 'package:cheesera/models/photo_item.dart';
import 'package:cheesera/services/llm/default_llm_curation_service.dart';
import 'package:cheesera/services/llm/image_feature_extractor.dart';
import 'package:cheesera/services/llm/llm_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('On-Device Local LLM & Heuristic Curation Tests', () {
    late DefaultLlmCurationService service;
    late List<FilmRecipe> recipes;

    setUp(() {
      service = DefaultLlmCurationService();
      recipes = FilmRecipe.defaultSampleRecipes;
    });

    test('Initial state: no model loaded, activeBackend is heuristicFallback', () {
      expect(service.isModelLoaded, isFalse);
      expect(service.activeBackend, LlmBackendType.heuristicFallback);
      expect(service.activeModelName, contains('Heuristic'));
    });

    test('ImageFeatureExtractor analyzes golden coast as warm/golden hour', () {
      final bytes = SampleImagesData.getGoldenCoast();
      final analysis = ImageFeatureExtractor.analyze(bytes);

      expect(analysis.warmthScore, greaterThan(0.0));
      expect(analysis.averageLuminance, greaterThan(0.3));
      expect(analysis.lightingAtmosphere, contains('Golden Hour'));
    });

    test('ImageFeatureExtractor analyzes midnight neon as low-key night/teal', () {
      final bytes = SampleImagesData.getMidnightNeon();
      final analysis = ImageFeatureExtractor.analyze(bytes);

      expect(analysis.averageLuminance, lessThan(0.35));
      expect(analysis.lightingAtmosphere, contains('Night'));
      expect(analysis.dominantTones, contains('Teal Shadows'));
    });

    test('suggestRecipe recommends Portra 400 for Golden Coast image with reason', () async {
      final photo = PhotoItem(
        id: 'golden_test',
        title: 'Golden Sunset',
        originalBytes: SampleImagesData.getGoldenCoast(),
        recipe: FilmRecipe.fromPreset(FilmPreset.classicChrome),
        createdAt: DateTime.now(),
      );

      final result = await service.suggestRecipe(
        photo: photo,
        availableRecipes: recipes,
      );

      expect(result.suggestedRecipe.preset.id, FilmPreset.portra400.id);
      expect(result.reasoning.toLowerCase(), contains('warm'));
      expect(result.confidence, greaterThanOrEqualTo(0.80));
      expect(result.backendUsed, LlmBackendType.heuristicFallback);
    });

    test('suggestRecipe recommends CineStill 800T for Midnight Neon image with reason', () async {
      final photo = PhotoItem(
        id: 'neon_test',
        title: 'Midnight Tokyo',
        originalBytes: SampleImagesData.getMidnightNeon(),
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400),
        createdAt: DateTime.now(),
      );

      final result = await service.suggestRecipe(
        photo: photo,
        availableRecipes: recipes,
      );

      expect(result.suggestedRecipe.preset.id, FilmPreset.cinestill800T.id);
      expect(result.reasoning.toLowerCase(), contains('tungsten'));
      expect(result.matchedAttributes, contains('Teal Shadow Cast'));
    });

    test('curateBatch ranks Golden Coast #1 when user prompts "warm golden hour vibe"', () async {
      final photoGolden = PhotoItem(
        id: 'p_golden',
        title: 'Coast Sunset',
        originalBytes: SampleImagesData.getGoldenCoast(),
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400),
        createdAt: DateTime.now(),
      );

      final photoNeon = PhotoItem(
        id: 'p_neon',
        title: 'Night Street',
        originalBytes: SampleImagesData.getMidnightNeon(),
        recipe: FilmRecipe.fromPreset(FilmPreset.cinestill800T),
        createdAt: DateTime.now(),
      );

      final photoStudio = PhotoItem(
        id: 'p_studio',
        title: 'Studio Monolith',
        originalBytes: SampleImagesData.getStudioPortrait(),
        recipe: FilmRecipe.fromPreset(FilmPreset.triX400),
        createdAt: DateTime.now(),
      );

      final result = await service.curateBatch(
        photos: [photoNeon, photoGolden, photoStudio],
        userPrompt: 'warm golden hour vibe',
        availableRecipes: recipes,
        targetCount: 1,
      );

      expect(result.selectedTopPicks.length, 1);
      expect(result.selectedTopPicks.first.id, 'p_golden');
      expect(result.rankedPhotos.first.photo.id, 'p_golden');
      expect(result.rankedPhotos.first.rank, 1);
      expect(result.rankedPhotos.first.reason.toLowerCase(), contains('golden'));
    });

    test('curateBatch ranks Midnight Neon #1 when user prompts "moody night neon"', () async {
      final photoGolden = PhotoItem(
        id: 'p_golden',
        title: 'Coast Sunset',
        originalBytes: SampleImagesData.getGoldenCoast(),
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400),
        createdAt: DateTime.now(),
      );

      final photoNeon = PhotoItem(
        id: 'p_neon',
        title: 'Night Street',
        originalBytes: SampleImagesData.getMidnightNeon(),
        recipe: FilmRecipe.fromPreset(FilmPreset.cinestill800T),
        createdAt: DateTime.now(),
      );

      final result = await service.curateBatch(
        photos: [photoGolden, photoNeon],
        userPrompt: 'moody night neon',
        availableRecipes: recipes,
      );

      expect(result.rankedPhotos.first.photo.id, 'p_neon');
      expect(result.rankedPhotos.first.recommendedRecipe.preset.id, FilmPreset.cinestill800T.id);
    });

    test('Model load and unload lifecycle updates service state', () async {
      expect(service.isModelLoaded, isFalse);

      final loaded = await service.loadLocalModel(
        modelFilePath: '/mock/path/SmolLM2-1.7B-Q4_K_M.gguf',
        modelDisplayName: 'SmolLM2 1.7B',
      );

      expect(loaded, isTrue);
      expect(service.isModelLoaded, isTrue);
      expect(service.activeModelName, 'SmolLM2 1.7B');
      expect(service.activeBackend, LlmBackendType.onDeviceGguf);

      await service.unloadModel();
      expect(service.isModelLoaded, isFalse);
      expect(service.activeBackend, LlmBackendType.heuristicFallback);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/models/film_preset.dart';
import 'package:cheesera/models/film_recipe.dart';
import 'package:cheesera/services/recipe_service/recipe_cache_storage.dart';
import 'package:cheesera/services/recipe_service/recipe_provider.dart';
import 'package:cheesera/services/recipe_service/recipe_remote_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('RecipeProvider & Offline Fallback Tests', () {
    test('Successful remote sync merges remote recipes and caches them offline', () async {
      const mockPayload = '''
[
  {
    "id": "xweekly_cinestill_street",
    "title": "CineStill Street 800",
    "presetId": "cinestill_800t",
    "isCustom": true,
    "dynamicRange": "DR400",
    "highlightTone": 1.0,
    "shadowTone": -1.0
  }
]
''';

      final adapter = XWeeklyRecipeAdapter(mockResponsePayload: mockPayload);
      final cacheStorage = RecipeCacheStorage();
      final provider = RecipeProvider(
        remoteAdapter: adapter,
        cacheStorage: cacheStorage,
      );

      await provider.initialize(syncRemote: true);

      expect(provider.syncStatus, RecipeSyncStatus.success);
      expect(provider.recipes.any((r) => r.id == 'xweekly_cinestill_street'), isTrue);

      // Verify offline cache has been populated
      final cached = await cacheStorage.loadCachedRecipes();
      expect(cached, isNotNull);
      expect(cached!.any((r) => r.id == 'xweekly_cinestill_street'), isTrue);
    });

    test('Network error falls back gracefully to offline cached recipes', () async {
      final cacheStorage = RecipeCacheStorage();
      // Pre-seed offline cache with a recipe
      final cachedRecipe = FilmRecipe(
        id: 'cached_offline_recipe',
        title: 'Offline Vault Portra',
        preset: FilmPreset.portra400,
        isCustom: true,
      );
      await cacheStorage.saveRecipes([cachedRecipe]);

      // Adapter configured to simulate network failure
      final failingAdapter = XWeeklyRecipeAdapter(simulateNetworkError: true);
      final provider = RecipeProvider(
        remoteAdapter: failingAdapter,
        cacheStorage: cacheStorage,
      );

      await provider.initialize(syncRemote: true);

      // Should fall back to offline cache
      expect(provider.syncStatus, RecipeSyncStatus.offlineFallback);
      expect(provider.lastErrorMessage, contains('SocketException'));
      expect(provider.recipes.any((r) => r.id == 'cached_offline_recipe'), isTrue);
    });

    test('Network error with empty cache falls back gracefully to built-in defaults', () async {
      final cacheStorage = RecipeCacheStorage();
      await cacheStorage.clearCache();

      final failingAdapter = XWeeklyRecipeAdapter(simulateNetworkError: true);
      final provider = RecipeProvider(
        remoteAdapter: failingAdapter,
        cacheStorage: cacheStorage,
      );

      await provider.initialize(syncRemote: true);

      expect(provider.syncStatus, RecipeSyncStatus.offlineFallback);
      expect(provider.recipes.isNotEmpty, isTrue);
      expect(provider.recipes.any((r) => r.preset.id == 'portra_400'), isTrue);
      expect(provider.recipes.any((r) => r.preset.id == 'trix_400'), isTrue);
    });

    test('Saving and deleting custom recipes updates cache and notifies listeners', () async {
      final cacheStorage = RecipeCacheStorage();
      final provider = RecipeProvider(
        remoteAdapter: XWeeklyRecipeAdapter(simulateNetworkError: true),
        cacheStorage: cacheStorage,
      );

      await provider.initialize(syncRemote: false);

      final custom = FilmRecipe(
        id: 'my_unique_custom_recipe',
        title: 'My Custom Chrome',
        preset: FilmPreset.classicChrome,
        highlightTone: 2.0,
      );

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.saveCustomRecipe(custom);
      expect(provider.recipes.any((r) => r.id == 'my_unique_custom_recipe'), isTrue);
      expect(provider.getRecipeById('my_unique_custom_recipe').highlightTone, 2.0);
      expect(notifyCount, greaterThan(0));

      // Delete custom recipe
      await provider.deleteCustomRecipe('my_unique_custom_recipe');
      expect(provider.recipes.any((r) => r.id == 'my_unique_custom_recipe'), isFalse);
    });
  });
}

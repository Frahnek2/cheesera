import 'package:flutter/foundation.dart';
import '../../models/film_preset.dart';
import '../../models/film_recipe.dart';
import 'recipe_cache_storage.dart';
import 'recipe_remote_adapter.dart';

enum RecipeSyncStatus {
  idle,
  syncing,
  success,
  offlineFallback,
  error,
}

/// Orchestrates recipe fetching, offline caching, and graceful fallbacks.
/// Provides a reactive state model (via [ChangeNotifier]) for UI consumption.
class RecipeProvider extends ChangeNotifier {
  final RecipeRemoteAdapter remoteAdapter;
  final RecipeCacheStorage cacheStorage;

  List<FilmRecipe> _recipes = [];
  RecipeSyncStatus _syncStatus = RecipeSyncStatus.idle;
  String? _lastErrorMessage;
  DateTime? _lastSyncTime;

  RecipeProvider({
    RecipeRemoteAdapter? remoteAdapter,
    RecipeCacheStorage? cacheStorage,
    List<FilmRecipe>? initialRecipes,
  })  : remoteAdapter = remoteAdapter ?? XWeeklyRecipeAdapter(),
        cacheStorage = cacheStorage ?? RecipeCacheStorage() {
    _recipes = initialRecipes != null
        ? List.from(initialRecipes)
        : List.from(FilmRecipe.defaultSampleRecipes);
  }

  List<FilmRecipe> get recipes => List.unmodifiable(_recipes);
  RecipeSyncStatus get syncStatus => _syncStatus;
  String? get lastErrorMessage => _lastErrorMessage;
  DateTime? get lastSyncTime => _lastSyncTime;

  List<FilmRecipe> get builtInRecipes =>
      _recipes.where((r) => !r.isCustom && !r.id.startsWith('xweekly_')).toList();

  List<FilmRecipe> get customRecipes =>
      _recipes.where((r) => r.isCustom && !r.id.startsWith('xweekly_')).toList();

  List<FilmRecipe> get communityRecipes =>
      _recipes.where((r) => r.id.startsWith('xweekly_')).toList();

  /// Initializes the provider:
  /// 1. Tries to load from offline cache.
  /// 2. If no cache exists, loads built-in defaults.
  /// 3. Initiates asynchronous remote sync in the background.
  Future<void> initialize({bool syncRemote = true}) async {
    final cached = await cacheStorage.loadCachedRecipes();
    if (cached != null && cached.isNotEmpty) {
      _recipes = cached;
      _syncStatus = RecipeSyncStatus.offlineFallback;
      notifyListeners();
    } else {
      _recipes = List.from(FilmRecipe.defaultSampleRecipes);
      notifyListeners();
    }

    if (syncRemote) {
      await refreshFromRemote();
    }
  }

  /// Fetches latest recipes from remote source with three-tier fallback:
  /// Tier 1: Remote X Weekly API / adapter.
  /// Tier 2: Offline disk cache if remote fails.
  /// Tier 3: Built-in defaults if cache is missing or corrupt.
  Future<void> refreshFromRemote() async {
    _syncStatus = RecipeSyncStatus.syncing;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final remoteList = await remoteAdapter.fetchRecipes();

      // Preserve existing user-created custom recipes
      final userCustom = _recipes.where((r) => r.isCustom && !r.id.startsWith('xweekly_')).toList();

      // Merge: Defaults + User Custom + Remote Community
      final Map<String, FilmRecipe> mergedMap = {};
      for (final r in FilmRecipe.defaultSampleRecipes) {
        mergedMap[r.id] = r;
      }
      for (final r in userCustom) {
        mergedMap[r.id] = r;
      }
      for (final r in remoteList) {
        mergedMap[r.id] = r;
      }

      _recipes = mergedMap.values.toList();
      _syncStatus = RecipeSyncStatus.success;
      _lastSyncTime = DateTime.now();

      // Update offline disk cache
      await cacheStorage.saveRecipes(_recipes);
    } catch (e) {
      _lastErrorMessage = e.toString();

      // Tier 2 Fallback: Check local cache
      final cached = await cacheStorage.loadCachedRecipes();
      if (cached != null && cached.isNotEmpty) {
        _recipes = cached;
        _syncStatus = RecipeSyncStatus.offlineFallback;
      } else {
        // Tier 3 Fallback: Built-in defaults
        if (_recipes.isEmpty) {
          _recipes = List.from(FilmRecipe.defaultSampleRecipes);
        }
        _syncStatus = RecipeSyncStatus.offlineFallback;
      }
    } finally {
      notifyListeners();
    }
  }

  /// Creates or updates a custom recipe, saves to offline storage, and notifies UI.
  Future<void> saveCustomRecipe(FilmRecipe recipe) async {
    final updatedRecipe = recipe.copyWith(isCustom: true);
    final index = _recipes.indexWhere((r) => r.id == updatedRecipe.id);

    if (index >= 0) {
      _recipes[index] = updatedRecipe;
    } else {
      _recipes.insert(0, updatedRecipe);
    }

    await cacheStorage.saveRecipes(_recipes);
    notifyListeners();
  }

  /// Deletes a custom recipe by ID.
  Future<void> deleteCustomRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    await cacheStorage.saveRecipes(_recipes);
    notifyListeners();
  }

  /// Finds recipe by ID or returns baseline Portra 400.
  FilmRecipe getRecipeById(String id) {
    return _recipes.firstWhere(
      (r) => r.id == id,
      orElse: () => FilmRecipe.fromPreset(FilmPreset.portra400),
    );
  }
}

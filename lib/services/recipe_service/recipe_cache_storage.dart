import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/film_recipe.dart';
import 'recipe_serializer.dart';

/// Handles offline disk persistence for cached and user-created film recipes.
class RecipeCacheStorage {
  final File? customCacheFile;
  String? _inMemoryCache; // Fallback / mock storage for unit testing without platform channels

  RecipeCacheStorage({this.customCacheFile});

  Future<File?> _getFile() async {
    if (customCacheFile != null) return customCacheFile!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/recipes_cache.json');
    } catch (_) {
      // In unit test or environment without path_provider
      return null;
    }
  }

  /// Loads cached recipes from disk or memory. Returns null if no cache exists or corrupted.
  Future<List<FilmRecipe>?> loadCachedRecipes() async {
    try {
      final file = await _getFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isEmpty) return null;
        final list = RecipeSerializer.deserializeList(content);
        return list.isNotEmpty ? list : null;
      } else if (_inMemoryCache != null) {
        final list = RecipeSerializer.deserializeList(_inMemoryCache!);
        return list.isNotEmpty ? list : null;
      }
      return null;
    } catch (_) {
      return null; // Graceful fallback on corrupt cache
    }
  }

  /// Writes recipes to disk or memory cache.
  Future<void> saveRecipes(List<FilmRecipe> recipes) async {
    try {
      final jsonString = RecipeSerializer.serializeList(recipes);
      _inMemoryCache = jsonString;

      final file = await _getFile();
      if (file != null) {
        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }
        await file.writeAsString(jsonString);
      }
    } catch (_) {
      // Ignore disk write failure in restricted sandbox
    }
  }

  /// Clears the cache.
  Future<void> clearCache() async {
    _inMemoryCache = null;
    try {
      final file = await _getFile();
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

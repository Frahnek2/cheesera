import 'dart:io';
import '../../models/film_preset.dart';
import '../../models/film_recipe.dart';
import '../recipe_service/recipe_provider.dart';
import 'watched_folder_models.dart';

class IngestionMatchResult {
  final FilmRecipe recipe;
  final List<String> tags;
  final IngestionRule? matchedRule;

  const IngestionMatchResult({
    required this.recipe,
    this.tags = const [],
    this.matchedRule,
  });
}

/// Evaluates file metadata (name, modification date, path) against configured ingestion rules.
class IngestionRuleEngine {
  final RecipeProvider recipeProvider;

  const IngestionRuleEngine({required this.recipeProvider});

  /// Evaluates a file against a list of rules and returns the matched film recipe.
  IngestionMatchResult evaluateFile({
    required File file,
    required List<IngestionRule> rules,
  }) {
    final filename = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : file.path;
    final parentDir = file.parent.path.toLowerCase();

    DateTime? fileDate;
    try {
      fileDate = file.lastModifiedSync();
    } catch (_) {
      fileDate = DateTime.now();
    }

    for (final rule in rules) {
      if (!rule.isEnabled) continue;

      if (_matchesCriteria(rule.criteria, filename, parentDir, fileDate)) {
        final recipe = recipeProvider.getRecipeById(rule.targetRecipeId);
        return IngestionMatchResult(
          recipe: recipe,
          tags: rule.tags,
          matchedRule: rule,
        );
      }
    }

    // Default fallback if no rule matched
    return IngestionMatchResult(
      recipe: recipeProvider.getRecipeById(FilmPreset.portra400.id),
      tags: ['Auto-Ingested'],
      matchedRule: null,
    );
  }

  bool _matchesCriteria(
    IngestionCriteria criteria,
    String filename,
    String parentDir,
    DateTime fileDate,
  ) {
    switch (criteria.type) {
      case CriteriaType.filenamePattern:
        try {
          final reg = RegExp(criteria.pattern, caseSensitive: false);
          return reg.hasMatch(filename);
        } catch (_) {
          return filename.toLowerCase().contains(criteria.pattern.toLowerCase());
        }

      case CriteriaType.fileExtension:
        final ext = filename.split('.').last.toLowerCase();
        return ext == criteria.pattern.toLowerCase().replaceAll('.', '');

      case CriteriaType.timeOfDay:
        final hour = fileDate.hour;
        final start = criteria.startHour ?? 0;
        final end = criteria.endHour ?? 23;
        if (start <= end) {
          return hour >= start && hour <= end;
        } else {
          // Wraps around midnight (e.g. 21h to 04h)
          return hour >= start || hour <= end;
        }

      case CriteriaType.albumKeyword:
        return parentDir.contains(criteria.pattern.toLowerCase());
    }
  }
}

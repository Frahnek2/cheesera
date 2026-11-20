import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/models/film_preset.dart';
import 'package:cheesera/services/external_media/media_source_adapter.dart';
import 'package:cheesera/services/recipe_service/recipe_provider.dart';
import 'package:cheesera/services/watched_folder/ingestion_rule_engine.dart';
import 'package:cheesera/services/watched_folder/watched_folder_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Watched Folder Rule Engine & Triage Tests', () {
    test('IngestionRuleEngine matches Fujifilm camera files (DSCF*) to Classic Chrome', () {
      final recipeProvider = RecipeProvider();
      final engine = IngestionRuleEngine(recipeProvider: recipeProvider);

      final rules = [
        IngestionRule(
          id: 'rule_fuji',
          name: 'Fujifilm Camera Rule',
          criteria: const IngestionCriteria(
            type: CriteriaType.filenamePattern,
            pattern: r'(?i)^DSCF.*',
          ),
          targetRecipeId: FilmPreset.classicChrome.id,
          tags: ['Fuji X-T5'],
        ),
      ];

      final file = File('/tmp/DCIM/DSCF1042.JPG');
      final result = engine.evaluateFile(file: file, rules: rules);

      expect(result.recipe.preset.id, FilmPreset.classicChrome.id);
      expect(result.tags, contains('Fuji X-T5'));
      expect(result.matchedRule?.id, 'rule_fuji');
    });

    test('IngestionRuleEngine matches night keyword files to CineStill 800T', () {
      final recipeProvider = RecipeProvider();
      final engine = IngestionRuleEngine(recipeProvider: recipeProvider);

      final rules = [
        IngestionRule(
          id: 'rule_night',
          name: 'Night Neon Rule',
          criteria: const IngestionCriteria(
            type: CriteriaType.filenamePattern,
            pattern: r'(?i).*(night|neon).*',
          ),
          targetRecipeId: FilmPreset.cinestill800T.id,
          tags: ['Tungsten'],
        ),
      ];

      final file = File('/photos/shibuya_night_walk.jpg');
      final result = engine.evaluateFile(file: file, rules: rules);

      expect(result.recipe.preset.id, FilmPreset.cinestill800T.id);
      expect(result.tags, contains('Tungsten'));
    });

    test('IngestionRuleEngine falls back gracefully to Portra 400 on unmatched files', () {
      final recipeProvider = RecipeProvider();
      final engine = IngestionRuleEngine(recipeProvider: recipeProvider);

      final rules = [
        IngestionRule(
          id: 'rule_specific',
          name: 'Very Specific Rule',
          criteria: const IngestionCriteria(
            type: CriteriaType.filenamePattern,
            pattern: r'^SPECIFIC_PREFIX_.*',
          ),
          targetRecipeId: FilmPreset.triX400.id,
        ),
      ];

      final file = File('/photos/random_vacation_image.jpg');
      final result = engine.evaluateFile(file: file, rules: rules);

      expect(result.recipe.preset.id, FilmPreset.portra400.id);
      expect(result.matchedRule, isNull);
    });

    test('MockMediaSourceAdapter detects volumes and provides mock SD cards', () async {
      final adapter = MockMediaSourceAdapter();
      final volumes = await adapter.detectConnectedVolumes();

      expect(volumes.isNotEmpty, isTrue);
      expect(volumes.any((v) => v.name.contains('FUJIFILM')), isTrue);
      expect(volumes.first.photoCount, greaterThan(0));
    });
  });
}

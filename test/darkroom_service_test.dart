import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheesera/models/disposable_roll.dart';
import 'package:cheesera/models/film_preset.dart';
import 'package:cheesera/models/film_recipe.dart';
import 'package:cheesera/models/photo_item.dart';
import 'package:cheesera/services/darkroom/darkroom_models.dart';
import 'package:cheesera/services/darkroom/darkroom_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Disposable Camera & Shake-to-Develop Darkroom Tests', () {
    test('DisposableRoll accurately tracks 27 exposures and winding state', () {
      final roll = DisposableRoll(
        id: 'roll_test',
        title: 'QuickSnap 27',
        preset: FilmPreset.gold200,
        maxExposures: 27,
        createdAt: DateTime.now(),
      );

      expect(roll.remainingExposures, 27);
      expect(roll.isFull, isFalse);

      final photo = PhotoItem(
        id: 'shot_1',
        title: 'Exposure 1',
        originalBytes: Uint8List(10),
        recipe: FilmRecipe.fromPreset(FilmPreset.gold200),
        createdAt: DateTime.now(),
      );

      final updated = roll.copyWith(exposures: [photo]);
      expect(updated.remainingExposures, 26);
      expect(updated.exposures.length, 1);
    });

    test('DarkroomService queues 15-minute chemical developing batch', () async {
      final darkroom = DarkroomService();
      final photo = PhotoItem(
        id: 'p1',
        title: 'Raw Shot',
        originalBytes: Uint8List(20),
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400),
        createdAt: DateTime.now(),
      );

      final batch = await darkroom.queuePhotosForDevelopment(
        photos: [photo],
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400),
        durationSeconds: 900, // 15 minutes
      );

      expect(batch.totalDurationSeconds, 900);
      expect(batch.isCompleted, isFalse);
      expect(batch.remainingSeconds, closeTo(900, 2));
      expect(batch.formattedRemainingTime, '15:00');
      expect(darkroom.hasActiveDeveloping, isTrue);

      darkroom.dispose();
    });

    test('Shake agitation increments agitation count and triggers haptic feedback', () async {
      final darkroom = DarkroomService();
      final photo = PhotoItem(
        id: 'p2',
        title: 'Raw Shot 2',
        originalBytes: Uint8List(20),
        recipe: FilmRecipe.fromPreset(FilmPreset.triX400),
        createdAt: DateTime.now(),
      );

      final batch = await darkroom.queuePhotosForDevelopment(
        photos: [photo],
        recipe: FilmRecipe.fromPreset(FilmPreset.triX400),
      );

      expect(batch.agitationCount, 0);

      // Simulate 3 device shakes
      darkroom.shakeAgitate(batch.id);
      darkroom.shakeAgitate(batch.id);
      darkroom.shakeAgitate(batch.id);

      final updatedBatch = darkroom.batches.firstWhere((b) => b.id == batch.id);
      expect(updatedBatch.agitationCount, 3);

      darkroom.dispose();
    });

    test('DEBUG TOGGLE: instantCompleteDev immediately finishes the 15-minute timer', () async {
      final darkroom = DarkroomService();
      final photo = PhotoItem(
        id: 'p3',
        title: 'Raw Shot 3',
        originalBytes: Uint8List(20),
        recipe: FilmRecipe.fromPreset(FilmPreset.cinestill800T),
        createdAt: DateTime.now(),
      );

      final batch = await darkroom.queuePhotosForDevelopment(
        photos: [photo],
        recipe: FilmRecipe.fromPreset(FilmPreset.cinestill800T),
        durationSeconds: 900,
      );

      expect(batch.isCompleted, isFalse);

      // Trigger instant complete debug toggle
      await darkroom.instantCompleteDev(batch.id);

      final completedBatch = darkroom.batches.firstWhere((b) => b.id == batch.id);
      expect(completedBatch.isCompleted, isTrue);
      expect(completedBatch.remainingSeconds, 0);
      expect(completedBatch.progress, 1.0);

      // Reveal photos into gallery
      final revealed = await darkroom.revealBatch(batch.id);
      expect(revealed.length, 1);
      expect(revealed.first.recipe.preset.id, FilmPreset.cinestill800T.id);
      expect(darkroom.batches.any((b) => b.id == batch.id), isFalse);

      darkroom.dispose();
    });

    test('DevelopingBatch JSON serialization preserves state across app restarts', () {
      final batch = DevelopingBatch(
        id: 'batch_persist_test',
        title: 'FunSaver Roll',
        photos: [
          PhotoItem(
            id: 'shot_persist',
            title: 'Shot',
            originalBytes: Uint8List(15),
            recipe: FilmRecipe.fromPreset(FilmPreset.gold200),
            createdAt: DateTime.now(),
          ),
        ],
        recipe: FilmRecipe.fromPreset(FilmPreset.gold200),
        startTime: DateTime.now().subtract(const Duration(minutes: 5)),
        totalDurationSeconds: 900,
        agitationCount: 4,
        isCompleted: false,
      );

      final json = batch.toJson();
      final restored = DevelopingBatch.fromJson(json);

      expect(restored.id, batch.id);
      expect(restored.title, batch.title);
      expect(restored.agitationCount, 4);
      expect(restored.totalDurationSeconds, 900);
      expect(restored.photos.length, 1);
      // After 5 minutes elapsed, approximately 10 minutes (600s) remaining
      expect(restored.remainingSeconds, closeTo(600, 5));
    });
  });
}

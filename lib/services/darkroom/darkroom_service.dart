import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/haptics_util.dart';
import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';
import 'darkroom_models.dart';

/// Service managing the 15-minute chemical darkroom development queue,
/// persistence across app restarts, shake agitation, and dev instant-complete.
class DarkroomService extends ChangeNotifier {
  final File? customStorageFile;
  final List<DevelopingBatch> _batches = [];
  Timer? _tickerTimer;
  String? _inMemoryQueueString; // Fallback for unit testing

  DarkroomService({this.customStorageFile}) {
    _startTicker();
  }

  List<DevelopingBatch> get batches => List.unmodifiable(_batches);
  List<DevelopingBatch> get activeBatches => _batches.where((b) => !b.isCompleted).toList();
  List<DevelopingBatch> get completedBatches => _batches.where((b) => b.isCompleted).toList();
  bool get hasActiveDeveloping => activeBatches.isNotEmpty;

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      bool changed = false;
      for (final batch in _batches) {
        if (!batch.isCompleted && batch.remainingSeconds <= 0) {
          batch.isCompleted = true;
          changed = true;
          HapticsUtil.heavyAffirmation();
        }
      }
      if (changed || activeBatches.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  Future<File?> _getFile() async {
    if (customStorageFile != null) return customStorageFile!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/darkroom_queue.json');
    } catch (_) {
      return null;
    }
  }

  /// Initializes service by loading existing batches from disk and evaluating elapsed time.
  Future<void> initialize() async {
    await loadQueue();
  }

  /// Queues photos into a chemical development tank (default 15 minutes = 900 seconds).
  Future<DevelopingBatch> queuePhotosForDevelopment({
    required List<PhotoItem> photos,
    required FilmRecipe recipe,
    int durationSeconds = 900,
    String? title,
  }) async {
    final batch = DevelopingBatch(
      id: 'tank_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? '${recipe.preset.name} Tank Roll',
      photos: photos,
      recipe: recipe,
      startTime: DateTime.now(),
      totalDurationSeconds: durationSeconds,
      isCompleted: false,
      agitationCount: 0,
    );

    _batches.insert(0, batch);
    await persistQueue();
    notifyListeners();
    return batch;
  }

  /// Called when device shake is detected or tactile agitate button is pressed.
  void shakeAgitate(String batchId) {
    final index = _batches.indexWhere((b) => b.id == batchId);
    if (index != -1 && !_batches[index].isCompleted) {
      _batches[index].agitationCount += 1;
      HapticsUtil.lightSnap();
      persistQueue();
      notifyListeners();
    }
  }

  /// =========================================================================
  /// DEBUG / TESTING TOGGLE: Instantly completes the 15-minute timer
  /// =========================================================================
  Future<void> instantCompleteDev(String batchId) async {
    final index = _batches.indexWhere((b) => b.id == batchId);
    if (index != -1) {
      final batch = _batches[index];
      batch.isCompleted = true;
      // Offset start time so elapsedSeconds matches total duration
      HapticsUtil.heavyAffirmation();
      await persistQueue();
      notifyListeners();
    }
  }

  /// Debug helper: Instantly completes all active darkroom batches
  Future<void> instantCompleteAll() async {
    for (final batch in _batches) {
      batch.isCompleted = true;
    }
    HapticsUtil.heavyAffirmation();
    await persistQueue();
    notifyListeners();
  }

  /// Reveals a finished batch, returning developed PhotoItems with the recipe applied,
  /// and removes the batch from the darkroom queue.
  Future<List<PhotoItem>> revealBatch(String batchId) async {
    final index = _batches.indexWhere((b) => b.id == batchId);
    if (index == -1) return [];

    final batch = _batches[index];
    final List<PhotoItem> developedPhotos = batch.photos.map((p) {
      return p.copyWith(
        recipe: batch.recipe,
        title: '${batch.title} #${p.id.substring(p.id.length - 4)}',
      );
    }).toList();

    _batches.removeAt(index);
    await persistQueue();
    notifyListeners();
    return developedPhotos;
  }

  /// Persists darkroom queue to disk to survive app restarts and backgrounding.
  Future<void> persistQueue() async {
    try {
      final list = _batches.map((b) => b.toJson()).toList();
      final jsonString = jsonEncode(list);
      _inMemoryQueueString = jsonString;

      final file = await _getFile();
      if (file != null) {
        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }
        await file.writeAsString(jsonString);
      }
    } catch (_) {}
  }

  /// Loads queue from disk.
  Future<void> loadQueue() async {
    try {
      String? content;
      final file = await _getFile();
      if (file != null && await file.exists()) {
        content = await file.readAsString();
      } else {
        content = _inMemoryQueueString;
      }

      if (content != null && content.trim().isNotEmpty) {
        final decoded = jsonDecode(content);
        if (decoded is List) {
          _batches.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final batch = DevelopingBatch.fromJson(item);
              // Check if completed while app was closed
              if (batch.remainingSeconds <= 0) {
                batch.isCompleted = true;
              }
              _batches.add(batch);
            }
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}

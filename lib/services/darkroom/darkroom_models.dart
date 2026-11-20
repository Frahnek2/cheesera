import 'dart:convert';
import 'dart:typed_data';
import '../../models/film_preset.dart';
import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';
import '../recipe_service/recipe_serializer.dart';

/// Represents a batch of photos queued for 15-minute chemical darkroom development.
class DevelopingBatch {
  final String id;
  final String title;
  final List<PhotoItem> photos;
  final FilmRecipe recipe;
  final DateTime startTime;
  final int totalDurationSeconds; // Default 15 minutes = 900 seconds
  int agitationCount;
  bool isCompleted;

  DevelopingBatch({
    required this.id,
    required this.title,
    required this.photos,
    required this.recipe,
    required this.startTime,
    this.totalDurationSeconds = 900, // 15 minutes
    this.agitationCount = 0,
    this.isCompleted = false,
  });

  int get elapsedSeconds {
    final now = DateTime.now();
    final diff = now.difference(startTime).inSeconds;
    return diff.clamp(0, totalDurationSeconds);
  }

  int get remainingSeconds {
    if (isCompleted) return 0;
    final rem = totalDurationSeconds - elapsedSeconds;
    return rem.clamp(0, totalDurationSeconds);
  }

  double get progress {
    if (isCompleted) return 1.0;
    if (totalDurationSeconds <= 0) return 1.0;
    return (elapsedSeconds / totalDurationSeconds).clamp(0.0, 1.0);
  }

  String get formattedRemainingTime {
    final rem = remainingSeconds;
    final mins = (rem ~/ 60).toString().padLeft(2, '0');
    final secs = (rem % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'totalDurationSeconds': totalDurationSeconds,
      'agitationCount': agitationCount,
      'isCompleted': isCompleted,
      'recipe': RecipeSerializer.toJson(recipe),
      'photos': photos.map((p) => {
        'id': p.id,
        'title': p.title,
        'bytes': base64Encode(p.originalBytes),
        'frameRatio': p.frameRatio.name,
      }).toList(),
    };
  }

  factory DevelopingBatch.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipe'] != null
        ? RecipeSerializer.fromJson(Map<String, dynamic>.from(json['recipe']))
        : FilmRecipe.fromPreset(FilmPreset.portra400);

    final rawPhotos = (json['photos'] as List?) ?? [];
    final photos = rawPhotos.map((p) {
      final map = Map<String, dynamic>.from(p);
      final bytes = base64Decode(map['bytes'] ?? '');
      final ratioName = map['frameRatio']?.toString() ?? 'ratio4_5';
      final ratio = FrameRatio.values.firstWhere(
        (r) => r.name == ratioName,
        orElse: () => FrameRatio.ratio4_5,
      );

      return PhotoItem(
        id: map['id'] ?? 'photo_${DateTime.now().millisecondsSinceEpoch}',
        title: map['title'] ?? 'Negative',
        originalBytes: bytes,
        recipe: recipe,
        createdAt: DateTime.now(),
        frameRatio: ratio,
      );
    }).toList();

    return DevelopingBatch(
      id: json['id'] ?? 'batch_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Darkroom Batch',
      photos: photos,
      recipe: recipe,
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      totalDurationSeconds: json['totalDurationSeconds'] ?? 900,
      agitationCount: json['agitationCount'] ?? 0,
      isCompleted: json['isCompleted'] == true,
    );
  }
}

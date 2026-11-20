import 'dart:typed_data';
import 'film_recipe.dart';

enum FrameRatio {
  ratio3_2('3:2', 3 / 2),
  ratio4_5('4:5', 4 / 5),
  ratio1_1('1:1', 1.0),
  ratioXPan('65:24', 65 / 24);

  final String label;
  final double aspectRatio;
  const FrameRatio(this.label, this.aspectRatio);
}

/// Represents a photo item in Cheesera's gallery/feed.
class PhotoItem {
  final String id;
  final String title;
  final Uint8List originalBytes;
  final FilmRecipe recipe;
  final DateTime createdAt;
  final FrameRatio frameRatio;

  const PhotoItem({
    required this.id,
    required this.title,
    required this.originalBytes,
    required this.recipe,
    required this.createdAt,
    this.frameRatio = FrameRatio.ratio4_5,
  });

  PhotoItem copyWith({
    String? id,
    String? title,
    Uint8List? originalBytes,
    FilmRecipe? recipe,
    DateTime? createdAt,
    FrameRatio? frameRatio,
  }) {
    return PhotoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      originalBytes: originalBytes ?? this.originalBytes,
      recipe: recipe ?? this.recipe,
      createdAt: createdAt ?? this.createdAt,
      frameRatio: frameRatio ?? this.frameRatio,
    );
  }
}

import '../../models/film_preset.dart';
import '../../models/photo_item.dart';

/// Represents a disposable analog film roll (e.g. 27 or 36 exposures).
class DisposableRoll {
  final String id;
  final String title;
  final FilmPreset preset;
  final int maxExposures;
  final List<PhotoItem> exposures;
  final bool isSealed;
  final DateTime createdAt;

  const DisposableRoll({
    required this.id,
    required this.title,
    required this.preset,
    this.maxExposures = 27,
    this.exposures = const [],
    this.isSealed = false,
    required this.createdAt,
  });

  int get remainingExposures => (maxExposures - exposures.length).clamp(0, maxExposures);
  bool get isFull => exposures.length >= maxExposures;

  DisposableRoll copyWith({
    String? id,
    String? title,
    FilmPreset? preset,
    int? maxExposures,
    List<PhotoItem>? exposures,
    bool? isSealed,
    DateTime? createdAt,
  }) {
    return DisposableRoll(
      id: id ?? this.id,
      title: title ?? this.title,
      preset: preset ?? this.preset,
      maxExposures: maxExposures ?? this.maxExposures,
      exposures: exposures ?? this.exposures,
      isSealed: isSealed ?? this.isSealed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

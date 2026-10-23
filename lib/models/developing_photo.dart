class DevelopingPhoto {
  final String id;
  final String imagePath;
  final DateTime capturedAt;
  final DateTime developTime;
  bool isDeveloped;
  bool isShakeDeveloped;

  DevelopingPhoto({
    required this.id,
    required this.imagePath,
    required this.capturedAt,
    required this.developTime,
    this.isDeveloped = false,
    this.isShakeDeveloped = false,
  });

  // Get remaining time until development
  Duration get remainingTime {
    if (isDeveloped) return Duration.zero;
    final now = DateTime.now();
    if (now.isAfter(developTime)) return Duration.zero;
    return developTime.difference(now);
  }

  // Check if photo is ready to develop
  bool get isReadyToDevelop {
    return !isDeveloped && DateTime.now().isAfter(developTime);
  }

  // Check if photo can be shake-developed
  bool get canShakeDevelop {
    return !isDeveloped && !isShakeDeveloped;
  }

  // Mark as developed
  DevelopingPhoto markAsDeveloped() {
    return DevelopingPhoto(
      id: id,
      imagePath: imagePath,
      capturedAt: capturedAt,
      developTime: developTime,
      isDeveloped: true,
      isShakeDeveloped: isShakeDeveloped,
    );
  }

  // Mark as shake-developed
  DevelopingPhoto markAsShakeDeveloped() {
    return DevelopingPhoto(
      id: id,
      imagePath: imagePath,
      capturedAt: capturedAt,
      developTime: developTime,
      isDeveloped: true,
      isShakeDeveloped: true,
    );
  }

  // Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'capturedAt': capturedAt.toIso8601String(),
      'developTime': developTime.toIso8601String(),
      'isDeveloped': isDeveloped,
      'isShakeDeveloped': isShakeDeveloped,
    };
  }

  // Create from JSON
  factory DevelopingPhoto.fromJson(Map<String, dynamic> json) {
    return DevelopingPhoto(
      id: json['id'],
      imagePath: json['imagePath'],
      capturedAt: DateTime.parse(json['capturedAt']),
      developTime: DateTime.parse(json['developTime']),
      isDeveloped: json['isDeveloped'] ?? false,
      isShakeDeveloped: json['isShakeDeveloped'] ?? false,
    );
  }
}

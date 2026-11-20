enum MediaVolumeType {
  sdCard,
  usbOtg,
  cameraDcim,
  customDirectory,
  mockCamera,
}

class MediaVolume {
  final String id;
  final String name;
  final String path;
  final MediaVolumeType type;
  final int photoCount;
  final bool isConnected;
  final int? capacityBytes;

  const MediaVolume({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    this.photoCount = 0,
    this.isConnected = true,
    this.capacityBytes,
  });

  MediaVolume copyWith({
    String? id,
    String? name,
    String? path,
    MediaVolumeType? type,
    int? photoCount,
    bool? isConnected,
    int? capacityBytes,
  }) {
    return MediaVolume(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      photoCount: photoCount ?? this.photoCount,
      isConnected: isConnected ?? this.isConnected,
      capacityBytes: capacityBytes ?? this.capacityBytes,
    );
  }
}

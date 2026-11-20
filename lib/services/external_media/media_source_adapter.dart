import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/sample_images_data.dart';
import 'media_volume.dart';

/// Contract for scanning and detecting connected SD cards, USB cameras, and external volumes.
abstract class MediaSourceAdapter {
  Future<List<MediaVolume>> detectConnectedVolumes();
  Future<List<File>> scanVolumePhotos(MediaVolume volume);
  Future<MediaVolume?> pickDirectoryVolume();
}

/// Production platform adapter supporting Android `/storage/*` mounts, USB OTG,
/// and iOS/Android DocumentPicker / Storage Access Framework (SAF) trees.
class PlatformMediaSourceAdapter implements MediaSourceAdapter {
  const PlatformMediaSourceAdapter();

  @override
  Future<List<MediaVolume>> detectConnectedVolumes() async {
    final List<MediaVolume> volumes = [];

    // 1. Android: Scan external storage root for removable SD cards and USB OTG
    if (Platform.isAndroid) {
      try {
        final storageDir = Directory('/storage');
        if (storageDir.existsSync()) {
          for (final entity in storageDir.listSync()) {
            if (entity is Directory) {
              final seg = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
              // Ignore internal emulated storage
              if (seg != 'emulated' && seg != 'self') {
                final photoCount = _countPhotosInDir(entity);
                volumes.add(
                  MediaVolume(
                    id: 'android_sd_$seg',
                    name: 'SD CARD ($seg)',
                    path: entity.path,
                    type: MediaVolumeType.sdCard,
                    photoCount: photoCount,
                  ),
                );
              }
            }
          }
        }
      } catch (_) {}
    }

    return volumes;
  }

  @override
  Future<List<File>> scanVolumePhotos(MediaVolume volume) async {
    final dir = Directory(volume.path);
    if (!dir.existsSync()) return [];

    final List<File> photos = [];
    try {
      final entities = dir.listSync(recursive: true);
      for (final e in entities) {
        if (e is File && _isPhoto(e.path)) {
          photos.add(e);
        }
      }
    } catch (_) {}
    return photos;
  }

  @override
  Future<MediaVolume?> pickDirectoryVolume() async {
    try {
      final selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select SD Card / Camera DCIM Folder',
      );
      if (selectedPath == null) return null;

      final dir = Directory(selectedPath);
      final count = _countPhotosInDir(dir);
      final name = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;

      return MediaVolume(
        id: 'selected_${DateTime.now().millisecondsSinceEpoch}',
        name: name.toUpperCase(),
        path: selectedPath,
        type: MediaVolumeType.customDirectory,
        photoCount: count,
      );
    } catch (_) {
      return null;
    }
  }

  int _countPhotosInDir(Directory dir) {
    int count = 0;
    try {
      for (final e in dir.listSync(recursive: true)) {
        if (e is File && _isPhoto(e.path)) count++;
      }
    } catch (_) {}
    return count;
  }

  bool _isPhoto(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.dng') ||
        lower.endsWith('.raw');
  }
}

/// Mock adapter for unit testing and simulator demonstration.
class MockMediaSourceAdapter implements MediaSourceAdapter {
  final List<MediaVolume> mockVolumes;

  MockMediaSourceAdapter({List<MediaVolume>? volumes})
      : mockVolumes = volumes ?? [
          const MediaVolume(
            id: 'mock_sd_fuji',
            name: 'FUJIFILM SDHC (64GB)',
            path: '/mock/storage/FUJI_SDHC/DCIM/100_FUJI',
            type: MediaVolumeType.sdCard,
            photoCount: 6,
          ),
          const MediaVolume(
            id: 'mock_usb_sony',
            name: 'SONY A7RV USB-C',
            path: '/mock/storage/SONY_A7/DCIM',
            type: MediaVolumeType.usbOtg,
            photoCount: 4,
          ),
        ];

  @override
  Future<List<MediaVolume>> detectConnectedVolumes() async {
    return List.from(mockVolumes);
  }

  @override
  Future<List<File>> scanVolumePhotos(MediaVolume volume) async {
    // In mock mode, returns empty files list (UI consumes generated mock items)
    return [];
  }

  @override
  Future<MediaVolume?> pickDirectoryVolume() async {
    return const MediaVolume(
      id: 'mock_picked_dcim',
      name: 'CAMERA DCIM (MANUAL)',
      path: '/mock/dcim',
      type: MediaVolumeType.customDirectory,
      photoCount: 5,
    );
  }
}

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/sample_images_data.dart';
import '../../models/film_preset.dart';
import '../../models/film_recipe.dart';
import '../../models/photo_item.dart';

/// Service managing user photo imports (Camera / Gallery) and sample photo seeding.
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Picks a photo from Camera
  Future<PhotoItem?> captureFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 98,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return PhotoItem(
        id: 'capture_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Shutter Capture',
        originalBytes: bytes,
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400),
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Picks a photo from Device Photo Library / Camera Roll
  Future<PhotoItem?> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 98,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return PhotoItem(
        id: 'import_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Imported Negative',
        originalBytes: bytes,
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400),
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns default seeded sample photos so the user has beautiful, immediate
  /// content ready to edit, compare, and export right out-of-the-box.
  List<PhotoItem> getInitialSamplePhotos() {
    return [
      PhotoItem(
        id: 'sample_sunset_coast',
        title: 'Golden Hour Coast',
        originalBytes: SampleImagesData.getGoldenCoast(),
        recipe: FilmRecipe.fromPreset(FilmPreset.portra400, customTitle: 'Sunset Portra 400'),
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        frameRatio: FrameRatio.ratio4_5,
      ),
      PhotoItem(
        id: 'sample_midnight_tokyo',
        title: 'Midnight Tokyo',
        originalBytes: SampleImagesData.getMidnightNeon(),
        recipe: FilmRecipe.fromPreset(FilmPreset.cinestill800T, customTitle: 'Tokyo Neon 800T').copyWith(
          vignette: 0.35,
          contrast: 0.22,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        frameRatio: FrameRatio.ratio4_5,
      ),
      PhotoItem(
        id: 'sample_studio_portrait',
        title: 'Studio Monolith',
        originalBytes: SampleImagesData.getStudioPortrait(),
        recipe: FilmRecipe.fromPreset(FilmPreset.triX400, customTitle: 'Fine Art TX400').copyWith(
          contrast: 0.35,
          grainAmount: 0.55,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        frameRatio: FrameRatio.ratio1_1,
      ),
    ];
  }
}

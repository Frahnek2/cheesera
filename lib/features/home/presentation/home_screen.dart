import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptics_util.dart';
import '../../../models/film_recipe.dart';
import '../../../models/photo_item.dart';
import '../../../services/darkroom/darkroom_service.dart';
import '../../../services/film_engine/film_engine.dart';
import '../../../services/media/photo_service.dart';
import '../../../services/recipe_service/recipe_provider.dart';
import '../../../widgets/film_frame_card.dart';
import '../../../widgets/tactile_button.dart';
import '../../darkroom/presentation/darkroom_screen.dart';
import '../../disposable_camera/presentation/disposable_camera_screen.dart';
import '../../editor/presentation/editor_screen.dart';
import 'widgets/home_header.dart';
import 'widgets/recipe_catalog_sheet.dart';

/// Main home gallery & feed view.
class HomeScreen extends StatefulWidget {
  final FilmEngine filmEngine;
  final PhotoService photoService;
  final RecipeProvider recipeProvider;
  final DarkroomService darkroomService;

  const HomeScreen({
    super.key,
    required this.filmEngine,
    required this.photoService,
    required this.recipeProvider,
    required this.darkroomService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<PhotoItem> _photos;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photos = widget.photoService.getInitialSamplePhotos();
    widget.darkroomService.addListener(_onDarkroomUpdate);
  }

  @override
  void dispose() {
    widget.darkroomService.removeListener(_onDarkroomUpdate);
    super.dispose();
  }

  void _onDarkroomUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _handleCameraCapture() async {
    setState(() => _isLoading = true);
    final photo = await widget.photoService.captureFromCamera();
    setState(() => _isLoading = false);

    if (photo != null) {
      setState(() {
        _photos.insert(0, photo);
      });
      _openEditor(photo);
    }
  }

  Future<void> _handleGalleryImport() async {
    setState(() => _isLoading = true);
    final photo = await widget.photoService.pickFromGallery();
    setState(() => _isLoading = false);

    if (photo != null) {
      setState(() {
        _photos.insert(0, photo);
      });
      _openEditor(photo);
    }
  }

  void _openDisposableCamera() {
    HapticsUtil.lightSnap();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DisposableCameraScreen(
          filmEngine: widget.filmEngine,
          photoService: widget.photoService,
          darkroomService: widget.darkroomService,
          onPhotosDeveloped: (developedList) {
            setState(() {
              _photos.insertAll(0, developedList);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Revealed ${developedList.length} developed negatives in feed!'),
                backgroundColor: AppColors.surfaceElevated,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDarkroom({List<PhotoItem>? initialQueue, FilmRecipe? initialRecipe}) {
    HapticsUtil.selectionTick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DarkroomScreen(
          filmEngine: widget.filmEngine,
          darkroomService: widget.darkroomService,
          initialPhotosToQueue: initialQueue,
          initialRecipe: initialRecipe,
          onRevealed: (developedList) {
            setState(() {
              _photos.insertAll(0, developedList);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Developed ${developedList.length} photos added to gallery!'),
                backgroundColor: AppColors.slideTeal,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openRecipeCatalog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecipeCatalogSheet(
        recipeProvider: widget.recipeProvider,
        onSelectRecipe: (selected) {
          if (_photos.isNotEmpty) {
            // Queue into Darkroom with selected recipe
            _openDarkroom(
              initialQueue: [_photos.first],
              initialRecipe: selected,
            );
          }
        },
      ),
    );
  }

  Future<void> _openEditor(PhotoItem photo) async {
    final updated = await Navigator.of(context).push<PhotoItem>(
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          photo: photo,
          filmEngine: widget.filmEngine,
          recipeProvider: widget.recipeProvider,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        final index = _photos.indexWhere((p) => p.id == updated.id);
        if (index != -1) {
          _photos[index] = updated;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDarkroomCount = widget.darkroomService.activeBatches.length;

    return Scaffold(
      backgroundColor: AppColors.darkroomBackground,
      body: Column(
        children: [
          // Top Analog Navigation Header
          HomeHeader(
            onCameraTap: _handleCameraCapture,
            onDisposableTap: _openDisposableCamera,
            onDarkroomTap: () => _openDarkroom(),
            onImportTap: _handleGalleryImport,
            onRecipesTap: _openRecipeCatalog,
            activeDevelopingCount: activeDarkroomCount,
          ),

          // Active Darkroom Developing Tank Banner
          if (widget.darkroomService.hasActiveDeveloping) ...[
            GestureDetector(
              onTap: () => _openDarkroom(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF221111),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.filmRed.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science_outlined, size: 18, color: AppColors.filmRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TANK DEVELOPING: ${widget.darkroomService.activeBatches.first.formattedRemainingTime} • SHAKE TO AGITATE',
                        style: AppTypography.filmMetadata.copyWith(
                          fontSize: 9,
                          color: AppColors.filmRed,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.filmRed, size: 18),
                  ],
                ),
              ),
            ),
          ],

          // Main Film Negative Feed
          Expanded(
            child: _photos.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      return Column(
                        children: [
                          FilmFrameCard(
                            photo: photo,
                            filmEngine: widget.filmEngine,
                            onTap: () => _openEditor(photo),
                          ),
                          // Quick "Shake to Develop in Tank" Action
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticsUtil.lightSnap();
                                    _openDarkroom(
                                      initialQueue: [photo],
                                      initialRecipe: photo.recipe,
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.waves_rounded, size: 14, color: AppColors.amberAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        'SHAKE TO DEVELOP (TANK)',
                                        style: AppTypography.filmMetadata.copyWith(
                                          fontSize: 8,
                                          color: AppColors.amberAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'DARKROOM IS EMPTY',
            style: AppTypography.filmHeadline.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Shoot a disposable roll or import a photo to begin developing.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                _photos = widget.photoService.getInitialSamplePhotos();
              });
            },
            child: const Text('RESTORE SAMPLE NEGATIVES'),
          ),
        ],
      ),
    );
  }
}

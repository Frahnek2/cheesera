import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/film_recipe.dart';
import '../../../models/photo_item.dart';
import '../../../services/film_engine/film_engine.dart';
import '../../../services/media/photo_service.dart';
import '../../../services/recipe_service/recipe_provider.dart';
import '../../../widgets/film_frame_card.dart';
import '../../editor/presentation/editor_screen.dart';
import 'widgets/home_header.dart';
import 'widgets/recipe_catalog_sheet.dart';

/// Main home gallery & feed view.
class HomeScreen extends StatefulWidget {
  final FilmEngine filmEngine;
  final PhotoService photoService;
  final RecipeProvider recipeProvider;

  const HomeScreen({
    super.key,
    required this.filmEngine,
    required this.photoService,
    required this.recipeProvider,
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

  void _openRecipeCatalog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecipeCatalogSheet(
        recipeProvider: widget.recipeProvider,
        onSelectRecipe: (selected) {
          if (_photos.isNotEmpty) {
            setState(() {
              _photos[0] = _photos[0].copyWith(recipe: selected);
            });
            _openEditor(_photos[0]);
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
    return Scaffold(
      backgroundColor: AppColors.darkroomBackground,
      body: Column(
        children: [
          // Top Analog Navigation Header
          HomeHeader(
            onCameraTap: _handleCameraCapture,
            onImportTap: _handleGalleryImport,
            onRecipesTap: _openRecipeCatalog,
          ),

          // Main Film Negative Feed
          Expanded(
            child: _photos.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      return FilmFrameCard(
                        photo: photo,
                        filmEngine: widget.filmEngine,
                        onTap: () => _openEditor(photo),
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
            'Import a photo or capture a frame to begin developing.',
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

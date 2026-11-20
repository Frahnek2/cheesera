import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptics_util.dart';
import '../../../core/utils/sample_images_data.dart';
import '../../../models/film_preset.dart';
import '../../../models/film_recipe.dart';
import '../../../models/photo_item.dart';
import '../../../services/external_media/media_source_adapter.dart';
import '../../../services/external_media/media_volume.dart';
import '../../../services/film_engine/film_engine.dart';
import '../../../services/recipe_service/recipe_provider.dart';
import '../../../widgets/grain_canvas.dart';
import '../../../widgets/tactile_button.dart';

enum TriageDecision { unreviewed, keep, reject, flag }

class TriageItem {
  final String id;
  final String filename;
  final Uint8List bytes;
  TriageDecision decision;
  FilmRecipe recipe;

  TriageItem({
    required this.id,
    required this.filename,
    required this.bytes,
    this.decision = TriageDecision.unreviewed,
    required this.recipe,
  });
}

/// Fast-Triage & Culling workflow for camera SD cards, USB OTG, and external media.
class FastTriageScreen extends StatefulWidget {
  final MediaVolume volume;
  final FilmEngine filmEngine;
  final RecipeProvider recipeProvider;
  final MediaSourceAdapter mediaAdapter;
  final Function(List<PhotoItem> imported) onImportCompleted;

  const FastTriageScreen({
    super.key,
    required this.volume,
    required this.filmEngine,
    required this.recipeProvider,
    required this.mediaAdapter,
    required this.onImportCompleted,
  });

  @override
  State<FastTriageScreen> createState() => _FastTriageScreenState();
}

class _FastTriageScreenState extends State<FastTriageScreen> {
  final List<TriageItem> _items = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolumePhotos();
  }

  Future<void> _loadVolumePhotos() async {
    setState(() => _isLoading = true);

    final defaultRecipe = widget.recipeProvider.getRecipeById(FilmPreset.classicChrome.id);
    final files = await widget.mediaAdapter.scanVolumePhotos(widget.volume);

    if (files.isNotEmpty) {
      for (final f in files) {
        try {
          final bytes = await f.readAsBytes();
          final name = f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : f.path;
          _items.add(TriageItem(
            id: 'triage_${f.path.hashCode}',
            filename: name,
            bytes: bytes,
            recipe: defaultRecipe,
          ));
        } catch (_) {}
      }
    }

    // If volume had no raw files or on simulator/mock: seed with realistic fast triage photos
    if (_items.isEmpty) {
      final samples = [
        SampleImagesData.getGoldenCoast(),
        SampleImagesData.getMidnightNeon(),
        SampleImagesData.getStudioPortrait(),
        SampleImagesData.getGoldenCoast(),
        SampleImagesData.getMidnightNeon(),
      ];

      for (int i = 0; i < samples.length; i++) {
        _items.add(TriageItem(
          id: 'mock_triage_$i',
          filename: 'DSCF_${(1042 + i)}.JPG',
          bytes: samples[i],
          recipe: defaultRecipe,
        ));
      }
    }

    setState(() => _isLoading = false);
  }

  int get keepCount => _items.where((i) => i.decision == TriageDecision.keep).length;
  int get rejectCount => _items.where((i) => i.decision == TriageDecision.reject).length;
  int get flagCount => _items.where((i) => i.decision == TriageDecision.flag).length;

  void _applyDecision(TriageDecision decision) {
    if (_items.isEmpty) return;

    setState(() {
      _items[_currentIndex].decision = decision;
      if (_currentIndex < _items.length - 1) {
        _currentIndex++;
      }
    });

    if (decision == TriageDecision.keep) {
      HapticsUtil.lightSnap();
    } else if (decision == TriageDecision.reject) {
      HapticsUtil.selectionTick();
    } else {
      HapticsUtil.selectionTick();
    }
  }

  void _applyRecipeToCurrent(FilmPreset preset) {
    if (_items.isEmpty) return;
    HapticsUtil.selectionTick();
    final recipe = FilmRecipe.fromPreset(preset);
    setState(() {
      _items[_currentIndex].recipe = recipe;
    });
  }

  void _applyRecipeToAllKeeps(FilmPreset preset) {
    HapticsUtil.lightSnap();
    final recipe = FilmRecipe.fromPreset(preset);
    setState(() {
      for (final item in _items) {
        if (item.decision == TriageDecision.keep) {
          item.recipe = recipe;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied ${preset.name} to all KEEPS'),
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _finalizeIngest() {
    final keeps = _items.where((i) => i.decision == TriageDecision.keep).toList();
    if (keeps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mark at least 1 photo as KEEP before ingesting!')),
      );
      return;
    }

    HapticsUtil.heavyAffirmation();
    final List<PhotoItem> imported = keeps.map((k) {
      return PhotoItem(
        id: 'sd_ingest_${DateTime.now().millisecondsSinceEpoch}_${k.id}',
        title: k.filename,
        originalBytes: k.bytes,
        recipe: k.recipe,
        createdAt: DateTime.now(),
      );
    }).toList();

    widget.onImportCompleted(imported);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkroomBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.volume.name,
              style: AppTypography.brandLogo.copyWith(fontSize: 13, letterSpacing: 1.5),
            ),
            Text(
              'FAST TRIAGE & CULLING',
              style: AppTypography.filmMetadata.copyWith(fontSize: 8, color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          // Batch Ingest Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TactileButton(
              backgroundColor: keepCount > 0 ? AppColors.slideTeal : AppColors.surfaceElevated,
              foregroundColor: keepCount > 0 ? Colors.black : AppColors.textDisabled,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: 8,
              onPressed: keepCount > 0 ? _finalizeIngest : null,
              child: Text(
                'INGEST ($keepCount)',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.amberAccent))
            : _items.isEmpty
                ? const Center(child: Text('No photos found on storage media.'))
                : Column(
                    children: [
                      // Status Stats Tally Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          children: [
                            _buildTallyBadge('KEEPS', keepCount, AppColors.slideTeal),
                            const SizedBox(width: 8),
                            _buildTallyBadge('REJECTS', rejectCount, AppColors.filmRed),
                            const SizedBox(width: 8),
                            _buildTallyBadge('FLAGGED', flagCount, AppColors.warmGold),
                            const Spacer(),
                            Text(
                              '${_currentIndex + 1} / ${_items.length}',
                              style: AppTypography.knobValue.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Main Culling Viewport
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: AspectRatio(
                              aspectRatio: 3 / 2,
                              child: _buildCandidateCard(_items[_currentIndex]),
                            ),
                          ),
                        ),
                      ),

                      // Quick Recipe Strip (Grading on-the-fly)
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceDark,
                          border: Border(
                            top: BorderSide(color: AppColors.surfaceBorder),
                            bottom: BorderSide(color: AppColors.surfaceBorder),
                          ),
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: FilmPreset.allPresets.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final p = FilmPreset.allPresets[idx];
                            final isSelected = _items[_currentIndex].recipe.preset.id == p.id;
                            return GestureDetector(
                              onTap: () => _applyRecipeToCurrent(p),
                              onLongPress: () => _applyRecipeToAllKeeps(p),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.surfaceHighlight : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.amberAccent : AppColors.surfaceBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(color: p.badgeColor, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      p.code,
                                      style: AppTypography.filmMetadata.copyWith(
                                        fontSize: 9,
                                        color: isSelected ? AppColors.amberAccent : AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Lower Triage Control Deck: REJECT / MAYBE / KEEP
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            // REJECT BUTTON (Left)
                            Expanded(
                              child: TactileButton(
                                backgroundColor: const Color(0xFF281313),
                                borderColor: AppColors.filmRed.withOpacity(0.6),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                borderRadius: 12,
                                onPressed: () => _applyDecision(TriageDecision.reject),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close_rounded, color: AppColors.filmRed, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      'REJECT',
                                      style: TextStyle(
                                        color: AppColors.filmRed,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // FLAG / MAYBE (Center)
                            TactileButton(
                              backgroundColor: AppColors.surfaceElevated,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              borderRadius: 12,
                              onPressed: () => _applyDecision(TriageDecision.flag),
                              child: const Icon(Icons.star_border_rounded, color: AppColors.warmGold, size: 22),
                            ),

                            const SizedBox(width: 10),

                            // KEEP BUTTON (Right)
                            Expanded(
                              child: TactileButton(
                                backgroundColor: const Color(0xFF132824),
                                borderColor: AppColors.slideTeal.withOpacity(0.6),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                borderRadius: 12,
                                onPressed: () => _applyDecision(TriageDecision.keep),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_rounded, color: AppColors.slideTeal, size: 20),
                                    SizedBox(width: 6),
                                    Text(
                                      'KEEP',
                                      style: TextStyle(
                                        color: AppColors.slideTeal,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCandidateCard(TriageItem item) {
    final matrix = widget.filmEngine.getPreviewColorMatrix(item.recipe);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.decision == TriageDecision.keep
              ? AppColors.slideTeal
              : (item.decision == TriageDecision.reject
                  ? AppColors.filmRed
                  : (item.decision == TriageDecision.flag ? AppColors.warmGold : AppColors.surfaceBorder)),
          width: 2.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GrainCanvas(
            amount: item.recipe.grainAmount,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(matrix),
              child: Image.memory(item.bytes, fit: BoxFit.cover),
            ),
          ),
          // Decision Watermark Badge
          if (item.decision != TriageDecision.unreviewed)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.decision.name.toUpperCase(),
                  style: AppTypography.filmMetadata.copyWith(
                    color: item.decision == TriageDecision.keep
                        ? AppColors.slideTeal
                        : (item.decision == TriageDecision.reject ? AppColors.filmRed : AppColors.warmGold),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          // Bottom Info Label
          Positioned(
            left: 14,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${item.filename} • ${item.recipe.preset.name}',
                style: AppTypography.filmMetadata.copyWith(fontSize: 9, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTallyBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$count $label',
        style: AppTypography.filmMetadata.copyWith(fontSize: 9, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptics_util.dart';
import '../../../models/film_preset.dart';
import '../../../models/film_recipe.dart';
import '../../../models/photo_item.dart';
import '../../../services/film_engine/film_engine.dart';
import '../../../services/storage/export_service.dart';
import '../../../widgets/before_after_slider.dart';
import '../../../widgets/grain_canvas.dart';
import '../../../widgets/tactile_button.dart';
import 'widgets/export_modal.dart';
import 'widgets/film_hud_overlay.dart';
import 'widgets/preset_strip.dart';
import 'widgets/recipe_adjustment_sheet.dart';

/// Interactive photo editor and preview screen.
/// Tactile, fast, uncluttered UI with real-time before/after comparison and preset switching.
class EditorScreen extends StatefulWidget {
  final PhotoItem photo;
  final FilmEngine filmEngine;

  const EditorScreen({
    super.key,
    required this.photo,
    required this.filmEngine,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late FilmRecipe _currentRecipe;
  late FrameRatio _currentRatio;
  bool _isHoldingRaw = false;

  // Export State
  bool _isExporting = false;
  String? _exportMessage;
  Uint8List? _lastExportedBytes;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.photo.recipe;
    _currentRatio = widget.photo.frameRatio;
  }

  void _onPresetSelected(FilmPreset preset) {
    setState(() {
      _currentRecipe = FilmRecipe.fromPreset(preset);
    });
  }

  void _openAdjustmentSheet() {
    HapticsUtil.selectionTick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return RecipeAdjustmentSheet(
            recipe: _currentRecipe,
            onRecipeChanged: (updated) {
              setSheetState(() {});
              setState(() {
                _currentRecipe = updated;
              });
            },
            onReset: () {
              setSheetState(() {});
              setState(() {
                _currentRecipe = _currentRecipe.reset();
              });
            },
          );
        },
      ),
    );
  }

  Future<void> _handleExport() async {
    HapticsUtil.shutterClick();
    setState(() {
      _isExporting = true;
      _exportMessage = null;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportModal(
        isRendering: _isExporting,
        resultMessage: _exportMessage,
        onDismiss: () => Navigator.of(context).pop(),
        onShare: () {
          if (_lastExportedBytes != null) {
            ExportService.sharePhoto(_lastExportedBytes!);
          }
        },
      ),
    );

    try {
      // 1. Render high-resolution image using FilmEngine
      final renderedBytes = await widget.filmEngine.renderFullResolution(
        sourceBytes: widget.photo.originalBytes,
        recipe: _currentRecipe,
        frameRatio: _currentRatio,
      );

      _lastExportedBytes = renderedBytes;

      // 2. Save directly to native Camera Roll / Photos album
      final result = await ExportService.exportToCameraRoll(renderedBytes);

      HapticsUtil.heavyAffirmation();
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportMessage = result.message;
        });

        // Reopen dialog with result state
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => ExportModal(
            isRendering: false,
            resultMessage: result.message,
            onDismiss: () => Navigator.of(context).pop(),
            onShare: () {
              if (_lastExportedBytes != null) {
                ExportService.sharePhoto(_lastExportedBytes!);
              }
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportMessage = 'Export failed: $e';
        });
        Navigator.of(context).pop();
      }
    }
  }

  void _saveAndExit() {
    final updatedPhoto = widget.photo.copyWith(
      recipe: _currentRecipe,
      frameRatio: _currentRatio,
    );
    Navigator.of(context).pop(updatedPhoto);
  }

  @override
  Widget build(BuildContext context) {
    final previewMatrix = widget.filmEngine.getPreviewColorMatrix(_currentRecipe);

    return Scaffold(
      backgroundColor: AppColors.darkroomBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _saveAndExit,
        ),
        title: Text(
          widget.photo.title.toUpperCase(),
          style: AppTypography.brandLogo.copyWith(fontSize: 14, letterSpacing: 2.0),
        ),
        actions: [
          // Chemistry Drawer Icon
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.amberAccent),
            tooltip: 'Fine-tune Recipe',
            onPressed: _openAdjustmentSheet,
          ),
          const SizedBox(width: 4),
          // Export Shutter Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: TactileButton(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              borderRadius: 8,
              onPressed: _handleExport,
              child: const Text(
                'EXPORT',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD: Preset info, Aspect ratio, Hold to raw
            FilmHudOverlay(
              preset: _currentRecipe.preset,
              currentRatio: _currentRatio,
              isHoldingCompare: _isHoldingRaw,
              onRatioChanged: (ratio) => setState(() => _currentRatio = ratio),
              onCompareDown: () => setState(() => _isHoldingRaw = true),
              onCompareUp: () => setState(() => _isHoldingRaw = false),
            ),

            // Main Viewport: Before / After Interactive Canvas
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AspectRatio(
                    aspectRatio: _currentRatio.aspectRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _isHoldingRaw
                          // User is holding down "HOLD: RAW" -> show pure untouched photo
                          ? Image.memory(
                              widget.photo.originalBytes,
                              fit: BoxFit.cover,
                            )
                          // Normal state: Interactive Before / After Split Slider
                          : BeforeAfterSlider(
                              beforeChild: Image.memory(
                                widget.photo.originalBytes,
                                fit: BoxFit.cover,
                              ),
                              afterChild: GrainCanvas(
                                amount: _currentRecipe.grainAmount,
                                size: _currentRecipe.grainSize,
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.matrix(previewMatrix),
                                  child: Image.memory(
                                    widget.photo.originalBytes,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Section: Film Preset Carousel & Quick Stats
            Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PresetStrip(
                    currentPreset: _currentRecipe.preset,
                    onSelectPreset: _onPresetSelected,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

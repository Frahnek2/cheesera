import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptics_util.dart';
import '../../../models/film_preset.dart';
import '../../../models/film_recipe.dart';
import '../../../models/photo_item.dart';
import '../../../services/film_engine/film_engine.dart';
import '../../../services/llm/default_llm_curation_service.dart';
import '../../../services/llm/llm_curation_service.dart';
import '../../../services/recipe_service/recipe_provider.dart';
import '../../../services/storage/export_service.dart';
import '../../../widgets/before_after_slider.dart';
import '../../../widgets/grain_canvas.dart';
import '../../../widgets/tactile_button.dart';
import '../../llm/presentation/widgets/ai_recipe_suggestion_sheet.dart';
import 'widgets/export_modal.dart';
import 'widgets/film_hud_overlay.dart';
import 'widgets/preset_strip.dart';
import 'widgets/recipe_adjustment_sheet.dart';

/// Interactive photo editor and preview screen with on-device AI recipe suggestions.
class EditorScreen extends StatefulWidget {
  final PhotoItem photo;
  final FilmEngine filmEngine;
  final RecipeProvider? recipeProvider;
  final LlmCurationService? llmService;

  const EditorScreen({
    super.key,
    required this.photo,
    required this.filmEngine,
    this.recipeProvider,
    this.llmService,
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

  Future<void> _suggestAiRecipe() async {
    HapticsUtil.selectionTick();
    final service = widget.llmService ?? DefaultLlmCurationService();
    final available = widget.recipeProvider?.recipes ?? FilmRecipe.defaultSampleRecipes;

    final suggestion = await service.suggestRecipe(
      photo: widget.photo,
      availableRecipes: available,
    );

    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => AiRecipeSuggestionSheet(
          suggestion: suggestion,
          onApplyRecipe: (rec) {
            setState(() => _currentRecipe = rec);
          },
        ),
      );
    }
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
            filmEngine: widget.filmEngine,
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
            onSaveCustomRecipe: (custom) {
              widget.recipeProvider?.saveCustomRecipe(custom);
              setState(() {
                _currentRecipe = custom;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved "${custom.title}" to Recipe Vault'),
                  backgroundColor: AppColors.surfaceElevated,
                  duration: const Duration(seconds: 2),
                ),
              );
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
      final renderedBytes = await widget.filmEngine.renderFullResolution(
        sourceBytes: widget.photo.originalBytes,
        recipe: _currentRecipe,
        frameRatio: _currentRatio,
      );

      _lastExportedBytes = renderedBytes;
      final result = await ExportService.exportToCameraRoll(renderedBytes);

      HapticsUtil.heavyAffirmation();
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportMessage = result.message;
        });

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
          // AI Recipe Suggestion Button
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.amberAccent, size: 20),
            tooltip: 'On-Device AI Recipe Suggestion',
            onPressed: _suggestAiRecipe,
          ),
          // Chemistry Drawer Icon
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.amberAccent, size: 20),
            tooltip: 'Fine-tune Recipe & 3D LUT',
            onPressed: _openAdjustmentSheet,
          ),
          const SizedBox(width: 4),
          // Export Shutter Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: TactileButton(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: 8,
              onPressed: _handleExport,
              child: const Text(
                'EXPORT',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
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
            // Top HUD
            FilmHudOverlay(
              preset: _currentRecipe.preset,
              currentRatio: _currentRatio,
              isHoldingCompare: _isHoldingRaw,
              onRatioChanged: (ratio) => setState(() => _currentRatio = ratio),
              onCompareDown: () => setState(() => _isHoldingRaw = true),
              onCompareUp: () => setState(() => _isHoldingRaw = false),
            ),

            // Main Viewport: Before / After Split Slider
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
                          ? Image.memory(
                              widget.photo.originalBytes,
                              fit: BoxFit.cover,
                            )
                          : BeforeAfterSlider(
                              beforeChild: Image.memory(
                                widget.photo.originalBytes,
                                fit: BoxFit.cover,
                              ),
                              afterChild: GrainCanvas(
                                amount: _currentRecipe.grainAmount,
                                size: _currentRecipe.grainSizeAmount,
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

            // Bottom Section: Film Preset Carousel
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

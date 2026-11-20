import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../models/film_recipe.dart';
import '../../../../services/film_engine/film_engine.dart';
import '../../../../services/film_engine/lut_manager.dart';
import '../../../../widgets/tactile_button.dart';
import '../../../../widgets/tactile_slider.dart';

/// Tactile bottom sheet drawer for fine-tuning film chemistry parameters,
/// Fujifilm camera parameters, custom 3D .cube LUTs, and saving custom recipes.
class RecipeAdjustmentSheet extends StatefulWidget {
  final FilmRecipe recipe;
  final FilmEngine filmEngine;
  final ValueChanged<FilmRecipe> onRecipeChanged;
  final VoidCallback onReset;
  final ValueChanged<FilmRecipe>? onSaveCustomRecipe;

  const RecipeAdjustmentSheet({
    super.key,
    required this.recipe,
    required this.filmEngine,
    required this.onRecipeChanged,
    required this.onReset,
    this.onSaveCustomRecipe,
  });

  @override
  State<RecipeAdjustmentSheet> createState() => _RecipeAdjustmentSheetState();
}

class _RecipeAdjustmentSheetState extends State<RecipeAdjustmentSheet> {
  int _selectedTab = 0; // 0: Chemistry, 1: Fujifilm Parameters, 2: 3D .cube LUT

  void _showSaveRecipeDialog() {
    final titleController = TextEditingController(text: '${widget.recipe.preset.name} Custom');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'SAVE CUSTOM RECIPE',
          style: AppTypography.filmHeadline.copyWith(fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save current parameters to your local recipe vault.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'RECIPE NAME',
                labelStyle: AppTypography.filmMetadata.copyWith(fontSize: 10),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty && widget.onSaveCustomRecipe != null) {
                final customRecipe = widget.recipe.copyWith(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  title: newTitle,
                  isCustom: true,
                  author: 'User Recipe',
                );
                widget.onSaveCustomRecipe!(customRecipe);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('SAVE RECIPE'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImportCubeLut() async {
    HapticsUtil.selectionTick();
    final meta = await widget.filmEngine.lutManager.pickAndImportCustomLut();
    if (meta != null && mounted) {
      HapticsUtil.lightSnap();
      widget.onRecipeChanged(widget.recipe.copyWith(customLutId: meta.id));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Recipe Title & Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHEMISTRY & OPTICS',
                          style: AppTypography.filmMetadata.copyWith(fontSize: 9),
                        ),
                        Text(
                          recipe.title,
                          style: AppTypography.filmHeadline.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TactileButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 8,
                    onPressed: widget.onReset,
                    child: Text(
                      'RESET',
                      style: AppTypography.filmMetadata.copyWith(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TactileButton(
                    backgroundColor: AppColors.amberAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    borderRadius: 8,
                    onPressed: _showSaveRecipeDialog,
                    child: Text(
                      'SAVE RECIPE',
                      style: AppTypography.filmMetadata.copyWith(
                        fontSize: 9,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab Selector: Chemistry vs Fuji vs 3D LUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabPill('CONTINUOUS', 0),
                  const SizedBox(width: 8),
                  _buildTabPill('FUJIFILM (X-PRO)', 1),
                  const SizedBox(width: 8),
                  _buildTabPill('3D .CUBE LUT', 2),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceBorder, height: 16),

            // Tab View Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (_selectedTab == 0) ..._buildContinuousSliders(recipe),
                  if (_selectedTab == 1) ..._buildFujiSliders(recipe),
                  if (_selectedTab == 2) ..._buildLutSection(recipe),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticsUtil.selectionTick();
          setState(() => _selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceHighlight : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.amberAccent : AppColors.surfaceBorder,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.filmMetadata.copyWith(
                fontSize: 9,
                color: isSelected ? AppColors.amberAccent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContinuousSliders(FilmRecipe recipe) {
    return [
      TactileSlider(
        label: 'Exposure Comp (EV)',
        value: recipe.exposure,
        min: -2.0,
        max: 2.0,
        zeroDetent: 0.0,
        valueFormatter: (v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)} EV',
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(exposure: val)),
      ),
      TactileSlider(
        label: 'Contrast',
        value: recipe.contrast,
        min: -1.0,
        max: 1.0,
        zeroDetent: 0.0,
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(contrast: val)),
      ),
      TactileSlider(
        label: 'Warmth / Kelvin Cast',
        value: recipe.warmth,
        min: -1.0,
        max: 1.0,
        zeroDetent: 0.0,
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(warmth: val)),
      ),
      TactileSlider(
        label: 'Tint (Green / Magenta)',
        value: recipe.tint,
        min: -1.0,
        max: 1.0,
        zeroDetent: 0.0,
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(tint: val)),
      ),
      TactileSlider(
        label: 'Silver Halide Grain',
        value: recipe.grainAmount,
        min: 0.0,
        max: 1.0,
        zeroDetent: 0.0,
        valueFormatter: (v) => '${(v * 100).round()}%',
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(grainAmount: val)),
      ),
      TactileSlider(
        label: 'Matte Shadow Fade',
        value: recipe.fade,
        min: 0.0,
        max: 0.5,
        zeroDetent: 0.0,
        valueFormatter: (v) => '${(v * 100).round()}%',
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(fade: val)),
      ),
      TactileSlider(
        label: 'Optical Vignette',
        value: recipe.vignette,
        min: 0.0,
        max: 1.0,
        zeroDetent: 0.0,
        valueFormatter: (v) => '${(v * 100).round()}%',
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(vignette: val)),
      ),
    ];
  }

  List<Widget> _buildFujiSliders(FilmRecipe recipe) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Text('DYNAMIC RANGE:', style: AppTypography.filmMetadata.copyWith(fontSize: 10)),
            const Spacer(),
            ...['DR100', 'DR200', 'DR400'].map((dr) {
              final active = recipe.dynamicRange == dr;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  onTap: () {
                    HapticsUtil.selectionTick();
                    widget.onRecipeChanged(recipe.copyWith(dynamicRange: dr));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? AppColors.amberAccent : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: active ? AppColors.amberAccent : AppColors.surfaceBorder),
                    ),
                    child: Text(
                      dr,
                      style: AppTypography.filmMetadata.copyWith(
                        fontSize: 9,
                        color: active ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      TactileSlider(
        label: 'Highlight Tone (-2 to +4)',
        value: recipe.highlightTone,
        min: -2.0,
        max: 4.0,
        divisions: 12,
        zeroDetent: 0.0,
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(
          highlightTone: val,
          contrast: (val + recipe.shadowTone) * 0.08,
        )),
      ),
      TactileSlider(
        label: 'Shadow Tone (-2 to +4)',
        value: recipe.shadowTone,
        min: -2.0,
        max: 4.0,
        divisions: 12,
        zeroDetent: 0.0,
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(
          shadowTone: val,
          contrast: (recipe.highlightTone + val) * 0.08,
        )),
      ),
      TactileSlider(
        label: 'Color Saturation (-4 to +4)',
        value: recipe.colorSaturation,
        min: -4.0,
        max: 4.0,
        divisions: 16,
        zeroDetent: 0.0,
        onChanged: (val) => widget.onRecipeChanged(recipe.copyWith(colorSaturation: val)),
      ),
      TactileSlider(
        label: 'WB Shift: Red (-9 to +9)',
        value: recipe.wbShiftR.toDouble(),
        min: -9.0,
        max: 9.0,
        divisions: 18,
        zeroDetent: 0.0,
        valueFormatter: (v) => '${v >= 0 ? '+' : ''}${v.round()} R',
        onChanged: (val) {
          final r = val.round();
          widget.onRecipeChanged(recipe.copyWith(
            wbShiftR: r,
            warmth: (r * 0.05 - recipe.wbShiftB * 0.04).clamp(-1.0, 1.0),
          ));
        },
      ),
      TactileSlider(
        label: 'WB Shift: Blue (-9 to +9)',
        value: recipe.wbShiftB.toDouble(),
        min: -9.0,
        max: 9.0,
        divisions: 18,
        zeroDetent: 0.0,
        valueFormatter: (v) => '${v >= 0 ? '+' : ''}${v.round()} B',
        onChanged: (val) {
          final b = val.round();
          widget.onRecipeChanged(recipe.copyWith(
            wbShiftB: b,
            warmth: (recipe.wbShiftR * 0.05 - b * 0.04).clamp(-1.0, 1.0),
          ));
        },
      ),
    ];
  }

  List<Widget> _buildLutSection(FilmRecipe recipe) {
    final available = widget.filmEngine.lutManager.availableLuts;

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3D COLOR LOOK-UP TABLE (.CUBE)',
                    style: AppTypography.filmMetadata.copyWith(fontSize: 10),
                  ),
                  Text(
                    'Apply 17x17, 33x33 or custom camera profile LUTs.',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            TactileButton(
              backgroundColor: AppColors.surfaceHighlight,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              borderRadius: 8,
              onPressed: _handleImportCubeLut,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 14, color: AppColors.amberAccent),
                  const SizedBox(width: 4),
                  Text(
                    'IMPORT .CUBE',
                    style: AppTypography.filmMetadata.copyWith(
                      fontSize: 9,
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
      // "None / Identity" option
      ListTile(
        title: Text(
          'None (Stock Film Matrix)',
          style: AppTypography.body.copyWith(
            color: recipe.customLutId == null ? AppColors.amberAccent : AppColors.textPrimary,
          ),
        ),
        subtitle: Text('Uses procedural 4x5 color grading chemistry', style: AppTypography.caption),
        trailing: recipe.customLutId == null ? const Icon(Icons.check, color: AppColors.amberAccent) : null,
        onTap: () {
          HapticsUtil.selectionTick();
          widget.onRecipeChanged(recipe.copyWith(customLutId: null));
        },
      ),
      ...available.map((lut) {
        final isSelected = recipe.customLutId == lut.id;
        return ListTile(
          title: Text(
            lut.title,
            style: AppTypography.body.copyWith(
              color: isSelected ? AppColors.amberAccent : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${lut.source == LutSource.bundled ? 'Bundled' : 'User Imported'} • ${lut.size}x${lut.size}x${lut.size}',
            style: AppTypography.caption,
          ),
          trailing: isSelected ? const Icon(Icons.check, color: AppColors.amberAccent) : null,
          onTap: () {
            HapticsUtil.lightSnap();
            widget.onRecipeChanged(recipe.copyWith(customLutId: lut.id));
          },
        );
      }),
    ];
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../models/film_recipe.dart';
import '../../../../widgets/tactile_button.dart';
import '../../../../widgets/tactile_slider.dart';

/// Tactile bottom sheet drawer for fine-tuning film chemistry parameters.
class RecipeAdjustmentSheet extends StatelessWidget {
  final FilmRecipe recipe;
  final ValueChanged<FilmRecipe> onRecipeChanged;
  final VoidCallback onReset;

  const RecipeAdjustmentSheet({
    super.key,
    required this.recipe,
    required this.onRecipeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet Handle
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

            // Header with Recipe name & Reset button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHEMISTRY & OPTICS',
                        style: AppTypography.filmMetadata.copyWith(fontSize: 10),
                      ),
                      Text(
                        recipe.preset.name,
                        style: AppTypography.filmHeadline.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TactileButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    borderRadius: 8,
                    onPressed: () {
                      HapticsUtil.lightSnap();
                      onReset();
                    },
                    child: Text(
                      'RESET',
                      style: AppTypography.filmMetadata.copyWith(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceBorder, height: 16),

            // Scrollable Adjustment Sliders
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  TactileSlider(
                    label: 'Exposure Comp (EV)',
                    value: recipe.exposure,
                    min: -2.0,
                    max: 2.0,
                    zeroDetent: 0.0,
                    valueFormatter: (v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)} EV',
                    onChanged: (val) => onRecipeChanged(recipe.copyWith(exposure: val)),
                  ),
                  TactileSlider(
                    label: 'Contrast',
                    value: recipe.contrast,
                    min: -1.0,
                    max: 1.0,
                    zeroDetent: 0.0,
                    onChanged: (val) => onRecipeChanged(recipe.copyWith(contrast: val)),
                  ),
                  TactileSlider(
                    label: 'Color Temp / Warmth',
                    value: recipe.warmth,
                    min: -1.0,
                    max: 1.0,
                    zeroDetent: 0.0,
                    onChanged: (val) => onRecipeChanged(recipe.copyWith(warmth: val)),
                  ),
                  TactileSlider(
                    label: 'Tint (Green / Magenta)',
                    value: recipe.tint,
                    min: -1.0,
                    max: 1.0,
                    zeroDetent: 0.0,
                    onChanged: (val) => onRecipeChanged(recipe.copyWith(tint: val)),
                  ),
                  TactileSlider(
                    label: 'Silver Halide Grain',
                    value: recipe.grainAmount,
                    min: 0.0,
                    max: 1.0,
                    zeroDetent: 0.0,
                    valueFormatter: (v) => '${(v * 100).round()}%',
                    onChanged: (val) => onRecipeChanged(recipe.copyWith(grainAmount: val)),
                  ),
                  TactileSlider(
                    label: 'Matte Shadow Fade',
                    value: recipe.fade,
                    min: 0.0,
                    max: 0.5,
                    zeroDetent: 0.0,
                    valueFormatter: (v) => '${(v * 100).round()}%',
                    onChanged: (val) => onRecipeChanged(recipe.copyWith(fade: val)),
                  ),
                  TactileSlider(
                    label: 'Optical Vignette',
                    value: recipe.vignette,
                    min: 0.0,
                    max: 1.0,
                    zeroDetent: 0.0,
                    valueFormatter: (v) => '${(v * 100).round()}%',
                    onChanged: (val) => onRecipeChanged(recipe.copyWith(vignette: val)),
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

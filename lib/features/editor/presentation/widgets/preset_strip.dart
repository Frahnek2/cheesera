import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../models/film_preset.dart';

/// Horizontal tactile strip displaying available analog film stocks.
class PresetStrip extends StatelessWidget {
  final FilmPreset currentPreset;
  final ValueChanged<FilmPreset> onSelectPreset;

  const PresetStrip({
    super.key,
    required this.currentPreset,
    required this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: FilmPreset.allPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final preset = FilmPreset.allPresets[index];
          final isSelected = preset.id == currentPreset.id;

          return GestureDetector(
            onTap: () {
              HapticsUtil.lightSnap();
              onSelectPreset(preset);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 82,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceHighlight : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.amberAccent : AppColors.surfaceBorder,
                  width: isSelected ? 1.6 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.amberAccent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: preset.badgeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        preset.code,
                        style: AppTypography.filmMetadata.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? AppColors.amberAccent : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ISO ${preset.iso}',
                    style: AppTypography.filmMetadata.copyWith(
                      fontSize: 8,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

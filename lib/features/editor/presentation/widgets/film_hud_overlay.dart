import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../models/film_preset.dart';
import '../../../../models/photo_item.dart';

/// Top HUD displaying film stock badge, aspect ratio picker, and hold-to-compare indicator.
class FilmHudOverlay extends StatelessWidget {
  final FilmPreset preset;
  final FrameRatio currentRatio;
  final ValueChanged<FrameRatio> onRatioChanged;
  final bool isHoldingCompare;
  final VoidCallback onCompareDown;
  final VoidCallback onCompareUp;

  const FilmHudOverlay({
    super.key,
    required this.preset,
    required this.currentRatio,
    required this.onRatioChanged,
    required this.isHoldingCompare,
    required this.onCompareDown,
    required this.onCompareUp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Film Stock Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: preset.badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  preset.name.toUpperCase(),
                  style: AppTypography.filmMetadata.copyWith(
                    fontSize: 9,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Aspect Ratio Switcher Button
          GestureDetector(
            onTap: () {
              HapticsUtil.selectionTick();
              final nextIndex = (FrameRatio.values.indexOf(currentRatio) + 1) % FrameRatio.values.length;
              onRatioChanged(FrameRatio.values[nextIndex]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Text(
                currentRatio.label,
                style: AppTypography.filmMetadata.copyWith(
                  fontSize: 9,
                  color: AppColors.amberAccent,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Hold to Compare Button
          GestureDetector(
            onTapDown: (_) {
              HapticsUtil.selectionTick();
              onCompareDown();
            },
            onTapUp: (_) {
              onCompareUp();
            },
            onTapCancel: onCompareUp,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isHoldingCompare ? AppColors.amberAccent : AppColors.surfaceElevated.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHoldingCompare ? AppColors.amberAccent : AppColors.surfaceBorder,
                ),
              ),
              child: Text(
                'HOLD: RAW',
                style: AppTypography.filmMetadata.copyWith(
                  fontSize: 9,
                  color: isHoldingCompare ? Colors.black : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/utils/haptics_util.dart';
import '../models/photo_item.dart';
import '../services/film_engine/film_engine.dart';
import 'grain_canvas.dart';

/// Minimalist analog negative / print card for the gallery feed.
class FilmFrameCard extends StatelessWidget {
  final PhotoItem photo;
  final FilmEngine filmEngine;
  final VoidCallback onTap;

  const FilmFrameCard({
    super.key,
    required this.photo,
    required this.filmEngine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final matrix = filmEngine.getPreviewColorMatrix(photo.recipe);

    return GestureDetector(
      onTap: () {
        HapticsUtil.lightSnap();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Film Rebate Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: photo.recipe.preset.badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    photo.recipe.preset.code,
                    style: AppTypography.filmMetadata.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•  ISO ${photo.recipe.preset.iso}',
                    style: AppTypography.filmMetadata.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 9,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    photo.frameRatio.label,
                    style: AppTypography.filmMetadata.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            // Photo Preview with simulated film grade + grain
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: photo.frameRatio.aspectRatio,
                child: GrainCanvas(
                  amount: photo.recipe.grainAmount,
                  size: photo.recipe.grainSize,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(matrix),
                    child: Image.memory(
                      photo.originalBytes,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Negative Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photo.title,
                          style: AppTypography.filmHeadline.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          photo.recipe.title,
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.tune_rounded,
                    color: AppColors.amberAccent,
                    size: 20,
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

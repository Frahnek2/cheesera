import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../models/film_recipe.dart';
import '../../../../services/llm/llm_models.dart';
import '../../../../widgets/tactile_button.dart';

/// Modal bottom sheet presenting local AI film simulation recommendations.
class AiRecipeSuggestionSheet extends StatelessWidget {
  final RecipeSuggestionResult suggestion;
  final ValueChanged<FilmRecipe> onApplyRecipe;

  const AiRecipeSuggestionSheet({
    super.key,
    required this.suggestion,
    required this.onApplyRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = suggestion.suggestedRecipe;
    final preset = recipe.preset;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header with Model Status Pill
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.amberAccent, size: 20),
                const SizedBox(width: 8),
                Text('ON-DEVICE CURATION', style: AppTypography.filmHeadline.copyWith(fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: suggestion.backendUsed == LlmBackendType.onDeviceGguf
                        ? AppColors.slideTeal.withOpacity(0.18)
                        : AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: suggestion.backendUsed == LlmBackendType.onDeviceGguf
                          ? AppColors.slideTeal
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Text(
                    suggestion.backendUsed == LlmBackendType.onDeviceGguf ? 'LOCAL GGUF' : 'HEURISTIC (OFFLINE)',
                    style: AppTypography.filmMetadata.copyWith(
                      fontSize: 8,
                      color: suggestion.backendUsed == LlmBackendType.onDeviceGguf ? AppColors.slideTeal : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(color: AppColors.surfaceBorder, height: 20),

            // Recommended Recipe Badge Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: preset.badgeColor.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: preset.badgeColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(preset.name.toUpperCase(), style: AppTypography.filmHeadline.copyWith(fontSize: 15)),
                      Text('${preset.manufacturer} • ISO ${preset.iso}', style: AppTypography.caption),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(suggestion.confidence * 100).round()}% MATCH',
                      style: AppTypography.filmMetadata.copyWith(fontSize: 9, color: AppColors.amberAccent),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Reasoning Narrative
            Text('PHOTOGRAPHIC RATIONALE', style: AppTypography.filmMetadata.copyWith(fontSize: 9)),
            const SizedBox(height: 4),
            Text(
              suggestion.reasoning,
              style: AppTypography.body.copyWith(fontSize: 13, height: 1.4),
            ),

            const SizedBox(height: 12),

            // Matched Attributes Tags
            if (suggestion.matchedAttributes.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: suggestion.matchedAttributes.map((attr) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Text(
                      attr,
                      style: AppTypography.filmMetadata.copyWith(fontSize: 8, color: AppColors.textSecondary),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Apply Button
            TactileButton(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: 12,
              onPressed: () {
                HapticsUtil.lightSnap();
                onApplyRecipe(recipe);
                Navigator.of(context).pop();
              },
              child: const Center(
                child: Text(
                  'APPLY RECOMMENDED RECIPE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

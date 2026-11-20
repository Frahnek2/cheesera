import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../models/film_recipe.dart';
import '../../../../models/photo_item.dart';
import '../../../../services/llm/llm_curation_service.dart';
import '../../../../services/llm/llm_models.dart';
import '../../../../widgets/tactile_button.dart';

/// Modal dialog for batch culling and ranking with natural language prompt input.
class AiBatchCurationDialog extends StatefulWidget {
  final List<PhotoItem> photos;
  final List<FilmRecipe> availableRecipes;
  final LlmCurationService llmService;
  final ValueChanged<BatchCurationResult> onCurationCompleted;

  const AiBatchCurationDialog({
    super.key,
    required this.photos,
    required this.availableRecipes,
    required this.llmService,
    required this.onCurationCompleted,
  });

  @override
  State<AiBatchCurationDialog> createState() => _AiBatchCurationDialogState();
}

class _AiBatchCurationDialogState extends State<AiBatchCurationDialog> {
  final TextEditingController _promptController = TextEditingController(text: 'warm golden hour vibe');
  bool _isProcessing = false;

  final List<String> _quickPrompts = [
    'warm golden hour vibe',
    'punchy street colors',
    'minimalist compositions',
    'moody night neon',
    'classic black & white documentary',
  ];

  Future<void> _runCuration() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    HapticsUtil.selectionTick();
    setState(() => _isProcessing = true);

    final result = await widget.llmService.curateBatch(
      photos: widget.photos,
      userPrompt: prompt,
      availableRecipes: widget.availableRecipes,
    );

    HapticsUtil.heavyAffirmation();
    if (mounted) {
      setState(() => _isProcessing = false);
      widget.onCurationCompleted(result);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.amberAccent, size: 20),
                const SizedBox(width: 8),
                Text('AI BATCH CURATION', style: AppTypography.filmHeadline.copyWith(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Ranks ${widget.photos.length} frames on-device and auto-selects top picks.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              autofocus: false,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'CURATION CRITERIA',
                labelStyle: AppTypography.filmMetadata.copyWith(fontSize: 9),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            // Quick preset pills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickPrompts.map((p) {
                return GestureDetector(
                  onTap: () {
                    HapticsUtil.selectionTick();
                    setState(() => _promptController.text = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Text(
                      p,
                      style: AppTypography.filmMetadata.copyWith(fontSize: 8, color: AppColors.textSecondary),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(color: AppColors.amberAccent),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL', style: TextStyle(color: AppColors.textTertiary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TactileButton(
                      backgroundColor: AppColors.amberAccent,
                      foregroundColor: Colors.black,
                      onPressed: _runCuration,
                      child: const Center(
                        child: Text(
                          'CURATE',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

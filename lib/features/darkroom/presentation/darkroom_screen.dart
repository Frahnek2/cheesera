import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptics_util.dart';
import '../../../models/film_recipe.dart';
import '../../../models/photo_item.dart';
import '../../../services/darkroom/darkroom_models.dart';
import '../../../services/darkroom/darkroom_service.dart';
import '../../../services/darkroom/shake_detector.dart';
import '../../../services/film_engine/film_engine.dart';
import '../../../widgets/grain_canvas.dart';
import '../../../widgets/tactile_button.dart';

/// Darkroom Screen managing the 15-minute chemical development tank,
/// device shake agitation gestures, and the instant-complete testing toggle.
class DarkroomScreen extends StatefulWidget {
  final FilmEngine filmEngine;
  final DarkroomService darkroomService;
  final List<PhotoItem>? initialPhotosToQueue;
  final FilmRecipe? initialRecipe;
  final Function(List<PhotoItem>) onRevealed;

  const DarkroomScreen({
    super.key,
    required this.filmEngine,
    required this.darkroomService,
    this.initialPhotosToQueue,
    this.initialRecipe,
    required this.onRevealed,
  });

  @override
  State<DarkroomScreen> createState() => _DarkroomScreenState();
}

class _DarkroomScreenState extends State<DarkroomScreen> with SingleTickerProviderStateMixin {
  late ShakeDetector _shakeDetector;
  String? _activeBatchId;
  late AnimationController _bubbleAnimController;

  @override
  void initState() {
    super.initState();
    _bubbleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    widget.darkroomService.addListener(_onServiceUpdate);

    // If new photos were passed to queue, start development
    if (widget.initialPhotosToQueue != null && widget.initialPhotosToQueue!.isNotEmpty) {
      widget.darkroomService
          .queuePhotosForDevelopment(
            photos: widget.initialPhotosToQueue!,
            recipe: widget.initialRecipe ?? FilmRecipe.fromPreset(widget.initialPhotosToQueue!.first.recipe.preset),
            durationSeconds: 900, // 15 minutes
          )
          .then((batch) {
        if (mounted) setState(() => _activeBatchId = batch.id);
      });
    } else if (widget.darkroomService.batches.isNotEmpty) {
      _activeBatchId = widget.darkroomService.batches.first.id;
    }

    // Set up Shake-to-Develop accelerometer detection
    _shakeDetector = ShakeDetector(
      onShake: _handleShakeAgitation,
    );
    _shakeDetector.start();
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    widget.darkroomService.removeListener(_onServiceUpdate);
    _bubbleAnimController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _handleShakeAgitation() {
    if (_activeBatchId == null) return;
    HapticsUtil.lightSnap();
    _bubbleAnimController.forward().then((_) => _bubbleAnimController.reverse());
    widget.darkroomService.shakeAgitate(_activeBatchId!);
  }

  Future<void> _handleReveal(String batchId) async {
    HapticsUtil.heavyAffirmation();
    final developed = await widget.darkroomService.revealBatch(batchId);
    widget.onRevealed(developed);
  }

  @override
  Widget build(BuildContext context) {
    final batches = widget.darkroomService.batches;
    final DevelopingBatch? activeBatch = batches.isNotEmpty
        ? (_activeBatchId != null
            ? batches.firstWhere((b) => b.id == _activeBatchId, orElse: () => batches.first)
            : batches.first)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0808), // Darkroom safelight ambient
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0808),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.filmRed),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CHEMICAL DARKROOM TANK',
          style: AppTypography.brandLogo.copyWith(fontSize: 13, letterSpacing: 2.0, color: AppColors.filmRed),
        ),
        actions: [
          // DEV TESTING TOGGLE: Instant Complete
          if (activeBatch != null && !activeBatch.isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TactileButton(
                backgroundColor: AppColors.filmRed.withOpacity(0.25),
                borderColor: AppColors.filmRed,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                borderRadius: 6,
                onPressed: () {
                  HapticsUtil.heavyAffirmation();
                  widget.darkroomService.instantCompleteDev(activeBatch.id);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AppColors.filmRed),
                    const SizedBox(width: 2),
                    Text(
                      'DEV: SKIP 15M',
                      style: AppTypography.filmMetadata.copyWith(
                        fontSize: 8,
                        color: AppColors.filmRed,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: activeBatch == null
            ? _buildEmptyDarkroom()
            : Column(
                children: [
                  // Chemical Bath Status Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1010),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.filmRed.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: activeBatch.isCompleted ? AppColors.slideTeal : AppColors.filmRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activeBatch.isCompleted
                              ? 'FIXING COMPLETE • READY TO REVEAL'
                              : 'BATH 1: DEVELOPER • FIXER TANK',
                          style: AppTypography.filmMetadata.copyWith(
                            fontSize: 10,
                            color: activeBatch.isCompleted ? AppColors.slideTeal : AppColors.filmRed,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'AGITATED: ${activeBatch.agitationCount}x',
                          style: AppTypography.filmMetadata.copyWith(fontSize: 9, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),

                  // Tank Canvas & Latent Negative View
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF3A1C1C), width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.filmRed.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Latent negative preview (blurs/clears with progress)
                            if (activeBatch.photos.isNotEmpty)
                              ColorFiltered(
                                colorFilter: ColorFilter.matrix(
                                  activeBatch.isCompleted
                                      ? activeBatch.recipe.preset.colorMatrix
                                      : [
                                          0.3, 0.3, 0.3, 0, 0,
                                          0.3, 0.3, 0.3, 0, 0,
                                          0.3, 0.3, 0.3, 0, 0,
                                          0, 0, 0, 1, 0,
                                        ],
                                ),
                                child: Image.memory(
                                  activeBatch.photos.first.originalBytes,
                                  fit: BoxFit.cover,
                                ),
                              ),

                            // Milky Chemical Liquid Layer (clears up as timer advances)
                            if (!activeBatch.isCompleted)
                              Container(
                                color: const Color(0xFF3B1515).withOpacity(
                                  (1.0 - activeBatch.progress * 0.7).clamp(0.2, 0.95),
                                ),
                              ),

                            // Silver halide grain emulsion
                            GrainCanvas(
                              amount: activeBatch.isCompleted ? 0.25 : 0.75,
                              child: const SizedBox.expand(),
                            ),

                            // Agitation Bubbles Animation
                            AnimatedBuilder(
                              animation: _bubbleAnimController,
                              builder: (context, child) => Opacity(
                                opacity: _bubbleAnimController.value,
                                child: Container(
                                  color: AppColors.amberAccent.withOpacity(0.18),
                                  child: const Center(
                                    child: Icon(Icons.waves_rounded, size: 72, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                            // Center Countdown Display
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: activeBatch.isCompleted ? AppColors.slideTeal : AppColors.filmRed,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          activeBatch.isCompleted ? 'DEVELOPED' : activeBatch.formattedRemainingTime,
                                          style: AppTypography.knobValue.copyWith(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: activeBatch.isCompleted ? AppColors.slideTeal : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          activeBatch.isCompleted
                                              ? '100% CHEMISTRY COMPLETED'
                                              : 'SHAKE DEVICE TO AGITATE',
                                          style: AppTypography.filmMetadata.copyWith(
                                            fontSize: 9,
                                            color: activeBatch.isCompleted ? AppColors.slideTeal : AppColors.amberAccent,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: activeBatch.progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFF261212),
                            valueColor: AlwaysStoppedAnimation(
                              activeBatch.isCompleted ? AppColors.slideTeal : AppColors.filmRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Controls: Agitate Button or Reveal Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: activeBatch.isCompleted
                        ? TactileButton(
                            backgroundColor: AppColors.slideTeal,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            borderRadius: 12,
                            onPressed: () => _handleReveal(activeBatch.id),
                            child: const Center(
                              child: Text(
                                'REVEAL & ADD DEVELOPED PHOTOS TO FEED',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              // Tactile Agitate button for simulator / manual tap
                              Expanded(
                                child: TactileButton(
                                  backgroundColor: const Color(0xFF2E1616),
                                  borderColor: AppColors.filmRed.withOpacity(0.6),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  borderRadius: 12,
                                  onPressed: _handleShakeAgitation,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.vibration_rounded, color: AppColors.amberAccent, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'AGITATE TANK (OR SHAKE PHONE)',
                                        style: AppTypography.filmMetadata.copyWith(
                                          fontSize: 10,
                                          color: AppColors.textPrimary,
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

  Widget _buildEmptyDarkroom() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, size: 48, color: AppColors.filmRed),
          const SizedBox(height: 16),
          Text('DARKROOM TANKS EMPTY', style: AppTypography.filmHeadline.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Shoot a roll in Disposable Camera mode\nor select photos from the feed to develop.',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

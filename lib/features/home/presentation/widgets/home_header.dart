import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../widgets/tactile_button.dart';

/// Minimalist analog brand header with disposable camera, darkroom tank, and import triggers.
class HomeHeader extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onDisposableTap;
  final VoidCallback onDarkroomTap;
  final VoidCallback onImportTap;
  final VoidCallback onRecipesTap;
  final int activeDevelopingCount;

  const HomeHeader({
    super.key,
    required this.onCameraTap,
    required this.onDisposableTap,
    required this.onDarkroomTap,
    required this.onImportTap,
    required this.onRecipesTap,
    this.activeDevelopingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.darkroomBackground,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 1.0)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo & Analog Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'CHEESERA',
                      style: AppTypography.brandLogo.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.amberAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.amberAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        'FILM LAB',
                        style: AppTypography.filmMetadata.copyWith(
                          fontSize: 7,
                          color: AppColors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'ANALOG COLOR & GRAIN',
                  style: AppTypography.filmMetadata.copyWith(
                    fontSize: 7,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Disposable Camera Mode Trigger
            TactileButton(
              backgroundColor: const Color(0xFF222630),
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.lightSnap();
                onDisposableTap();
              },
              child: const Icon(Icons.videocam_outlined, size: 18, color: AppColors.amberAccent),
            ),

            const SizedBox(width: 6),

            // Darkroom Chemical Tank Trigger (with live developing badge)
            Stack(
              clipBehavior: Clip.none,
              children: [
                TactileButton(
                  backgroundColor: activeDevelopingCount > 0
                      ? AppColors.filmRed.withOpacity(0.25)
                      : AppColors.surfaceElevated,
                  borderColor: activeDevelopingCount > 0 ? AppColors.filmRed : null,
                  padding: const EdgeInsets.all(7),
                  borderRadius: 8,
                  onPressed: () {
                    HapticsUtil.selectionTick();
                    onDarkroomTap();
                  },
                  child: Icon(
                    Icons.science_outlined,
                    size: 18,
                    color: activeDevelopingCount > 0 ? AppColors.filmRed : AppColors.textPrimary,
                  ),
                ),
                if (activeDevelopingCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.filmRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$activeDevelopingCount',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 6),

            // Recipe catalog
            TactileButton(
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.selectionTick();
                onRecipesTap();
              },
              child: const Icon(Icons.style_outlined, size: 18),
            ),

            const SizedBox(width: 6),

            // Import from camera roll
            TactileButton(
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.selectionTick();
                onImportTap();
              },
              child: const Icon(Icons.photo_library_outlined, size: 18),
            ),

            const SizedBox(width: 6),

            // Shutter Camera Capture
            TactileButton(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.shutterClick();
                onCameraTap();
              },
              child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../widgets/tactile_button.dart';

/// Minimalist analog brand header with AI LLM settings, SD card import, watched folder, disposable camera, and darkroom triggers.
class HomeHeader extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onDisposableTap;
  final VoidCallback onDarkroomTap;
  final VoidCallback onSdImportTap;
  final VoidCallback onWatchedFolderTap;
  final VoidCallback onLlmSettingsTap;
  final VoidCallback onImportTap;
  final VoidCallback onRecipesTap;
  final int activeDevelopingCount;
  final bool isWatchedFolderActive;
  final bool isLlmModelLoaded;

  const HomeHeader({
    super.key,
    required this.onCameraTap,
    required this.onDisposableTap,
    required this.onDarkroomTap,
    required this.onSdImportTap,
    required this.onWatchedFolderTap,
    required this.onLlmSettingsTap,
    required this.onImportTap,
    required this.onRecipesTap,
    this.activeDevelopingCount = 0,
    this.isWatchedFolderActive = false,
    this.isLlmModelLoaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.darkroomBackground,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 1.0)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Brand Logo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'CHEESERA',
                      style: AppTypography.brandLogo.copyWith(fontSize: 15),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.amberAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.amberAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        'LAB',
                        style: AppTypography.filmMetadata.copyWith(
                          fontSize: 7,
                          color: AppColors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'COLOR & INGESTION',
                  style: AppTypography.filmMetadata.copyWith(
                    fontSize: 7,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Local LLM On-Device Engine Settings
            TactileButton(
              backgroundColor: isLlmModelLoaded ? AppColors.slideTeal.withOpacity(0.2) : AppColors.surfaceElevated,
              borderColor: isLlmModelLoaded ? AppColors.slideTeal : null,
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.selectionTick();
                onLlmSettingsTap();
              },
              child: Icon(
                Icons.memory_rounded,
                size: 17,
                color: isLlmModelLoaded ? AppColors.slideTeal : AppColors.amberAccent,
              ),
            ),

            const SizedBox(width: 5),

            // SD Card / Camera Media Import & Fast-Triage
            TactileButton(
              backgroundColor: const Color(0xFF1B2329),
              borderColor: AppColors.slideTeal.withOpacity(0.4),
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.selectionTick();
                onSdImportTap();
              },
              child: const Icon(Icons.sd_card_outlined, size: 17, color: AppColors.slideTeal),
            ),

            const SizedBox(width: 5),

            // Watched Folder Monitor Trigger
            Stack(
              clipBehavior: Clip.none,
              children: [
                TactileButton(
                  backgroundColor: AppColors.surfaceElevated,
                  padding: const EdgeInsets.all(7),
                  borderRadius: 8,
                  onPressed: () {
                    HapticsUtil.selectionTick();
                    onWatchedFolderTap();
                  },
                  child: const Icon(Icons.folder_shared_outlined, size: 17, color: AppColors.amberAccent),
                ),
                if (isWatchedFolderActive)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.slideTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 5),

            // Disposable Camera Mode
            TactileButton(
              backgroundColor: const Color(0xFF222630),
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.lightSnap();
                onDisposableTap();
              },
              child: const Icon(Icons.videocam_outlined, size: 17, color: AppColors.amberAccent),
            ),

            const SizedBox(width: 5),

            // Darkroom Tank
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
                    size: 17,
                    color: activeDevelopingCount > 0 ? AppColors.filmRed : AppColors.textPrimary,
                  ),
                ),
                if (activeDevelopingCount > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        color: AppColors.filmRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$activeDevelopingCount',
                        style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 5),

            // Camera Capture Shutter
            TactileButton(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(7),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.shutterClick();
                onCameraTap();
              },
              child: const Icon(Icons.camera_alt_rounded, size: 17, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

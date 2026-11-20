import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../widgets/tactile_button.dart';

/// Minimalist analog brand header with shutter / import triggers.
class HomeHeader extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onImportTap;
  final VoidCallback onRecipesTap;

  const HomeHeader({
    super.key,
    required this.onCameraTap,
    required this.onImportTap,
    required this.onRecipesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      style: AppTypography.brandLogo.copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.amberAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.amberAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        'FILM LAB',
                        style: AppTypography.filmMetadata.copyWith(
                          fontSize: 8,
                          color: AppColors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'ANALOG COLOR SIMULATION',
                  style: AppTypography.filmMetadata.copyWith(
                    fontSize: 8,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Recipe catalog button
            TactileButton(
              padding: const EdgeInsets.all(8),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.selectionTick();
                onRecipesTap();
              },
              child: const Icon(Icons.style_outlined, size: 18),
            ),

            const SizedBox(width: 8),

            // Import from camera roll
            TactileButton(
              padding: const EdgeInsets.all(8),
              borderRadius: 8,
              onPressed: () {
                HapticsUtil.selectionTick();
                onImportTap();
              },
              child: const Icon(Icons.photo_library_outlined, size: 18),
            ),

            const SizedBox(width: 8),

            // Shutter Camera Capture
            TactileButton(
              backgroundColor: AppColors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(8),
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

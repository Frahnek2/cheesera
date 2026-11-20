import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../../widgets/tactile_button.dart';

/// Modal dialog presented during and after exporting the negative to Camera Roll.
class ExportModal extends StatelessWidget {
  final bool isRendering;
  final String? resultMessage;
  final VoidCallback onDismiss;
  final VoidCallback onShare;

  const ExportModal({
    super.key,
    required this.isRendering,
    required this.resultMessage,
    required this.onDismiss,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRendering) ...[
              const SizedBox(height: 12),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.amberAccent),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'DEVELOPING NEGATIVE',
                style: AppTypography.filmHeadline.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Synthesizing grain, color chemistry & curves...',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.amberAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'EXPORT SUCCESSFUL',
                style: AppTypography.filmHeadline.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                resultMessage ?? 'Negative saved to Camera Roll.',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TactileButton(
                      backgroundColor: AppColors.surfaceDark,
                      onPressed: () {
                        HapticsUtil.selectionTick();
                        onShare();
                      },
                      child: const Center(
                        child: Text(
                          'SHARE',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TactileButton(
                      backgroundColor: AppColors.amberAccent,
                      foregroundColor: Colors.black,
                      onPressed: () {
                        HapticsUtil.lightSnap();
                        onDismiss();
                      },
                      child: const Center(
                        child: Text(
                          'DONE',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

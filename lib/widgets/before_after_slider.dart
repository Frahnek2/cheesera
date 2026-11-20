import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/utils/haptics_util.dart';

/// Interactive Before / After split-screen slider widget.
/// Allows smooth scrubbing across the photo or a quick tap/hold to inspect the original.
class BeforeAfterSlider extends StatefulWidget {
  final Widget beforeChild; // Original unfiltered
  final Widget afterChild; // Processed film simulation
  final double initialSplit;
  final VoidCallback? onCompareHoldStart;
  final VoidCallback? onCompareHoldEnd;

  const BeforeAfterSlider({
    super.key,
    required this.beforeChild,
    required this.afterChild,
    this.initialSplit = 0.5,
    this.onCompareHoldStart,
    this.onCompareHoldEnd,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _splitPosition;
  bool _isHoldingOriginal = false;

  @override
  void initState() {
    super.initState();
    _splitPosition = widget.initialSplit;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final splitX = width * (_isHoldingOriginal ? 1.0 : _splitPosition);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Full After (Film Sim)
            widget.afterChild,

            // Layer 2: Clipped Before (Original)
            ClipRect(
              clipper: _HorizontalSplitClipper(splitX),
              child: widget.beforeChild,
            ),

            // Layer 3: Tactile Divider Bar & Drag Handle
            if (!_isHoldingOriginal)
              Positioned(
                left: splitX - 1.0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2.0,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),

            // Tactile Center Scrub Handle
            if (!_isHoldingOriginal)
              Positioned(
                left: splitX - 18.0,
                top: (height / 2) - 18.0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      final newPos = (_splitPosition + (details.delta.dx / width)).clamp(0.05, 0.95);
                      if ((newPos - 0.5).abs() < 0.03 && (_splitPosition - 0.5).abs() >= 0.03) {
                        HapticsUtil.lightSnap(); // Detent at center
                      }
                      _splitPosition = newPos;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withOpacity(0.92),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.compare_arrows_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // Badges: "ORIGINAL" vs "FILM"
            Positioned(
              top: 14,
              left: 14,
              child: _BadgePill(label: 'ORIGINAL', opacity: _splitPosition > 0.15 ? 0.85 : 0.0),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: _BadgePill(label: 'FILM SIM', opacity: _splitPosition < 0.85 ? 0.85 : 0.0),
            ),
          ],
        );
      },
    );
  }
}

class _HorizontalSplitClipper extends CustomClipper<Rect> {
  final double splitX;
  _HorizontalSplitClipper(this.splitX);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(covariant _HorizontalSplitClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final double opacity;

  const _BadgePill({required this.label, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Text(
          label,
          style: AppTypography.filmMetadata.copyWith(
            fontSize: 9,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

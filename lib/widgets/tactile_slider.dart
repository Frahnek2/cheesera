import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/utils/haptics_util.dart';

/// Minimalist tactile slider with detent ticks and numerical readout.
class TactileSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;
  final double zeroDetent;

  const TactileSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 40,
    required this.onChanged,
    this.valueFormatter,
    this.zeroDetent = 0.0,
  });

  @override
  State<TactileSlider> createState() => _TactileSliderState();
}

class _TactileSliderState extends State<TactileSlider> {
  double _lastDetentNotified = 0.0;

  void _handleChange(double newVal) {
    // Check if crossing neutral zero detent
    if ((_lastDetentNotified - widget.zeroDetent).abs() > 0.05 &&
        (newVal - widget.zeroDetent).abs() <= 0.05) {
      HapticsUtil.lightSnap();
      _lastDetentNotified = newVal;
    } else {
      HapticsUtil.selectionTick();
      _lastDetentNotified = newVal;
    }
    widget.onChanged(newVal);
  }

  @override
  Widget build(BuildContext context) {
    final formatted = widget.valueFormatter != null
        ? widget.valueFormatter!(widget.value)
        : (widget.value >= 0 ? '+${widget.value.toStringAsFixed(1)}' : widget.value.toStringAsFixed(1));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTypography.filmMetadata.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                formatted,
                style: AppTypography.knobValue.copyWith(
                  color: (widget.value - widget.zeroDetent).abs() > 0.01
                      ? AppColors.amberAccent
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.amberAccent,
              inactiveTrackColor: AppColors.surfaceBorder,
              trackHeight: 2.0,
              thumbColor: AppColors.textPrimary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
              overlayColor: AppColors.amberAccent.withOpacity(0.15),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
            ),
            child: Slider(
              value: widget.value.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              onChanged: _handleChange,
            ),
          ),
        ],
      ),
    );
  }
}

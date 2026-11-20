import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/haptics_util.dart';

/// Tactile button with physical depress animation and micro-haptic feedback.
class TactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isCircular;

  const TactileButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = AppColors.surfaceElevated,
    this.foregroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 12.0,
    this.isCircular = false,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    _controller.forward();
    HapticsUtil.selectionTick();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _controller.reverse();
    HapticsUtil.lightSnap();
    widget.onPressed!();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: enabled ? widget.backgroundColor : AppColors.surfaceDark,
            shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircular ? null : BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.borderColor ?? AppColors.surfaceBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: enabled ? (widget.foregroundColor ?? AppColors.textPrimary) : AppColors.textDisabled,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: enabled ? (widget.foregroundColor ?? AppColors.textPrimary) : AppColors.textDisabled,
                size: 20,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

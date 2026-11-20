import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/haptics_util.dart';
import '../../../core/utils/sample_images_data.dart';
import '../../../models/disposable_roll.dart';
import '../../../models/film_preset.dart';
import '../../../models/film_recipe.dart';
import '../../../models/photo_item.dart';
import '../../../services/darkroom/darkroom_service.dart';
import '../../../services/film_engine/film_engine.dart';
import '../../../services/media/photo_service.dart';
import '../../../widgets/grain_canvas.dart';
import '../../../widgets/tactile_button.dart';
import '../../darkroom/presentation/darkroom_screen.dart';

enum FlashMode { off, on, auto }

/// A playful analog disposable camera mode with a vintage chassis viewfinder,
/// thumb advance winder mechanism, mechanical counter, flash capacitor, and roll developing.
class DisposableCameraScreen extends StatefulWidget {
  final FilmEngine filmEngine;
  final PhotoService photoService;
  final DarkroomService darkroomService;
  final Function(List<PhotoItem>) onPhotosDeveloped;

  const DisposableCameraScreen({
    super.key,
    required this.filmEngine,
    required this.photoService,
    required this.darkroomService,
    required this.onPhotosDeveloped,
  });

  @override
  State<DisposableCameraScreen> createState() => _DisposableCameraScreenState();
}

class _DisposableCameraScreenState extends State<DisposableCameraScreen>
    with SingleTickerProviderStateMixin {
  late DisposableRoll _activeRoll;
  FlashMode _flashMode = FlashMode.auto;
  bool _isWound = true; // Must wind film before firing shutter
  bool _isFlashing = false;
  double _winderAngle = 0.0;
  Uint8List? _lastCapturedThumbnail;

  late final AnimationController _shutterAnimController;

  @override
  void initState() {
    super.initState();
    _activeRoll = DisposableRoll(
      id: 'roll_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cheesera 27 Flash',
      preset: FilmPreset.gold200, // Classic disposable film stock
      maxExposures: 27,
      createdAt: DateTime.now(),
    );

    _shutterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _shutterAnimController.dispose();
    super.dispose();
  }

  void _onWindFilm() {
    if (_isWound) return;
    HapticsUtil.selectionTick();
    setState(() {
      _winderAngle += math.pi / 2;
      _isWound = true;
    });
    HapticsUtil.lightSnap();
  }

  Future<void> _onShutterPress() async {
    if (!_isWound) {
      HapticsUtil.selectionTick();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wind film advance wheel before taking next shot!'),
          duration: Duration(milliseconds: 1200),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    if (_activeRoll.isFull) {
      HapticsUtil.heavyAffirmation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roll is finished! Tap "Develop Roll" to process in Darkroom.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticsUtil.shutterClick();
    _shutterAnimController.forward().then((_) => _shutterAnimController.reverse());

    // Flash simulation
    if (_flashMode != FlashMode.off) {
      setState(() => _isFlashing = true);
      Future.delayed(const Duration(milliseconds: 70), () {
        if (mounted) setState(() => _isFlashing = false);
      });
    }

    // Capture or seed exposure
    Uint8List shotBytes;
    final captured = await widget.photoService.captureFromCamera();
    if (captured != null) {
      shotBytes = captured.originalBytes;
    } else {
      // Deterministic synthetic snapshot for simulator/camera unavailable
      final sampleIndex = _activeRoll.exposures.length % 3;
      if (sampleIndex == 0) {
        shotBytes = SampleImagesData.getGoldenCoast();
      } else if (sampleIndex == 1) {
        shotBytes = SampleImagesData.getMidnightNeon();
      } else {
        shotBytes = SampleImagesData.getStudioPortrait();
      }
    }

    final newPhoto = PhotoItem(
      id: 'shot_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Frame #${_activeRoll.exposures.length + 1}',
      originalBytes: shotBytes,
      recipe: FilmRecipe.fromPreset(_activeRoll.preset),
      createdAt: DateTime.now(),
      frameRatio: FrameRatio.ratio3_2, // Classic 35mm
    );

    setState(() {
      _lastCapturedThumbnail = shotBytes;
      _isWound = false; // Must advance film
      _activeRoll = _activeRoll.copyWith(
        exposures: [..._activeRoll.exposures, newPhoto],
      );
    });
  }

  void _onDevelopRoll() {
    if (_activeRoll.exposures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Take at least 1 shot before developing!')),
      );
      return;
    }

    HapticsUtil.lightSnap();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DarkroomScreen(
          filmEngine: widget.filmEngine,
          darkroomService: widget.darkroomService,
          initialPhotosToQueue: _activeRoll.exposures,
          initialRecipe: FilmRecipe.fromPreset(_activeRoll.preset),
          onRevealed: (developed) {
            widget.onPhotosDeveloped(developed);
            Navigator.of(context).pop(); // Exit disposable camera
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _activeRoll.remainingExposures;
    final preset = _activeRoll.preset;

    return Scaffold(
      backgroundColor: const Color(0xFF141519),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141519),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'DISPOSABLE 35MM',
          style: AppTypography.brandLogo.copyWith(fontSize: 14, letterSpacing: 2.0),
        ),
        actions: [
          // Stock Switcher
          PopupMenuButton<FilmPreset>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: preset.badgeColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  preset.code,
                  style: AppTypography.filmMetadata.copyWith(color: AppColors.textPrimary, fontSize: 10),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
              ],
            ),
            color: AppColors.surfaceElevated,
            onSelected: (p) => setState(() => _activeRoll = _activeRoll.copyWith(preset: p)),
            itemBuilder: (_) => FilmPreset.allPresets.map((p) {
              return PopupMenuItem(
                value: p,
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: p.badgeColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(p.name, style: AppTypography.body.copyWith(fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Camera Bar: Exposure Counter + Flash Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // Mechanical LCD Counter Window
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0B0D),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF2E323D), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.amberAccent),
                        const SizedBox(width: 6),
                        Text(
                          'EXP [ ${remaining.toString().padLeft(2, '0')} ]',
                          style: AppTypography.knobValue.copyWith(
                            fontSize: 13,
                            color: AppColors.amberAccent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Flash Ready LED
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _flashMode != FlashMode.off ? AppColors.filmRed : AppColors.textDisabled,
                      shape: BoxShape.circle,
                      boxShadow: _flashMode != FlashMode.off
                          ? [BoxShadow(color: AppColors.filmRed.withOpacity(0.8), blurRadius: 6)]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Flash Selector
                  TactileButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 6,
                    onPressed: () {
                      HapticsUtil.selectionTick();
                      setState(() {
                        final next = (_flashMode.index + 1) % FlashMode.values.length;
                        _flashMode = FlashMode.values[next];
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _flashMode == FlashMode.off
                              ? Icons.flash_off_rounded
                              : (_flashMode == FlashMode.on ? Icons.flash_on_rounded : Icons.flash_auto_rounded),
                          size: 14,
                          color: _flashMode != FlashMode.off ? AppColors.amberAccent : AppColors.textDisabled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _flashMode.name.toUpperCase(),
                          style: AppTypography.filmMetadata.copyWith(
                            fontSize: 9,
                            color: _flashMode != FlashMode.off ? AppColors.amberAccent : AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Optical Viewfinder Canvas
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AspectRatio(
                    aspectRatio: 3 / 2, // 35mm optical ratio
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF383E4C), width: 3.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Viewfinder Image or Last Shot Preview
                          if (_lastCapturedThumbnail != null)
                            GrainCanvas(
                              amount: preset.defaultGrain,
                              child: ColorFiltered(
                                colorFilter: ColorFilter.matrix(preset.colorMatrix),
                                child: Image.memory(_lastCapturedThumbnail!, fit: BoxFit.cover),
                              ),
                            )
                          else
                            Container(
                              color: const Color(0xFF1B1E26),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.crop_free_rounded, size: 48, color: AppColors.textTertiary),
                                    const SizedBox(height: 8),
                                    Text('OPTICAL VIEWFINDER READY', style: AppTypography.filmMetadata.copyWith(fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),

                          // Viewfinder Crosshairs & Frame Overlay
                          IgnorePointer(
                            child: CustomPaint(
                              painter: _ViewfinderOverlayPainter(),
                            ),
                          ),

                          // Flash burst whiteout overlay
                          if (_isFlashing)
                            Container(color: Colors.white.withOpacity(0.85)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Lower Chassis: Winder Gear + Shutter Button + Darkroom Trigger
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1B1D23),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFF2A2E38))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Film Advance Thumb Wheel
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _onWindFilm,
                            child: Transform.rotate(
                              angle: _winderAngle,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _isWound ? const Color(0xFF22262F) : AppColors.amberAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.rotate_right_rounded,
                                  size: 28,
                                  color: _isWound ? AppColors.textSecondary : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isWound ? 'WOUND (READY)' : 'WIND FILM',
                            style: AppTypography.filmMetadata.copyWith(
                              fontSize: 9,
                              color: _isWound ? AppColors.textTertiary : AppColors.amberAccent,
                            ),
                          ),
                        ],
                      ),

                      // Mechanical Shutter Release Button
                      GestureDetector(
                        onTap: _onShutterPress,
                        child: AnimatedBuilder(
                          animation: _shutterAnimController,
                          builder: (context, child) => Transform.scale(
                            scale: 1.0 - (_shutterAnimController.value * 0.12),
                            child: child,
                          ),
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFE54B4B), Color(0xFF9E1B1B)],
                                center: Alignment(-0.2, -0.2),
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE54B4B).withOpacity(0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
                            ),
                          ),
                        ),
                      ),

                      // Develop Roll Button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _onDevelopRoll,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _activeRoll.exposures.isNotEmpty
                                    ? AppColors.slideTeal
                                    : AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surfaceBorder, width: 2),
                              ),
                              child: Icon(
                                Icons.science_outlined,
                                size: 26,
                                color: _activeRoll.exposures.isNotEmpty ? Colors.black : AppColors.textDisabled,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'DEVELOP ROLL',
                            style: AppTypography.filmMetadata.copyWith(
                              fontSize: 9,
                              color: _activeRoll.exposures.isNotEmpty ? AppColors.slideTeal : AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewfinderOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Corner Guide Marks
    const len = 20.0;
    const pad = 16.0;

    // Top-left
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + len, pad), paint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad, pad + len), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad - len, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad, pad + len), paint);

    // Bottom-left
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad + len, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad, size.height - pad - len), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - pad, size.height - pad), Offset(size.width - pad - len, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad), Offset(size.width - pad, size.height - pad - len), paint);

    // Center Crosshair
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 8, cy), Offset(cx + 8, cy), paint);
    canvas.drawLine(Offset(cx, cy - 8), Offset(cx, cy + 8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

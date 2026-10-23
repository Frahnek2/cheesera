import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/developing_photo.dart';
import 'disposable_camera_onboarding.dart';
import 'help_page.dart';

class DisposableCameraScreen extends StatefulWidget {
  const DisposableCameraScreen({super.key});

  @override
  State<DisposableCameraScreen> createState() => _DisposableCameraScreenState();
}

class _DisposableCameraScreenState extends State<DisposableCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _remainingShots = 27;
  List<DevelopingPhoto> _developingQueue = [];
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  bool _showQueue = false;
  bool _showOnboarding = false;
  bool _showHelp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadDevelopingQueue();
    _listenToShake();
    _checkOnboarding();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      // Camera initialization failed
    }
  }

  Future<void> _loadDevelopingQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString('developing_queue');
    if (queueJson != null) {
      // Parse and load queue (simplified for now)
      setState(() {
        _remainingShots = prefs.getInt('remaining_shots') ?? 27;
      });
    }
  }

  Future<void> _saveDevelopingQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remaining_shots', _remainingShots);
    // Save full queue in production
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        prefs.getBool('disposable_camera_onboarding_seen') ?? false;
    if (!hasSeenOnboarding) {
      setState(() {
        _showOnboarding = true;
      });
    }
  }

  void _listenToShake() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();
      if (_lastShakeTime != null &&
          now.difference(_lastShakeTime!) < const Duration(seconds: 1)) {
        return;
      }

      final acceleration = event.x.abs() + event.y.abs() + event.z.abs();
      if (acceleration > 25) {
        _lastShakeTime = now;
        _handleShake();
      }
    });
  }

  void _handleShake() {
    if (!_showQueue) return;

    // Find first photo that can be shake-developed
    final photoToDevelop = _developingQueue
        .firstWhere((photo) => photo.canShakeDevelop, orElse: () => _developingQueue.first);

    if (photoToDevelop.canShakeDevelop) {
      setState(() {
        _developingQueue = _developingQueue.map((photo) {
          if (photo.id == photoToDevelop.id) {
            return photo.markAsShakeDeveloped();
          }
          return photo;
        }).toList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📸 Shake developing complete!'),
            backgroundColor: Colors.grey[800],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_remainingShots <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No shots remaining!')),
        );
      }
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await photo.saveTo(path);

      final newPhoto = DevelopingPhoto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: path,
        capturedAt: DateTime.now(),
        developTime: DateTime.now().add(const Duration(hours: 2)),
      );

      setState(() {
        _remainingShots--;
        _developingQueue.add(newPhoto);
      });

      await _saveDevelopingQueue();

      // Flash effect
      setState(() {
        _isFlashOn = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _isFlashOn = false;
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shot taken! $_remainingShots remaining'),
            backgroundColor: Colors.grey[800],
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Error taking photo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_showHelp)
            HelpPage(
              onClose: () {
                setState(() {
                  _showHelp = false;
                });
              },
            )
          else if (_showQueue)
            _buildQueueView()
          else
            _buildCameraView(),
          if (_showOnboarding)
            DisposableCameraOnboarding(
              onDismiss: () {
                setState(() {
                  _showOnboarding = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Flash overlay
        if (_isFlashOn)
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),

        // Retro viewfinder overlay
        _buildViewfinderOverlay(),

        // Shot counter
        Positioned(
          top: 60,
          right: 20,
          child: _buildShotCounter(),
        ),

        // Queue button
        Positioned(
          top: 60,
          left: 20,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo_library, color: Colors.grey[300]),
                onPressed: () {
                  setState(() {
                    _showQueue = true;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.grey[300]),
                onPressed: () {
                  setState(() {
                    _showHelp = true;
                  });
                },
              ),
            ],
          ),
        ),

        // Shutter button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: _buildShutterButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinderOverlay() {
    return Stack(
      children: [
        // Corner brackets
        Positioned(
          top: 80,
          left: 20,
          child: _buildCornerBracket(true, true),
        ),
        Positioned(
          top: 80,
          right: 20,
          child: _buildCornerBracket(true, false),
        ),
        Positioned(
          bottom: 120,
          left: 20,
          child: _buildCornerBracket(false, true),
        ),
        Positioned(
          bottom: 120,
          right: 20,
          child: _buildCornerBracket(false, false),
        ),

        // Center crosshair
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),

        // Brand text
        Positioned(
          bottom: 140,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'DISPOSABLE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerBracket(bool isTop, bool isLeft) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.6),
            width: 2,
          ),
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.6),
            width: 2,
          ),
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.6),
            width: 2,
          ),
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
      ),
      child: CustomPaint(
        painter: _CornerBracketPainter(isTop, isLeft),
      ),
    );
  }

  Widget _buildShotCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: _remainingShots > 10 ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            '$_remainingShots',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.grey[400]!,
              Colors.grey[600]!,
              Colors.grey[800]!,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[500]!,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[300]),
          onPressed: () {
            setState(() {
              _showQueue = false;
            });
          },
        ),
        title: Text(
          'Developing Queue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.grey[200],
            letterSpacing: 2,
          ),
        ),
      ),
      body: _developingQueue.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No photos yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take some shots!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w200,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _developingQueue.length,
              itemBuilder: (context, index) {
                final photo = _developingQueue[index];
                return _buildPhotoCard(photo, index);
              },
            ),
    );
  }

  Widget _buildPhotoCard(DevelopingPhoto photo, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: photo.isDeveloped
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(photo.imagePath),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.hourglass_empty,
                        color: Colors.grey[600],
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shot #${_developingQueue.length - index}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[200],
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      photo.isDeveloped
                          ? photo.isShakeDeveloped
                              ? 'Shake developed'
                              : 'Developed'
                          : 'Developing...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: photo.isDeveloped
                            ? Colors.green[400]
                            : Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!photo.isDeveloped) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(photo.remainingTime),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (photo.canShakeDevelop)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_iphone,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Shake to develop',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[400],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerBracketPainter(this.isTop, this.isLeft);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final lineLength = 20.0;

    if (isTop && isLeft) {
      path.moveTo(0, lineLength);
      path.lineTo(0, 0);
      path.lineTo(lineLength, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width - lineLength, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, lineLength);
    } else if (!isTop && isLeft) {
      path.moveTo(0, size.height - lineLength);
      path.lineTo(0, size.height);
      path.lineTo(lineLength, size.height);
    } else {
      path.moveTo(size.width - lineLength, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - lineLength);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
